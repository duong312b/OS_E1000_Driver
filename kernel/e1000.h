#ifndef E1000_H
#define E1000_H

#include "types.h"

// E1000 MMIO
#define E1000_MMIO_BASE 0x40000000L
#define E1000_MMIO_SIZE 0x20000L

#define E1000_CTRL   0x0000
#define E1000_STATUS 0x0008

// Interrupt registers
#define E1000_ICR    0x00C0   // Interrupt Cause Read (doc la tu xoa)
#define E1000_IMS    0x00D0   // Interrupt Mask Set (bat ngat)
#define E1000_IMC    0x00D8   // Interrupt Mask Clear (tat ngat)

#define E1000_ICR_RXDMT0 (1 << 4)   // RX ring con it descriptor trong
#define E1000_ICR_RXO    (1 << 6)   // RX overrun (ring day)
#define E1000_ICR_RXT0   (1 << 7)   // Co goi moi nhan xong

// MAC registers
#define E1000_RAL0   0x5400
#define E1000_RAH0   0x5404

// TX registers
#define E1000_TDBAL  0x3800
#define E1000_TDBAH  0x3804
#define E1000_TDLEN  0x3808
#define E1000_TDH    0x3810
#define E1000_TDT    0x3818

// RX registers
#define E1000_RDBAL  0x2800
#define E1000_RDBAH  0x2804
#define E1000_RDLEN  0x2808
#define E1000_RDH    0x2810
#define E1000_RDT    0x2818

// TX/RX control registers
#define E1000_TCTL   0x0400
#define E1000_TIPG   0x0410
#define E1000_RCTL   0x0100

#define E1000_TCTL_EN    (1 << 1)
#define E1000_TCTL_PSP   (1 << 3)
#define E1000_TCTL_CT    (0x10 << 4)
#define E1000_TCTL_COLD  (0x40 << 12)

#define E1000_RCTL_EN    (1 << 1)
#define E1000_RCTL_BAM   (1 << 15)
#define E1000_RCTL_SECRC (1 << 26)

#define NUM_TX_DESC 8
#define NUM_RX_DESC 8
#define E1000_TX_BUF_SIZE 2048
#define E1000_RX_BUF_SIZE 2048

// TX descriptor command / status bits
#define E1000_TXD_CMD_EOP  0x01
#define E1000_TXD_CMD_IFCS 0x02
#define E1000_TXD_CMD_RS   0x08
#define E1000_TXD_STAT_DD  0x01

// RX descriptor status bits
#define E1000_RXD_STAT_DD  0x01
#define E1000_RXD_STAT_EOP 0x02

// TX Descriptor
struct tx_desc {
    uint64 addr;
    uint16 length;
    uint8 cso;
    uint8 cmd;
    uint8 status;
    uint8 css;
    uint16 special;
} __attribute__((packed));

// RX Descriptor
struct rx_desc {
    uint64 addr;
    uint16 length;
    uint16 checksum;
    uint8 status;
    uint8 errors;
    uint16 special;
} __attribute__((packed));

// PLIC IRQ cua E1000, do pci_init() tinh tu slot PCI (0 = chua tim thay card).
extern int e1000_irq;

void e1000_test_mmio(void);
void e1000_read_mac(void);
void e1000_init_rings(void);
void e1000_configure_rings(void);

// Gui 1 frame Ethernet hoan chinh. Copy vao DMA buffer, khong giu buf.
// Tra ve 0 neu OK, -1 neu tham so sai hoac TX ring day.
int  e1000_transmit(uint8 *buf, int len);

// Goi tu devintr() khi PLIC bao IRQ cua E1000.
void e1000_intr(void);

#endif
