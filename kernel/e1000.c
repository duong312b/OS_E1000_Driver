#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "e1000.h"
#include "net.h"

#define REG(offset) ((volatile uint32 *)(E1000_MMIO_BASE + (offset)))

// Doc status descriptor qua con tro volatile: phan cung ghi vao bang DMA,
// compiler khong duoc phep cache gia tri.
#define TXD_STATUS(i) (*(volatile uint8 *)&tx_ring[i].status)
#define RXD_STATUS(i) (*(volatile uint8 *)&rx_ring[i].status)

struct tx_desc *tx_ring;
struct rx_desc *rx_ring;

char *tx_bufs[NUM_TX_DESC];
char *rx_bufs[NUM_RX_DESC];

// Hai lock rieng. Thu tu lay lock: rx_lock -> (arp_lock, tha ra) -> tx_lock.
// e1000_intr giu rx_lock trong luc goi net_rx, ma net_rx co the goi
// e1000_transmit (tra loi ARP), nen TX phai dung lock khac RX.
static struct spinlock e1000_tx_lock;
static struct spinlock e1000_rx_lock;

static int tx_tail;   // descriptor TX tiep theo se ghi (bao ve boi tx_lock)
static int rx_head;   // descriptor RX tiep theo can doc (bao ve boi rx_lock)

// Bo dem de debug. Chi cong don, khong can chinh xac tuyet doi.
static uint32 stat_tx_ok, stat_tx_full;
static uint32 stat_rx_ok, stat_rx_bad, stat_rx_overrun, stat_irq;

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

// Doc MAC that cua card va dong bo vao week2_my_mac de tang net luon
// dung dung dia chi card dang loc.
void
e1000_read_mac(void)
{
    uint32 ral;
    uint32 rah;

    ral = *REG(E1000_RAL0);
    rah = *REG(E1000_RAH0);

    week2_my_mac[0] = ral & 0xff;
    week2_my_mac[1] = (ral >> 8) & 0xff;
    week2_my_mac[2] = (ral >> 16) & 0xff;
    week2_my_mac[3] = (ral >> 24) & 0xff;
    week2_my_mac[4] = rah & 0xff;
    week2_my_mac[5] = (rah >> 8) & 0xff;

    printk("E1000: MAC address = %x:%x:%x:%x:%x:%x\n",
           week2_my_mac[0], week2_my_mac[1], week2_my_mac[2],
           week2_my_mac[3], week2_my_mac[4], week2_my_mac[5]);
}

void
e1000_init_rings(void)
{
    int i;

    initlock(&e1000_tx_lock, "e1000_tx");
    initlock(&e1000_rx_lock, "e1000_rx");

    tx_ring = (struct tx_desc *)kalloc();
    if (tx_ring == 0)
        panic("E1000: TX ring allocation failed");

    rx_ring = (struct rx_desc *)kalloc();
    if (rx_ring == 0)
        panic("E1000: RX ring allocation failed");

    memset(tx_ring, 0, PGSIZE);
    memset(rx_ring, 0, PGSIZE);

    for (i = 0; i < NUM_TX_DESC; i++) {
        tx_bufs[i] = (char *)kalloc();
        if (tx_bufs[i] == 0)
            panic("E1000: TX buffer allocation failed");
        memset(tx_bufs[i], 0, PGSIZE);

        tx_ring[i].addr = (uint64)tx_bufs[i];
        tx_ring[i].status = E1000_TXD_STAT_DD;   // coi nhu "da gui xong" = ranh
    }

    for (i = 0; i < NUM_RX_DESC; i++) {
        rx_bufs[i] = (char *)kalloc();
        if (rx_bufs[i] == 0)
            panic("E1000: RX buffer allocation failed");
        memset(rx_bufs[i], 0, PGSIZE);

        rx_ring[i].addr = (uint64)rx_bufs[i];
        rx_ring[i].status = 0;
    }

    tx_tail = 0;
    rx_head = 0;

    printk("E1000: TX/RX rings allocated successfully\n");
}

