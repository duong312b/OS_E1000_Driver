// Pure IPv4/ICMP logic: no locks, no kalloc, no printk, so it can be unit-tested on the host.
#include "types.h"
#include "net.h"
#include "week4_ip.h"

static void
zero(uint8 *p, int n)
{
  int i;

  for (i = 0; i < n; i++)
    p[i] = 0;
}

static void
copy(uint8 *d, const uint8 *s, int n)
{
  int i;

  for (i = 0; i < n; i++)
    d[i] = s[i];
}

static int
src_ok(uint32 a)
{
  if (a == 0 || a == 0xffffffff)
    return 0;
  if ((a >> 28) == 0xe)          // 224.0.0.0/4 multicast
    return 0;
  return 1;
}

uint32
week4_next_hop(uint32 dst, uint32 myip)
{
  if (((dst ^ myip) & WEEK4_NETMASK) == 0)
    return dst;                  // on-link: ARP for the destination itself
  return WEEK4_GATEWAY;          // off-link: ARP for the gateway
}

int
week4_ip_parse(const uint8 *frame, int len, uint32 myip, struct week4_ip_info *info)
{
  const struct eth *e;
  const struct ip *ip;
  int hl, total;
  uint32 src, dst;

  if (frame == 0 || info == 0 || len < ETH_HDR_LEN + IP_HDR_MIN_LEN)
    return WEEK4_IP_DROP_SHORT;
  e = (const struct eth *)frame;
  if (ntohs(e->type) != ETHTYPE_IP)
    return WEEK4_IP_DROP_TYPE;

  ip = (const struct ip *)(frame + ETH_HDR_LEN);
  if (IP_VERSION(ip->vhl) != 4)
    return WEEK4_IP_DROP_VERSION;
  hl = IP_HDRLEN(ip->vhl);
  if (hl < IP_HDR_MIN_LEN)
    return WEEK4_IP_DROP_IHL;

  // ip->len is the truth; the frame may be longer (Ethernet padding) but never shorter.
  total = ntohs(ip->len);
  if (total < hl || total > len - ETH_HDR_LEN)
    return WEEK4_IP_DROP_LEN;

  if (in_cksum(ip, hl) != 0)     // sum over a correct header (checksum included) is 0
    return WEEK4_IP_DROP_CKSUM;

  if (ntohs(ip->off) & (IP_MF | IP_OFFMASK))
    return WEEK4_IP_DROP_FRAG;

  src = ntohl(ip->src);
  dst = ntohl(ip->dst);
  if (dst != myip)
    return WEEK4_IP_DROP_NOT_US;
  if (!src_ok(src))
    return WEEK4_IP_DROP_ADDR;
  if (ip->ttl == 0)
    return WEEK4_IP_DROP_TTL;

  info->src = src;
  info->dst = dst;
  info->proto = ip->proto;
  info->ttl = ip->ttl;
  info->id = ntohs(ip->id);
  info->hdrlen = hl;
  info->paylen = total - hl;
  info->payload = frame + ETH_HDR_LEN + hl;
  return WEEK4_IP_OK;
}

int
week4_ip_fill(uint8 *frame, const uint8 *srcmac, uint32 srcip, uint32 dstip,
              uint8 proto, uint16 id, int paylen)
{
  struct eth *e;
  struct ip *ip;
  int i, n, fl;

  if (frame == 0 || srcmac == 0 || paylen < 0 || paylen > WEEK4_IP_MAX_PAYLOAD)
    return -1;
  n = WEEK4_IP_PAYLOAD_OFF + paylen;
  fl = n < ETH_MIN_FRAME ? ETH_MIN_FRAME : n;

  zero(frame, WEEK4_IP_PAYLOAD_OFF);
  zero(frame + n, fl - n);

  e = (struct eth *)frame;
  ip = (struct ip *)(frame + ETH_HDR_LEN);
  for (i = 0; i < ETHADDR_LEN; i++)
    e->shost[i] = srcmac[i];
  e->type = htons(ETHTYPE_IP);

  ip->vhl = (4 << 4) | 5;
  ip->tos = 0;
  ip->len = htons(IP_HDR_MIN_LEN + paylen);
  ip->id = htons(id);
  ip->off = 0;
  ip->ttl = WEEK4_IP_TTL;
  ip->proto = proto;
  ip->sum = 0;
  ip->src = htonl(srcip);
  ip->dst = htonl(dstip);
  ip->sum = in_cksum(ip, IP_HDR_MIN_LEN);   // already in network byte order
  return fl;
}

