#ifndef E1000_H
#define E1000_H

#include "types.h"

#define E1000_MMIO_BASE 0x40000000L
#define E1000_MMIO_SIZE 0x20000L

#define E1000_CTRL   0x0000
#define E1000_STATUS 0x0008

void e1000_test_mmio(void);

#endif
