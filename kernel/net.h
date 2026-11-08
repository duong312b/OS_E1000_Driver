#ifndef NET_H
#define NET_H

#define NET_PACKED __attribute__((packed))

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

#define ETHADDR_LEN   6
#define ETH_HDR_LEN   14
#define ETH_MTU       1500
#define ETH_MAX_FRAME (ETH_HDR_LEN + ETH_MTU)
#define ETH_MIN_FRAME 60

#define ETHTYPE_IP  0x0800
#define ETHTYPE_ARP 0x0806

// Header fields are big-endian (network order): use htons/htonl/ntohs/ntohl.
struct eth {
  uint8  dhost[ETHADDR_LEN];
  uint8  shost[ETHADDR_LEN];
  uint16 type;
} NET_PACKED;

#define ARP_HDR_LEN    28
#define ARP_HRD_ETHER  1
#define ARP_OP_REQUEST 1
#define ARP_OP_REPLY   2

struct arp {
  uint16 hrd;
  uint16 pro;
  uint8  hln;
  uint8  pln;
  uint16 op;
  uint8  sha[ETHADDR_LEN];
  uint32 sip;
  uint8  tha[ETHADDR_LEN];
  uint32 tip;
} NET_PACKED;

#define IP_HDR_MIN_LEN 20
#define IPPROTO_ICMP   1
#define IPPROTO_UDP    17
#define IP_RF          0x8000
#define IP_DF          0x4000
#define IP_MF          0x2000
#define IP_OFFMASK     0x1fff

#define IP_VERSION(vhl) ((vhl) >> 4)
#define IP_IHL(vhl)     ((vhl) & 0x0f)
#define IP_HDRLEN(vhl)  (IP_IHL(vhl) * 4)

struct ip {
  uint8  vhl;
  uint8  tos;
  uint16 len;
  uint16 id;
  uint16 off;
  uint8  ttl;
  uint8  proto;
  uint16 sum;
  uint32 src;
  uint32 dst;
} NET_PACKED;

#define ICMP_HDR_LEN        8
#define ICMP_TYPE_ECHOREPLY 0
#define ICMP_TYPE_ECHO      8

struct icmp {
  uint8  type;
  uint8  code;
  uint16 sum;
  uint16 id;
  uint16 seq;
} NET_PACKED;

#define UDP_HDR_LEN 8
struct udp {
  uint16 sport;
  uint16 dport;
  uint16 ulen;
  uint16 sum;
} NET_PACKED;

uint16 in_cksum(const void *buf, int len);

uint32 cksum_partial(uint32 sum, const void *buf, int len);
uint16 cksum_finish(uint32 sum);

#define WEEK2_ETH_DROP_SHORT        0
#define WEEK2_ETH_DROP_NOT_FOR_US   1
#define WEEK2_ETH_DROP_UNSUPPORTED  2
#define WEEK2_ETH_TO_ARP            3
#define WEEK2_ETH_TO_IP             4

int week2_eth_classify(const uint8 *buf, int len, const uint8 *mymac);

// net_rx only borrows buf and may run in interrupt context: it must not sleep.
int net_rx(const uint8 *buf, int len);

int week2_arp_build_request(uint8 *buf, int buflen, const uint8 *srcmac,
                            uint32 srcip, uint32 dstip);

extern uint8  week2_my_mac[ETHADDR_LEN];
extern uint32 week2_my_ip;

extern uint32 week2_rx_arp;
extern uint32 week2_rx_ip;
extern uint32 week2_rx_drop;

// week2_net_tx takes ownership of buf (from kalloc) and frees it.
int week2_net_tx(uint8 *buf, int len);
int week2_arp_send_request(uint32 dstip);

#define WEEK3_ARP_ENTRIES    16
#define WEEK3_ARP_QUEUE      2
#define WEEK3_ARP_TTL        600
#define WEEK3_ARP_RETRY      10
#define WEEK3_ARP_MAX_TRIES  3

#define WEEK3_ARP_FREE        0
#define WEEK3_ARP_INCOMPLETE  1
#define WEEK3_ARP_VALID       2

#define WEEK3_ARP_HIT   0
#define WEEK3_ARP_WAIT  1
#define WEEK3_ARP_MISS  2

struct week3_arp_entry {
  uint8  state;
  uint8  tries;
  uint8  nq;
  uint8  mac[ETHADDR_LEN];
  uint32 ip;
  uint32 stamp;
  uint32 last_req;
  uint8 *q[WEEK3_ARP_QUEUE];
  int    qlen[WEEK3_ARP_QUEUE];
};

// Not thread-safe: the kernel layer serializes access with week3_arp_lock.
struct week3_arp_cache {
  struct week3_arp_entry e[WEEK3_ARP_ENTRIES];
};

struct week3_arp_pkts {
  int    n;
  uint8 *buf[WEEK3_ARP_QUEUE];
  int    len[WEEK3_ARP_QUEUE];
};

struct week3_arp_timer_out {
  int    nreq;
  uint32 req_ip[WEEK3_ARP_ENTRIES];
  int    ndrop;
  uint8 *drop_buf[WEEK3_ARP_ENTRIES * WEEK3_ARP_QUEUE];
  int    drop_len[WEEK3_ARP_ENTRIES * WEEK3_ARP_QUEUE];
};

void week3_arp_cache_init(struct week3_arp_cache *c);

int  week3_arp_lookup(struct week3_arp_cache *c, uint32 ip, uint32 now, uint8 *mac);

int  week3_arp_learn(struct week3_arp_cache *c, uint32 ip, const uint8 *mac, uint32 now,
                     struct week3_arp_pkts *send, struct week3_arp_pkts *drop);

int  week3_arp_begin(struct week3_arp_cache *c, uint32 ip, uint32 now, struct week3_arp_pkts *drop);

// Queued frames are complete Ethernet frames from kalloc; the cache owns them until
// they are handed back through a week3_arp_pkts list.
int  week3_arp_enqueue(struct week3_arp_cache *c, uint32 ip, uint8 *buf, int len);

void week3_arp_timer(struct week3_arp_cache *c, uint32 now, struct week3_arp_timer_out *out);

int  week3_arp_process(struct week3_arp_cache *c, const uint8 *frame, int len,
                       const uint8 *mymac, uint32 myip, uint32 now,
                       uint8 *reply, int replymax,
                       struct week3_arp_pkts *send, struct week3_arp_pkts *drop);

extern void (*week3_arp_hook)(const uint8 *buf, int len);

void week3_arp_init(void);
void week3_arp_rx(const uint8 *buf, int len);
int  week3_arp_send(uint32 ip, uint8 *frame, int len);
void week3_arp_tick(void);
void week3_arp_selftest(void);

#endif