void
week4_echo_fill(uint8 *d, int n)
{
  int i;

  for (i = 0; i < n; i++)
    d[i] = (uint8)i;
}

int
week4_echo_check(const uint8 *d, int n)
{
  int i;

  for (i = 0; i < n; i++)
    if (d[i] != (uint8)i)
      return 0;
  return 1;
}

int
week4_icmp_parse(const struct week4_ip_info *ip, struct week4_icmp_info *ic)
{
  const struct icmp *h;

  if (ip == 0 || ic == 0 || ip->proto != IPPROTO_ICMP || ip->paylen < ICMP_HDR_LEN)
    return WEEK4_ICMP_DROP_SHORT;
  if (in_cksum(ip->payload, ip->paylen) != 0)
    return WEEK4_ICMP_DROP_CKSUM;

  h = (const struct icmp *)ip->payload;
  ic->type = h->type;
  ic->code = h->code;
  ic->id = ntohs(h->id);
  ic->seq = ntohs(h->seq);
  ic->data = ip->payload + ICMP_HDR_LEN;
  ic->datalen = ip->paylen - ICMP_HDR_LEN;

  if (h->code != 0)
    return WEEK4_ICMP_DROP_UNSUPPORTED;
  if (h->type == ICMP_TYPE_ECHO)
    return WEEK4_ICMP_ECHO_REQ;
  if (h->type == ICMP_TYPE_ECHOREPLY)
    return WEEK4_ICMP_ECHO_REPLY;
  return WEEK4_ICMP_DROP_UNSUPPORTED;
}

int
week4_icmp_write_echo(uint8 *icmp, int max, uint16 id, uint16 seq, int datalen)
{
  struct icmp *h;
  int n;

  if (icmp == 0 || datalen < 0 || datalen > WEEK4_ICMP_MAX_DATA)
    return -1;
  n = ICMP_HDR_LEN + datalen;
  if (n > max)
    return -1;
  h = (struct icmp *)icmp;
  h->type = ICMP_TYPE_ECHO;
  h->code = 0;
  h->sum = 0;
  h->id = htons(id);
  h->seq = htons(seq);
  week4_echo_fill(icmp + ICMP_HDR_LEN, datalen);
  h->sum = in_cksum(icmp, n);
  return n;
}

int
week4_icmp_make_reply(const uint8 *frame, const struct week4_ip_info *ip,
                      const struct week4_icmp_info *ic, const uint8 *mymac,
                      uint8 *reply, int replymax, uint16 ipid)
{
  const struct eth *e;
  struct eth *re;
  struct icmp *rh;
  int i, n, icmplen, fl;

  if (frame == 0 || ip == 0 || ic == 0 || mymac == 0 || reply == 0)
    return -1;
  icmplen = ip->paylen;
  if (icmplen < ICMP_HDR_LEN || icmplen > WEEK4_IP_MAX_PAYLOAD)
    return -1;
  n = WEEK4_IP_PAYLOAD_OFF + icmplen;
  fl = n < ETH_MIN_FRAME ? ETH_MIN_FRAME : n;
  if (replymax < fl)
    return -1;

  // Clean 20-byte header (IP options of the request are not echoed back); src/dst swapped.
  if (week4_ip_fill(reply, mymac, ip->dst, ip->src, IPPROTO_ICMP, ipid, icmplen) < 0)
    return -1;

  // Reply straight to the L2 sender of the request: no ARP lookup needed.
  e = (const struct eth *)frame;
  re = (struct eth *)reply;
  for (i = 0; i < ETHADDR_LEN; i++)
    re->dhost[i] = e->shost[i];

  copy(reply + WEEK4_IP_PAYLOAD_OFF, ip->payload, icmplen);
  rh = (struct icmp *)(reply + WEEK4_IP_PAYLOAD_OFF);
  rh->type = ICMP_TYPE_ECHOREPLY;
  rh->code = 0;
  rh->sum = 0;
  rh->sum = in_cksum(rh, icmplen);
  return fl;
}
