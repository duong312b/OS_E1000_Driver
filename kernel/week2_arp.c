#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "net.h"

extern int e1000_transmit(uint8 *buf, int len);

int
week2_net_tx(uint8 *buf, int len)
{
  // Gọi trực tiếp xuống hàm E1000 để truyền ra ngoài
  if (e1000_transmit(buf, len) < 0) {
    printk("week2_net_tx: E1000 TX ring is full\n");
  }

  // Luôn phải free buffer sau khi đã copy nội dung của nó xuống DMA buffer
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
