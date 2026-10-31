#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "e1000.h"
#define NUM_TX_DESC 8
#define NUM_RX_DESC 8
#define E1000_BUF_SIZE 2048

struct tx_desc *tx_ring;
struct rx_desc *rx_ring;

char *tx_bufs[NUM_TX_DESC];
char *rx_bufs[NUM_RX_DESC];

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
