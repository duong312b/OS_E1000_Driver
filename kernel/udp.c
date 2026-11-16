// dong, mo goi UDP qua IPv4 qua Ethernet
#include "types.h"
#include "net.h"

// Tinh tong kiem tra theo chuan RFC 768
// input: 
//  - src, dst: ip nguon va dich
//  - udp: con tro tro toi dau goi tin
//  - ulen: tong do dai goi tin
// output: gia tri checksum. Tra ve 0 neu dung de kiem tra goi tin den
static uint16
udp_cksum(uint32 src, uint32 dst, const uint8 *udp, int ulen)
{
    uint32 sum = 0;

    sum += (src >> 16) & 0xffff;
    sum += src & 0xffff;
    sum += (dst >> 16) & 0xffff;
    sum += dst & 0xffff;
    sum += IPPROTO_UDP;
    sum += (uint32)ulen;
    sum = cksum_partial(sum, udp, ulen);
    return cksum_finish(sum);
}

// Dong goi khung Ethernet chua goi UDP
// input: 
//  - frame: con tro toi bo dem chua khung tin
//  - framemax: kich thuoc toi da cua bo dem frame
//  - srcmac: dia chi MAC nguon
//  - srcip, dstip: IP cua nguon va dich
//  - sport, dport: port cua nguon va dich
//  - plen: do dai phan du lieu cua UDP
//  - ipid: dinh danh goi IP
// output: tong kich thuoc thuc te cua khung Ethernet sau khi dong goi, -1 neu loi
int
udp_build(uint8 *frame, int framemax, const uint8 *srcmac,
          uint32 srcip, uint32 dstip, uint16 sport, uint16 dport,
          int plen, uint16 ipid)
{
  struct eth *e;
  struct ip *ip;
  struct udp *u;
  int i, total, flen;

  if (frame == 0 || srcmac == 0 || plen < 0 || plen > UDP_MAX_PAYLOAD)
    return -1;
  total = UDP_FRAME_HDR + plen;
  flen = total < ETH_MIN_FRAME ? ETH_MIN_FRAME : total;
  if (flen > framemax)
    return -1;
  for (i = total; i < flen; i++)
    frame[i] = 0;

  e = (struct eth *)frame;
  for (i = 0; i < ETHADDR_LEN; i++) {
    e->dhost[i] = 0;
    e->shost[i] = srcmac[i];
  }
  e->type = htons(ETHTYPE_IP);

  ip = (struct ip *)(frame + ETH_HDR_LEN);
  ip->vhl = 0x45;
  ip->tos = 0;
  ip->len = htons(IP_HDR_MIN_LEN + UDP_HDR_LEN + plen);
  ip->id = htons(ipid);
  ip->off = htons(IP_DF);
  ip->ttl = 64;
  ip->proto = IPPROTO_UDP;
  ip->sum = 0;
  ip->src = htonl(srcip);
  ip->dst = htonl(dstip);
  ip->sum = in_cksum(ip, IP_HDR_MIN_LEN);

  u = (struct udp *)(frame + ETH_HDR_LEN + IP_HDR_MIN_LEN);
  u->sport = htons(sport);
  u->dport = htons(dport);
  u->ulen = htons(UDP_HDR_LEN + plen);
  u->sum = 0;
  u->sum = udp_cksum(srcip, dstip, (uint8 *)u, UDP_HDR_LEN + plen);
  if (u->sum == 0)            // 0 nghia la "khong co checksum" -> gui 0xffff
    u->sum = 0xffff;
  return flen;
}


// Kiem tra khung tin UDP nhan duoc tu tang L2 -> L4
// input
//  - frame: con tro toi khung Ethernet
//  - len: do dai khung ethernet nhan duoc
//  - myip: dia chi ip cua may
//  - out: con tro toi udp_info de luu ket qua boc tach
// output: thanh cong:0, that bai: con lai
int
udp_parse(const uint8 *frame, int len, uint32 myip, struct udp_info *out)
{
  const struct eth *e;
  const struct ip *ip;
  const struct udp *u;
  int hlen, iplen, ulen;
  uint32 dst;

  if (frame == 0 || out == 0 || len < ETH_HDR_LEN + IP_HDR_MIN_LEN)
    return UDP_PARSE_SHORT;
  e = (const struct eth *)frame;
  if (ntohs(e->type) != ETHTYPE_IP)
    return UDP_PARSE_NOTUDP;

  ip = (const struct ip *)(frame + ETH_HDR_LEN);
  hlen = IP_HDRLEN(ip->vhl);
  iplen = ntohs(ip->len);
  if (IP_VERSION(ip->vhl) != 4 || hlen < IP_HDR_MIN_LEN)
    return UDP_PARSE_BADIP;
  // Khung co the dai hon iplen vi phan dem 60 byte, nhung khong duoc ngan hon.
  if (iplen < hlen || ETH_HDR_LEN + iplen > len)
    return UDP_PARSE_SHORT;
  if (in_cksum(ip, hlen) != 0)
    return UDP_PARSE_BADIP;
  if (ip->proto != IPPROTO_UDP)
    return UDP_PARSE_NOTUDP;
  if (ntohs(ip->off) & (IP_MF | IP_OFFMASK))
    return UDP_PARSE_FRAG;          // khong ho tro phan manh
  dst = ntohl(ip->dst);
  if (dst != myip && dst != 0xffffffff)
    return UDP_PARSE_NOTME;

  if (iplen < hlen + UDP_HDR_LEN)
    return UDP_PARSE_SHORT;
  u = (const struct udp *)((const uint8 *)ip + hlen);
  ulen = ntohs(u->ulen);
  if (ulen < UDP_HDR_LEN || ulen > iplen - hlen)
    return UDP_PARSE_SHORT;
  if (u->sum != 0 &&
      udp_cksum(ntohl(ip->src), dst, (const uint8 *)u, ulen) != 0)
    return UDP_PARSE_BADSUM;

  out->src = ntohl(ip->src);
  out->dst = dst;
  out->sport = ntohs(u->sport);
  out->dport = ntohs(u->dport);
  out->data = (const uint8 *)u + UDP_HDR_LEN;
  out->dlen = ulen - UDP_HDR_LEN;
  return 0;
}