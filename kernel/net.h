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
#define ETH_MTU       1500            
#define ETH_MAX_FRAME (ETH_HDR_LEN + ETH_MTU)  
#define ETH_MIN_FRAME 60             

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
uint16 in_cksum(const void *buf, int len);

uint32 cksum_partial(uint32 sum, const void *buf, int len);
uint16 cksum_finish(uint32 sum);   // gap carry, bu 1, tra ve network order

// ---- Tuan 2: phan loai khung Ethernet nhan duoc, dung va gui ARP request ----

#define WEEK2_ETH_DROP_SHORT        0  
#define WEEK2_ETH_DROP_NOT_FOR_US   1   
#define WEEK2_ETH_DROP_UNSUPPORTED  2   
#define WEEK2_ETH_TO_ARP            3   
#define WEEK2_ETH_TO_IP             4   


int week2_eth_classify(const uint8 *buf, int len, const uint8 *mymac);
int net_rx(const uint8 *buf, int len);
int week2_arp_build_request(uint8 *buf, int buflen, const uint8 *srcmac,
                            uint32 srcip, uint32 dstip);
extern uint8  week2_my_mac[ETHADDR_LEN];
extern uint32 week2_my_ip;

extern uint32 week2_rx_arp;
extern uint32 week2_rx_ip;
extern uint32 week2_rx_drop;

int week2_net_tx(uint8 *buf, int len);       
int week2_arp_send_request(uint32 dstip);   

#endif
