// net.h - Khuon header giao thuc va tien ich byte-order / checksum.
// Vai B (Protocol): Ethernet, ARP, IPv4, ICMP (+ UDP header de vai C dung chung).
//
// QUY UOC BAT BIEN (invariant) - ca nhom phai theo:
//  1. Moi truong nhieu byte trong struct header luu o NETWORK ORDER (big-endian),
//     dung nhu tren day. RISC-V la little-endian => doc/ghi phai qua
//     ntohs/ntohl/htons/htonl. Khong so sanh truc tiep voi hang so host-order.
//  2. Cac struct deu __attribute__((packed)). Header IP nam o offset 14 trong khung
//     Ethernet nen truong 32-bit bi lech alignment; KHONG lay dia chi (&) cua mot
//     truong packed roi gan vao con tro uint16*/uint32* (se lech alignment).
//  3. Cac hang so ETHTYPE_*, IPPROTO_*, ARP_OP_* duoi day o HOST order;
//     phai htons() khi ghi vao header.
//  4. Dia chi IPv4 trong header (src/dst/sip/tip) o network order.
//     MAKE_IP_ADDR(a,b,c,d) tra ve gia tri HOST order; htonl() khi ghi vao header.
#ifndef NET_H
#define NET_H

#define NET_PACKED __attribute__((packed))

// ---- Byte order (RISC-V little-endian) ----
static inline uint16 bswap16(uint16 x) { return (uint16)((x << 8) | (x >> 8)); }
static inline uint32 bswap32(uint32 x) {
  return ((x & 0x000000ffU) << 24) | ((x & 0x0000ff00U) << 8) |
         ((x & 0x00ff0000U) >> 8)  | ((x & 0xff000000U) >> 24);
}
#define htons(x) bswap16(x)
#define ntohs(x) bswap16(x)
#define htonl(x) bswap32(x)
#define ntohl(x) bswap32(x)

#define MAKE_IP_ADDR(a, b, c, d) \
  (((uint32)(a) << 24) | ((uint32)(b) << 16) | ((uint32)(c) << 8) | (uint32)(d))

// ---- Ethernet II (14 byte) ----
#define ETHADDR_LEN   6
#define ETH_HDR_LEN   14
#define ETH_MTU       1500            // payload toi da
#define ETH_MAX_FRAME (ETH_HDR_LEN + ETH_MTU)  // 1514, khong tinh FCS
#define ETH_MIN_FRAME 60              // khong tinh FCS; ngan hon phai padding

#define ETHTYPE_IP  0x0800
#define ETHTYPE_ARP 0x0806

struct eth {
  uint8  dhost[ETHADDR_LEN];   // MAC dich
  uint8  shost[ETHADDR_LEN];   // MAC nguon
  uint16 type;                 // EtherType, network order
} NET_PACKED;

// ---- ARP cho Ethernet/IPv4 (28 byte), RFC 826 ----
#define ARP_HDR_LEN    28
#define ARP_HRD_ETHER  1
#define ARP_OP_REQUEST 1
#define ARP_OP_REPLY   2

struct arp {
  uint16 hrd;                  // hardware type = 1 (Ethernet)
  uint16 pro;                  // protocol type = 0x0800 (IPv4)
  uint8  hln;                  // do dai dia chi phan cung = 6
  uint8  pln;                  // do dai dia chi giao thuc = 4
  uint16 op;                   // 1 = request, 2 = reply
  uint8  sha[ETHADDR_LEN];     // sender MAC
  uint32 sip;                  // sender IP (network order)
  uint8  tha[ETHADDR_LEN];     // target MAC (request: 00:..:00)
  uint32 tip;                  // target IP (network order)
} NET_PACKED;

// ---- IPv4 (20 byte khi khong co options), RFC 791 ----
#define IP_HDR_MIN_LEN 20
#define IPPROTO_ICMP   1
#define IPPROTO_UDP    17
#define IP_RF          0x8000    // flags/offset (host order), nhan sau khi ntohs
#define IP_DF          0x4000
#define IP_MF          0x2000
#define IP_OFFMASK     0x1fff

// Truong vhl gom 4 bit version (cao) + 4 bit IHL (thap, don vi 4 byte).
// Khong dung bit-field vi thu tu bit phu thuoc compiler.
#define IP_VERSION(vhl) ((vhl) >> 4)
#define IP_IHL(vhl)     ((vhl) & 0x0f)
#define IP_HDRLEN(vhl)  (IP_IHL(vhl) * 4)

struct ip {
  uint8  vhl;                  // version<<4 | ihl ; goi IPv4 khong options = 0x45
  uint8  tos;
  uint16 len;                  // total length (header + data)
  uint16 id;
  uint16 off;                  // flags (3 bit) + fragment offset (13 bit)
  uint8  ttl;
  uint8  proto;
  uint16 sum;                  // header checksum
  uint32 src;
  uint32 dst;
} NET_PACKED;

// ---- ICMP echo (8 byte header; du lieu echo nam ngay sau), RFC 792 ----
#define ICMP_HDR_LEN        8
#define ICMP_TYPE_ECHOREPLY 0
#define ICMP_TYPE_ECHO      8

struct icmp {
  uint8  type;
  uint8  code;
  uint16 sum;                  // checksum phu ca header + du lieu
  uint16 id;                   // identifier
  uint16 seq;                  // sequence number
} NET_PACKED;

// ---- UDP (8 byte), RFC 768 - dung chung voi vai C ----
#define UDP_HDR_LEN 8
struct udp {
  uint16 sport;
  uint16 dport;
  uint16 ulen;                 // header + data
  uint16 sum;                  // 0 = khong dung checksum (IPv4)
} NET_PACKED;

// ---- Checksum Internet (RFC 1071) ----
// in_cksum(): tra ve gia tri CHUAN BI SAN de gan thang vao truong sum cua header
//   (da o network order):   ip->sum = 0; ip->sum = in_cksum(ip, hlen);
// Kiem tra goi den: tinh tren ca header gom ca truong sum; hop le <=> ket qua == 0.
uint16 in_cksum(const void *buf, int len);

// Dang tung phan, de tinh checksum nhieu vung nho (vi du UDP pseudo-header + UDP).
//   uint32 s = cksum_partial(0, &pseudo, sizeof(pseudo));
//   s = cksum_partial(s, udp_hdr_va_data, udplen);
//   udp->sum = cksum_finish(s);
uint32 cksum_partial(uint32 sum, const void *buf, int len);
uint16 cksum_finish(uint32 sum);   // gap carry, bu 1, tra ve network order

#endif
