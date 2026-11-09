#ifndef E1000_H
#define E1000_H

#include "types.h"

// E1000 MMIO
#define E1000_MMIO_BASE 0x40000000L
#define E1000_MMIO_SIZE 0x20000L

#define E1000_CTRL   0x0000
#define E1000_STATUS 0x0008

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
#define NUM_TX_DESC 8
#define NUM_RX_DESC 8
#define E1000_TX_BUF_SIZE 2048
#define E1000_RX_BUF_SIZE 2048

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
// TX descriptor command bits
#define E1000_TXD_CMD_EOP  0x01
#define E1000_TXD_CMD_IFCS 0x02
#define E1000_TXD_CMD_RS   0x08

// TX descriptor status bits
#define E1000_TXD_STAT_DD  0x01
// RX descriptor status bits
#define E1000_RXD_STAT_DD  0x01
#define E1000_RXD_STAT_EOP 0x02
// RX Descriptor
struct rx_desc {
    uint64 addr;
    uint16 length;
    uint16 checksum;
    uint8 status;
    uint8 errors;
    uint16 special;
} __attribute__((packed));

void e1000_test_mmio(void);
void e1000_read_mac(void);

void e1000_init_rings(void);
void e1000_configure_rings(void);
int e1000_transmit(char *buf, int len);
void e1000_test_tx(void);
int e1000_receive(char *buf, int maxlen);
void e1000_test_rx(void);
#endif