void
e1000_configure_rings(void)
{
    uint64 tx_pa = (uint64)tx_ring;   // kernel xv6 anh xa dong nhat: VA == PA
    uint64 rx_pa = (uint64)rx_ring;
    uint32 icr __attribute__((unused));

    // Tat moi ngat va tat TX/RX truoc khi cau hinh.
    *REG(E1000_IMC) = 0xffffffff;
    *REG(E1000_RCTL) = 0;
    *REG(E1000_TCTL) = 0;

    // TX ring.
    *REG(E1000_TDBAL) = (uint32)tx_pa;
    *REG(E1000_TDBAH) = (uint32)(tx_pa >> 32);
    *REG(E1000_TDLEN) = NUM_TX_DESC * sizeof(struct tx_desc);
    *REG(E1000_TDH) = 0;
    *REG(E1000_TDT) = 0;

    // RX ring.
    *REG(E1000_RDBAL) = (uint32)rx_pa;
    *REG(E1000_RDBAH) = (uint32)(rx_pa >> 32);
    *REG(E1000_RDLEN) = NUM_RX_DESC * sizeof(struct rx_desc);
    *REG(E1000_RDH) = 0;

    __sync_synchronize();
    // Giao 7 descriptor (0..6) cho phan cung; tail = 7 de ring khong "day" ngay.
    *REG(E1000_RDT) = NUM_RX_DESC - 1;

    *REG(E1000_TIPG) = 0x0060200A;
    *REG(E1000_TCTL) = E1000_TCTL_EN | E1000_TCTL_PSP |
                       E1000_TCTL_CT | E1000_TCTL_COLD;

    // RX: enable, nhan broadcast, bo CRC. BSIZE mac dinh = 2048.
    *REG(E1000_RCTL) = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SECRC;

    // Xoa ngat dang cho (neu co) roi MOI bat ngat nhan.
    icr = *REG(E1000_ICR);
    *REG(E1000_IMS) = E1000_ICR_RXT0 | E1000_ICR_RXDMT0 | E1000_ICR_RXO;

    printk("E1000: TX/RX configured, RX interrupts enabled\n");
}

int
e1000_transmit(uint8 *buf, int len)
{
    int idx;

    if (buf == 0 || len < ETH_HDR_LEN || len > E1000_TX_BUF_SIZE)
        return -1;

    acquire(&e1000_tx_lock);
    idx = tx_tail;

    // DD = phan cung da gui xong descriptor nay, duoc phep dung lai.
    if (!(TXD_STATUS(idx) & E1000_TXD_STAT_DD)) {
        stat_tx_full++;
        release(&e1000_tx_lock);
        return -1;
    }

    memmove(tx_bufs[idx], buf, len);

    tx_ring[idx].length = len;
    tx_ring[idx].cso = 0;
    tx_ring[idx].css = 0;
    tx_ring[idx].special = 0;
    tx_ring[idx].cmd = E1000_TXD_CMD_EOP | E1000_TXD_CMD_IFCS | E1000_TXD_CMD_RS;
    tx_ring[idx].status = 0;

    // Moi ghi vao descriptor/buffer phai thay duoc truoc khi tang TDT.
    __sync_synchronize();

    tx_tail = (idx + 1) % NUM_TX_DESC;
    *REG(E1000_TDT) = tx_tail;

    stat_tx_ok++;
    release(&e1000_tx_lock);
    return 0;
}

// Rut het cac frame dang nam trong RX ring. Phai duoc goi voi rx_lock.
// Buffer chi duoc "muon" cho net_rx; descriptor chi tra cho card SAU khi
// net_rx xong, nen khong can copy.
static void
e1000_recv(void)
{
    int idx, len;
    uint8 status;

    for (;;) {
        idx = rx_head;
        status = RXD_STATUS(idx);
        if (!(status & E1000_RXD_STAT_DD))
            break;

        __sync_synchronize();   // doc length/errors sau khi thay DD
        len = rx_ring[idx].length;

        if (rx_ring[idx].errors != 0 || !(status & E1000_RXD_STAT_EOP) ||
            len < ETH_HDR_LEN || len > E1000_RX_BUF_SIZE) {
            stat_rx_bad++;
        } else {
            stat_rx_ok++;
            net_rx((uint8 *)rx_bufs[idx], len);
        }

        // Tra descriptor cho card.
        rx_ring[idx].length = 0;
        rx_ring[idx].checksum = 0;
        rx_ring[idx].errors = 0;
        rx_ring[idx].status = 0;
        __sync_synchronize();
        *REG(E1000_RDT) = idx;

        rx_head = (idx + 1) % NUM_RX_DESC;
    }
}

// Ham xu ly ngat. Goi tu devintr() khi irq == e1000_irq.
void
e1000_intr(void)
{
    uint32 icr;

    // DOC ICR TRUOC: thao tac doc xoa nguyen nhan ngat. Neu khong doc,
    // duong IRQ (level-triggered) van keo cao va ngat se bi kich lai mai mai.
    // Doc truoc roi moi rut ring: goi den giua chung se tao ngat moi, khong mat.
    icr = *REG(E1000_ICR);

    acquire(&e1000_rx_lock);
    stat_irq++;
    if (icr & E1000_ICR_RXO)
        stat_rx_overrun++;
    e1000_recv();
    release(&e1000_rx_lock);
}

// Goi tay khi debug (vd. tu mot phim tat hoac cuoi selftest).
void
e1000_stats(void)
{
    printk("E1000: irq=%d rx_ok=%d rx_bad=%d rx_overrun=%d tx_ok=%d tx_full=%d\n",
           stat_irq, stat_rx_ok, stat_rx_bad, stat_rx_overrun,
           stat_tx_ok, stat_tx_full);
}
