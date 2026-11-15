#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "e1000.h"
#include "net.h"
#include "spinlock.h"
#define NUM_TX_DESC 8
#define NUM_RX_DESC 8
#define E1000_BUF_SIZE 2048

struct tx_desc *tx_ring;
struct rx_desc *rx_ring;

char *tx_bufs[NUM_TX_DESC];
char *rx_bufs[NUM_RX_DESC];

static int tx_tail = 0;
static int rx_head = 0;

static struct spinlock tx_lock;
static struct spinlock rx_lock;

static uint32 tx_packets = 0;
static uint32 tx_errors = 0;
static uint32 rx_packets = 0;
static uint32 rx_errors = 0;
#define REG(offset) ((volatile uint32 *)(E1000_MMIO_BASE + (offset)))

void
e1000_test_mmio(void)
{
    uint32 status;
    uint32 ctrl;

    status = *REG(E1000_STATUS);
    ctrl = *REG(E1000_CTRL);

    printk("E1000: MMIO test started\n");
    printk("E1000: STATUS = 0x%x\n", status);
    printk("E1000: CTRL = 0x%x\n", ctrl);
}
void
e1000_read_mac(void)
{
    uint32 ral;
    uint32 rah;

    ral = *REG(E1000_RAL0);
    rah = *REG(E1000_RAH0);

    printk("E1000: MAC address = %x:%x:%x:%x:%x:%x\n",
           ral & 0xff,
           (ral >> 8) & 0xff,
           (ral >> 16) & 0xff,
           (ral >> 24) & 0xff,
           rah & 0xff,
           (rah >> 8) & 0xff);
}
void
e1000_init_rings(void)
{
    int i;

    initlock(&tx_lock, "e1000-tx");
    initlock(&rx_lock, "e1000-rx");

    tx_tail = 0;
    rx_head = 0;
    tx_packets = tx_errors = 0;
    rx_packets = rx_errors = 0;

    // Allocate TX descriptor ring
    tx_ring = (struct tx_desc *)kalloc();
    if (tx_ring == 0)
        panic("E1000: TX ring allocation failed");

    // Allocate RX descriptor ring
    rx_ring = (struct rx_desc *)kalloc();
    if (rx_ring == 0)
        panic("E1000: RX ring allocation failed");

    memset(tx_ring, 0, PGSIZE);
    memset(rx_ring, 0, PGSIZE);

    // Allocate packet buffers
    for (i = 0; i < NUM_TX_DESC; i++) {
        tx_bufs[i] = (char *)kalloc();
        if (tx_bufs[i] == 0)
            panic("E1000: TX buffer allocation failed");

        memset(tx_bufs[i], 0, PGSIZE);

        tx_ring[i].addr = (uint64)tx_bufs[i];
        tx_ring[i].status = 1;
    }

    for (i = 0; i < NUM_RX_DESC; i++) {
        rx_bufs[i] = (char *)kalloc();
        if (rx_bufs[i] == 0)
            panic("E1000: RX buffer allocation failed");

        memset(rx_bufs[i], 0, PGSIZE);

        rx_ring[i].addr = (uint64)rx_bufs[i];
        rx_ring[i].status = 0;
    }
printk("E1000: TX/RX rings allocated successfully\n");
printk("E1000: TX ring address = %p\n", tx_ring);
printk("E1000: RX ring address = %p\n", rx_ring);
}
void
e1000_configure_rings(void)
{
    uint64 tx_pa;
    uint64 rx_pa;
    int i;

    tx_pa = (uint64)tx_ring;
    rx_pa = (uint64)rx_ring;

    // Disable TX and RX before configuration.
    *REG(E1000_RCTL) = 0;
    *REG(E1000_TCTL) = 0;

    // Configure TX descriptor ring.
    *REG(E1000_TDBAL) = (uint32)tx_pa;
    *REG(E1000_TDBAH) = (uint32)(tx_pa >> 32);
    *REG(E1000_TDLEN) = NUM_TX_DESC * 16;
    *REG(E1000_TDH) = 0;
    *REG(E1000_TDT) = 0;

    // Configure RX descriptor ring.
    *REG(E1000_RDBAL) = (uint32)rx_pa;
    *REG(E1000_RDBAH) = (uint32)(rx_pa >> 32);
    *REG(E1000_RDLEN) = NUM_RX_DESC * 16;
    *REG(E1000_RDH) = 0;

    for (i = 0; i < NUM_RX_DESC; i++) {
        rx_ring[i].status = 0;
    }

    __sync_synchronize();

    *REG(E1000_RDT) = NUM_RX_DESC - 1;

    // Configure TX.
    *REG(E1000_TIPG) = 0x0060200A;

    *REG(E1000_TCTL) =
        (1 << 1) |       // Transmit Enable
        (1 << 3) |       // Pad Short Packets
        (0x10 << 4) |    // Collision Threshold
        (0x40 << 12);    // Collision Distance

    // Configure RX: enable, broadcast accept, strip CRC.
    *REG(E1000_RCTL) =
        (1 << 1) |
        (1 << 15) |
        (1 << 26);

    printk("E1000: TX/RX registers configured\n");

printk("E1000: TDBAL = 0x%x\n", *REG(E1000_TDBAL));
printk("E1000: TDLEN = 0x%x\n", *REG(E1000_TDLEN));
printk("E1000: TCTL  = 0x%x\n", *REG(E1000_TCTL));

printk("E1000: RDBAL = 0x%x\n", *REG(E1000_RDBAL));
printk("E1000: RDLEN = 0x%x\n", *REG(E1000_RDLEN));
printk("E1000: RCTL  = 0x%x\n", *REG(E1000_RCTL));
}
int
e1000_transmit(char *buf, int len)
{
    int idx;
    int next;
    int timeout;

    if (buf == 0 || len < 14 || len > E1000_TX_BUF_SIZE)
        return -1;

    acquire(&tx_lock);

    if (tx_ring == 0) {
        tx_errors++;
        release(&tx_lock);
        return -1;
    }

    idx = tx_tail;

    if (!(*(volatile uint8 *)&tx_ring[idx].status &
          E1000_TXD_STAT_DD)) {
        tx_errors++;
        release(&tx_lock);
        return -1;
    }

    memmove(tx_bufs[idx], buf, len);

    tx_ring[idx].length = (uint16)len;
    tx_ring[idx].cso = 0;
    tx_ring[idx].cmd =
        E1000_TXD_CMD_EOP |
        E1000_TXD_CMD_IFCS |
        E1000_TXD_CMD_RS;
    tx_ring[idx].css = 0;
    tx_ring[idx].special = 0;
    tx_ring[idx].status = 0;

    __sync_synchronize();

    next = (idx + 1) % NUM_TX_DESC;
    *REG(E1000_TDT) = next;

    for (timeout = 0; timeout < 1000000; timeout++) {
        if (*(volatile uint8 *)&tx_ring[idx].status &
            E1000_TXD_STAT_DD)
            break;
    }

    if (!(*(volatile uint8 *)&tx_ring[idx].status &
          E1000_TXD_STAT_DD)) {
        tx_errors++;
        release(&tx_lock);
        return -1;
    }

    tx_tail = next;
    tx_packets++;

    release(&tx_lock);
    return 0;
}


