
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "pci.h"

#define PCI_VENDOR_ID       0x00
#define PCI_DEVICE_ID       0x02
#define PCI_COMMAND         0x04
#define PCI_BAR0            0x10
#define PCI_BAR1            0x14

#define PCI_VENDOR_INTEL    0x8086
#define PCI_DEVICE_E1000    0x100e

// Dia chi MMIO du kien cho E1000 tren QEMU virt
#define E1000_MMIO_BASE     0x40000000U

static volatile uint16 *
pci_config_addr(int dev, int func, int offset)
{
    uint64 addr;

    addr = PCI_ECAM
         + ((uint64)dev << 15)
         + ((uint64)func << 12)
         + offset;

    return (volatile uint16 *)addr;
}

static volatile uint32 *
pci_config_addr32(int dev, int func, int offset)
{
    uint64 addr;

    addr = PCI_ECAM
         + ((uint64)dev << 15)
         + ((uint64)func << 12)
         + offset;

    return (volatile uint32 *)addr;
}

void
pci_init(void)
{
    int dev, func;
    uint16 vendor, device, command;
    uint32 bar0, bar1;
    uint32 bar0_mask;
    uint32 mmio_size;
    uint32 mmio_base;
    int found = 0;

    printk("PCI: scanning bus 0\n");

    for (dev = 0; dev < 32; dev++) {
        for (func = 0; func < 8; func++) {

            vendor = *pci_config_addr(dev, func, PCI_VENDOR_ID);

            if (vendor == 0xffff || vendor == 0x0000)
                continue;

            device = *pci_config_addr(dev, func, PCI_DEVICE_ID);

            printk("PCI: bus 0 dev %d func %d vendor 0x%x device 0x%x\n",
                   dev, func, vendor, device);

            if (vendor != PCI_VENDOR_INTEL ||
                device != PCI_DEVICE_E1000)
                continue;

            printk("PCI: E1000 detected!\n");

            // Doc BAR0 va BAR1
            bar0 = *pci_config_addr32(dev, func, PCI_BAR0);
            bar1 = *pci_config_addr32(dev, func, PCI_BAR1);

            printk("PCI: BAR0 original = 0x%x\n", bar0);
            printk("PCI: BAR1 original = 0x%x\n", bar1);

            // Doc kich thuoc BAR0
            // Chi probe khi BAR0 la MMIO 32-bit
            if ((bar0 & 1) != 0 || (bar0 & 0x6) != 0) {
                printk("PCI: BAR0 is not 32-bit MMIO\n");
                continue;
            }

            *pci_config_addr32(dev, func, PCI_BAR0) = 0xffffffff;
            bar0_mask = *pci_config_addr32(dev, func, PCI_BAR0);

            // Khoi phuc BAR0 ban dau
            *pci_config_addr32(dev, func, PCI_BAR0) = bar0;

            printk("PCI: BAR0 mask = 0x%x\n", bar0_mask);

            if (bar0_mask == 0 || bar0_mask == 0xffffffff) {
                printk("PCI: invalid BAR0 mask\n");
                continue;
            }

            mmio_size = ~(bar0_mask & 0xfffffff0U) + 1;

            printk("PCI: BAR0 size = 0x%x bytes\n", mmio_size);

            // Kiem tra kich thuoc va can le
            if (mmio_size != 0x20000 ||
                (E1000_MMIO_BASE & (mmio_size - 1)) != 0) {
                printk("PCI: invalid MMIO size or alignment\n");
                continue;
            }

            // Cap dia chi cho BAR0
            *pci_config_addr32(dev, func, PCI_BAR0) =
                E1000_MMIO_BASE;

            bar0 = *pci_config_addr32(dev, func, PCI_BAR0);
            mmio_base = bar0 & 0xfffffff0U;

            printk("PCI: BAR0 assigned = 0x%x\n", bar0);
            printk("PCI: MMIO base = 0x%x\n", mmio_base);

            if (mmio_base != E1000_MMIO_BASE) {
                printk("PCI: BAR0 assignment failed\n");
                continue;
            }

            // Bat Memory Space va Bus Master
            command = *pci_config_addr(dev, func, PCI_COMMAND);
            command |= 0x0006;

            *pci_config_addr(dev, func, PCI_COMMAND) = command;

            printk("PCI: COMMAND enabled = 0x%x\n", command);

            found = 1;
        }
    }

    if (!found)
        printk("PCI: E1000 not initialized\n");
}

