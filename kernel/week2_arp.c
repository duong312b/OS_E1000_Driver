#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "net.h"

int
week2_net_tx(uint8 *buf, int len)
{
  int i;

  printk("week2_net_tx: %d bytes\n", len);
  for (i = 0; i < len; i++) {
    if (buf[i] < 16)
      printk("0");
    printk("%x", buf[i]);
    if (i % 16 == 15 || i == len - 1)
      printk("\n");
    else
      printk(" ");
  }
  kfree(buf);
  return 0;
}

int
week2_arp_send_request(uint32 dstip)
{
  uint8 *buf;
  int n;

  buf = kalloc();
  if (buf == 0)
    return -1;
  n = week2_arp_build_request(buf, ETH_MAX_FRAME, week2_my_mac, week2_my_ip, dstip);
  if (n < 0) {
    kfree(buf);
    return -1;
  }
  return week2_net_tx(buf, n);
}