void
e1000_test_tx(void)
{
    uint8 frame[60];
    uint32 ral, rah;
    int i;
    int success = 0;
    int failed = 0;

    memset(frame, 0, sizeof(frame));

    // Destination MAC: broadcast.
    for (i = 0; i < 6; i++)
        frame[i] = 0xff;

    // Read source MAC from E1000.
    ral = *REG(E1000_RAL0);
    rah = *REG(E1000_RAH0);

    frame[6] = ral & 0xff;
    frame[7] = (ral >> 8) & 0xff;
    frame[8] = (ral >> 16) & 0xff;
    frame[9] = (ral >> 24) & 0xff;
    frame[10] = rah & 0xff;
    frame[11] = (rah >> 8) & 0xff;

    // Test EtherType.
    frame[12] = 0x88;
    frame[13] = 0xb5;
    memmove(&frame[14], "XV6-E1000-TEST", 14);

    printk("E1000: Starting TX burst test (32 frames)...\n");

    for (i = 0; i < 32; i++) {
        frame[56] = i & 0xff;
        frame[57] = (i >> 8) & 0xff;
        frame[58] = 0;
        frame[59] = 0;

        if (e1000_transmit((char *)frame, sizeof(frame)) == 0)
            success++;
        else
            failed++;
    }

    printk("E1000: TX burst result: success=%d failed=%d\n",
           success, failed);

    e1000_print_stats();
}

