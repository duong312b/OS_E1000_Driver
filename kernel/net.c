#include "types.h"
#include "net.h"

uint32
cksum_partial(uint32 sum, const void *buf, int len)
{
  const uint8 *p = (const uint8 *)buf;

  while (len > 1) {
    sum += ((uint32)p[0] << 8) | p[1];
    p += 2;
    len -= 2;
  }
  if (len == 1)
    sum += (uint32)p[0] << 8;
  return sum;
}

uint16
cksum_finish(uint32 sum)
{
  while (sum >> 16)
    sum = (sum & 0xffff) + (sum >> 16);
  return htons((uint16)~sum);
}

uint16
in_cksum(const void *buf, int len)
{
  return cksum_finish(cksum_partial(0, buf, len));
}

uint8  week2_my_mac[ETHADDR_LEN] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
uint32 week2_my_ip = MAKE_IP_ADDR(10, 0, 2, 15);

uint32 week2_rx_arp;
uint32 week2_rx_ip;
uint32 week2_rx_drop;

static int
mac_equal(const uint8 *a, const uint8 *b)
{
  int i;

  for (i = 0; i < ETHADDR_LEN; i++)
    if (a[i] != b[i])
      return 0;
  return 1;
}

static int
mac_is_broadcast(const uint8 *a)
{
  int i;

  for (i = 0; i < ETHADDR_LEN; i++)
    if (a[i] != 0xff)
      return 0;
  return 1;
}

int
week2_eth_classify(const uint8 *buf, int len, const uint8 *mymac)
{
  const struct eth *e;
  int type;

  if (buf == 0 || mymac == 0 || len < ETH_HDR_LEN)
    return WEEK2_ETH_DROP_SHORT;

  e = (const struct eth *)buf;
  if (!mac_is_broadcast(e->dhost) && !mac_equal(e->dhost, mymac))
    return WEEK2_ETH_DROP_NOT_FOR_US;

  type = ntohs(e->type);
  if (type == ETHTYPE_ARP) {
    if (len < ETH_HDR_LEN + ARP_HDR_LEN)
      return WEEK2_ETH_DROP_SHORT;
    return WEEK2_ETH_TO_ARP;
  }
  if (type == ETHTYPE_IP) {
    if (len < ETH_HDR_LEN + IP_HDR_MIN_LEN)
      return WEEK2_ETH_DROP_SHORT;
    return WEEK2_ETH_TO_IP;
  }
  return WEEK2_ETH_DROP_UNSUPPORTED;
}

void (*week3_arp_hook)(const uint8 *buf, int len);

int
net_rx(const uint8 *buf, int len)
{
  int verdict;

  verdict = week2_eth_classify(buf, len, week2_my_mac);
  if (verdict == WEEK2_ETH_TO_ARP) {
    __sync_fetch_and_add(&week2_rx_arp, 1);
    if (week3_arp_hook)
      week3_arp_hook(buf, len);
  }
  else if (verdict == WEEK2_ETH_TO_IP)
    __sync_fetch_and_add(&week2_rx_ip, 1);
  else
    __sync_fetch_and_add(&week2_rx_drop, 1);
  return verdict;
}

int
week2_arp_build_request(uint8 *buf, int buflen, const uint8 *srcmac,
                        uint32 srcip, uint32 dstip)
{
  struct eth *e;
  struct arp *a;
  int i;

  if (buf == 0 || srcmac == 0 || buflen < ETH_MIN_FRAME)
    return -1;

  for (i = 0; i < ETH_MIN_FRAME; i++)
    buf[i] = 0;

  e = (struct eth *)buf;
  a = (struct arp *)(buf + ETH_HDR_LEN);

  for (i = 0; i < ETHADDR_LEN; i++) {
    e->dhost[i] = 0xff;
    e->shost[i] = srcmac[i];
    a->sha[i] = srcmac[i];
  }
  e->type = htons(ETHTYPE_ARP);

  a->hrd = htons(ARP_HRD_ETHER);
  a->pro = htons(ETHTYPE_IP);
  a->hln = ETHADDR_LEN;
  a->pln = 4;
  a->op = htons(ARP_OP_REQUEST);
  a->sip = htonl(srcip);
  a->tip = htonl(dstip);
  return ETH_MIN_FRAME;
}
