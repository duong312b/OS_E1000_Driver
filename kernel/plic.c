#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "e1000.h"

//
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
  // e1000_irq do pci_init() tinh; 0 nghia la khong tim thay card.
  if (e1000_irq)
    *(volatile uint32 *)(PLIC + e1000_irq * 4) = 1;
}

void
plicinithart(void)
{
  int hart = cpuid();

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // bat IRQ cua e1000: moi thanh ghi enable 32 bit, IRQ >= 32 nam o word tiep theo.
  if (e1000_irq)
    *(volatile uint32 *)(PLIC_SENABLE(hart) + 4 * (e1000_irq / 32)) |=
      1 << (e1000_irq % 32);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
}

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
  int hart = cpuid();
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
  return irq;
}

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
  int hart = cpuid();
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
}
