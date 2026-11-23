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

// Ghi header UDP (RFC 768) + checksum. Chi lam tang L4: header Ethernet/IPv4
// do tang IP dung (week4_ip_fill / week4_ip_send), de UDP va ICMP dung chung
// mot duong TX.
// input:
//  - udp: con tro toi dau goi UDP; plen byte payload PHAI nam san o udp + 8
//  - srcip, dstip: IP nguon/dich (host order) - can cho pseudo-header checksum
//  - sport, dport: cong nguon/dich (host order)
//  - plen: do dai payload, 0..UDP_MAX_PAYLOAD
// output: do dai goi UDP (8 + plen) de truyen cho week4_ip_send, -1 neu loi
int
udp_write(uint8 *udp, uint32 srcip, uint32 dstip, uint16 sport, uint16 dport, int plen)
{
  struct udp *u;
  int ulen;

  if (udp == 0 || plen < 0 || plen > UDP_MAX_PAYLOAD)
    return -1;
  ulen = UDP_HDR_LEN + plen;
  u = (struct udp *)udp;
  u->sport = htons(sport);
  u->dport = htons(dport);
  u->ulen = htons(ulen);
  u->sum = 0;
  u->sum = udp_cksum(srcip, dstip, udp, ulen);
  if (u->sum == 0)            // 0 nghia la "khong co checksum" -> gui 0xffff
    u->sum = 0xffff;
  return ulen;
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