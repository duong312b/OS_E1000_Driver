
#include "e1000.h"
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "net.h"

void week3_arp_init(void);

volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
  if (cpuid() == 0) {
    consoleinit();
    printkinit();
    printk("\n");
    printk("xv6 kernel is booting\n");
    printk("\n");

    kinit();
    kvminit();
    kvminithart();

    // Initialize E1000 driver.
    pci_init();
    e1000_test_mmio();
    e1000_read_mac();
    e1000_init_rings();
    e1000_configure_rings();
    e1000_test_tx();
    // Initialize and test ARP.
    week3_arp_init();
    week3_arp_selftest();

    procinit();
    trapinit();
    trapinithart();
    plicinit();
    plicinithart();
    binit();
    iinit();
    fileinit();
    virtio_disk_init();
    userinit();

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
      ;

    printk("hart %d starting\n", cpuid());
    kvminithart();
    trapinithart();
    plicinithart();
  }

  scheduler();
}
