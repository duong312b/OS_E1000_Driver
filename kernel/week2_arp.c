#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "net.h"
#include "e1000.h"

int
week2_net_tx(uint8 *buf, int len)
{
  int ret;

  if (buf == 0)
    return -1;

  ret = e1000_transmit((char *)buf, len);
  kfree(buf);

  return ret;
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
