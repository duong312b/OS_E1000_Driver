#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "e1000.h"

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