int
e1000_receive(char *buf, int maxlen)
{
    int idx;
    int len;
    uint8 status;

    if (buf == 0 || maxlen <= 0)
        return -1;

    acquire(&rx_lock);

    if (rx_ring == 0) {
        rx_errors++;
        release(&rx_lock);
        return -1;
    }

    idx = rx_head;
    status = *(volatile uint8 *)&rx_ring[idx].status;

    if (!(status & E1000_RXD_STAT_DD)) {
        release(&rx_lock);
        return 0;
    }

    __sync_synchronize();

    len = rx_ring[idx].length;

    if (rx_ring[idx].errors != 0 ||
        !(status & E1000_RXD_STAT_EOP) ||
        len < 14 || len > maxlen ||
        len > E1000_RX_BUF_SIZE) {
        len = -1;
        rx_errors++;
    } else {
        memmove(buf, rx_bufs[idx], len);
        rx_packets++;
    }

    rx_ring[idx].length = 0;
    rx_ring[idx].checksum = 0;
    rx_ring[idx].errors = 0;
    rx_ring[idx].status = 0;

    __sync_synchronize();

    *REG(E1000_RDT) = idx;
    rx_head = (idx + 1) % NUM_RX_DESC;

    release(&rx_lock);
    return len;
}



int
e1000_poll_rx(void)
{
    char buf[E1000_RX_BUF_SIZE];
    int len;
    int count = 0;

    while (count < NUM_RX_DESC) {
        len = e1000_receive(buf, sizeof(buf));

        if (len <= 0)
            break;

        net_rx((const uint8 *)buf, len);
        count++;
    }

    return count;
}

void
e1000_test_rx(void)
{
    char buf[E1000_RX_BUF_SIZE];
    char expected[] = "HOST-TO-XV6-RX-TEST";
    int len;
    int timeout;
    int i;
    int payload_ok = 1;

    printk("E1000: Waiting for test frame...\n");

    for (timeout = 0; timeout < 10000000; timeout++) {
        len = e1000_receive(buf, sizeof(buf));

        if (len > 0) {
            printk("E1000: RX test passed, length=%d\n", len);

            printk("E1000: Destination MAC = %x:%x:%x:%x:%x:%x\n",
                   (uint8)buf[0], (uint8)buf[1],
                   (uint8)buf[2], (uint8)buf[3],
                   (uint8)buf[4], (uint8)buf[5]);

            // Check EtherType.
            printk("E1000: EtherType = 0x%x%x\n",
                   (uint8)buf[12], (uint8)buf[13]);

            if ((uint8)buf[12] != 0x88 ||
                (uint8)buf[13] != 0xb5) {
                printk("E1000: EtherType check FAILED\n");
                return;
            }

            // Check payload length.
            if (len < 14 + sizeof(expected) - 1) {
                printk("E1000: Payload too short\n");
                return;
            }

            // Compare received payload with expected data.
            for (i = 0; i < sizeof(expected) - 1; i++) {
                if (buf[14 + i] != expected[i]) {
                    payload_ok = 0;
                    break;
                }
            }

            // Print payload bytes in hexadecimal.
            printk("E1000: Payload = ");

            for (i = 14; i < len; i++) {
                printk("%x ", (uint8)buf[i]);
            }

            printk("\n");

            if (payload_ok) {
                printk("E1000: Payload check PASSED\n");
            } else {
                printk("E1000: Payload check FAILED at byte %d\n", i);
            }

            return;
        }

        if (len < 0) {
            printk("E1000: RX test failed\n");
            return;
        }
    }

    printk("E1000: RX timeout, no frame received\n");
}

void
e1000_print_stats(void)
{
    printk("E1000 TX: packets=%d errors=%d\n",
           __sync_fetch_and_add(&tx_packets, 0),
           __sync_fetch_and_add(&tx_errors, 0));
    printk("E1000 RX: packets=%d errors=%d\n",
           __sync_fetch_and_add(&rx_packets, 0),
           __sync_fetch_and_add(&rx_errors, 0));
}
