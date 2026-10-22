#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "pci.h"

#define PCI_CONFIG_BUS0_SIZE (1L << 20)
#define PCI_VENDOR_ID 0x00
#define PCI_DEVICE_ID 0x02

#define PCI_VENDOR_INTEL 0x8086
#define PCI_DEVICE_E1000 0x100e

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

void
pci_init(void)
{
    int dev, func;
    uint16 vendor, device;
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

            if (vendor == PCI_VENDOR_INTEL &&
                device == PCI_DEVICE_E1000) {
                printk("PCI: E1000 detected!\n");
                found = 1;
            }
        }
    }

    if (!found)
        printk("PCI: E1000 8086:100e not found on bus 0\n");
}
