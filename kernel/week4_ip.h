#ifndef WEEK4_IP_H
#define WEEK4_IP_H

#define WEEK4_IP_PAYLOAD_OFF  (ETH_HDR_LEN + IP_HDR_MIN_LEN)   // 34
#define WEEK4_IP_MAX_PAYLOAD  (ETH_MTU - IP_HDR_MIN_LEN)       // 1480
#define WEEK4_ICMP_MAX_DATA   (WEEK4_IP_MAX_PAYLOAD - ICMP_HDR_LEN) // 1472
#define WEEK4_IP_TTL          64

// Network config. QEMU user-mode (slirp) by default, TAP with -DNET_TAP.
// WEEK4_MYIP is the single source of truth for xv6's own address (net.c: week2_my_ip).
// TAP: host side of tap0 is 192.168.100.1/24, xv6 is 192.168.100.2.
#ifdef NET_TAP
#define WEEK4_MYIP     MAKE_IP_ADDR(192, 168, 100, 2)
#define WEEK4_GATEWAY  MAKE_IP_ADDR(192, 168, 100, 1)
#else
#define WEEK4_MYIP     MAKE_IP_ADDR(10, 0, 2, 15)
#define WEEK4_GATEWAY  MAKE_IP_ADDR(10, 0, 2, 2)
#endif
#define WEEK4_NETMASK  MAKE_IP_ADDR(255, 255, 255, 0)

// ---- IPv4 receive verdicts ----
#define WEEK4_IP_OK            0
#define WEEK4_IP_DROP_SHORT    1   // frame shorter than Ethernet + 20
#define WEEK4_IP_DROP_TYPE     2   // EtherType is not IPv4
#define WEEK4_IP_DROP_VERSION  3   // version != 4
#define WEEK4_IP_DROP_IHL      4   // IHL < 5
#define WEEK4_IP_DROP_LEN      5   // total length inconsistent with frame
#define WEEK4_IP_DROP_CKSUM    6   // header checksum wrong
#define WEEK4_IP_DROP_FRAG     7   // fragment (out of scope)
#define WEEK4_IP_DROP_NOT_US   8   // dst != my IP
#define WEEK4_IP_DROP_ADDR     9   // src is 0 / broadcast / multicast
#define WEEK4_IP_DROP_TTL      10  // ttl == 0

struct week4_ip_info {
  uint32 src, dst;            // host byte order
  uint8  proto, ttl;
  uint16 id;                  // host byte order
  int    hdrlen;              // IP header length in bytes (>= 20)
  int    paylen;              // bytes after the IP header, per ip->len (no Ethernet padding)
  const uint8 *payload;       // points INTO the rx frame: borrowed, copy if you keep it
};

// ---- ICMP receive verdicts ----
#define WEEK4_ICMP_DROP_SHORT        0
#define WEEK4_ICMP_DROP_CKSUM        1
#define WEEK4_ICMP_DROP_UNSUPPORTED  2
#define WEEK4_ICMP_ECHO_REQ          3
#define WEEK4_ICMP_ECHO_REPLY        4

struct week4_icmp_info {
  uint8  type, code;
  uint16 id, seq;             // host byte order
  const uint8 *data;          // echo payload (borrowed from the rx frame)
  int    datalen;
};

// ---- pure functions (no kernel dependency, unit-tested on host) ----
int    week4_ip_parse(const uint8 *frame, int len, uint32 myip, struct week4_ip_info *info);

// Writes Ethernet header (dhost = 0, filled later by ARP) + IPv4 header (valid checksum) and
// zero-pads the tail up to ETH_MIN_FRAME. The paylen payload bytes at frame+34 are NOT touched.
// Returns the frame length to transmit (>= 60), or -1.
int    week4_ip_fill(uint8 *frame, const uint8 *srcmac, uint32 srcip, uint32 dstip,
                     uint8 proto, uint16 id, int paylen);

uint32 week4_next_hop(uint32 dst, uint32 myip);

int    week4_icmp_parse(const struct week4_ip_info *ip, struct week4_icmp_info *ic);
// Builds an echo request (ICMP header + pattern data + checksum) at icmp. Returns ICMP length or -1.
int    week4_icmp_write_echo(uint8 *icmp, int max, uint16 id, uint16 seq, int datalen);
// Builds a complete Ethernet frame holding the echo reply for `frame`. Returns frame length or -1.
int    week4_icmp_make_reply(const uint8 *frame, const struct week4_ip_info *ip,
                             const struct week4_icmp_info *ic, const uint8 *mymac,
                             uint8 *reply, int replymax, uint16 ipid);
void   week4_echo_fill(uint8 *d, int n);
int    week4_echo_check(const uint8 *d, int n);

// ---- statistics (updated with atomics) ----
struct week4_stats {
  uint32 ip_ok, ip_drop_short, ip_drop_hdr, ip_drop_cksum, ip_drop_frag;
  uint32 ip_drop_ttl;         // ttl == 0 (split out of ip_drop_hdr in week 5)
  uint32 ip_drop_notus, ip_drop_addr, ip_unsup_proto;
  uint32 icmp_echo_req, icmp_echo_reply_tx, icmp_drop;
  uint32 ping_tx, ping_rx, ping_timeout, ping_unmatched, tx_nomem;
};
extern struct week4_stats week4_stats;

// ---- kernel layer (week4_ip_kernel.c) ----
extern void (*week4_ip_hook)(const uint8 *buf, int len);     // called by net_rx for IPv4 frames
extern void (*week4_udp_hook)(const uint8 *frame, const struct week4_ip_info *ip);  // role C sets this

void   week4_ip_init(void);
void   week4_ip_rx(const uint8 *buf, int len);
uint8 *week4_ip_alloc(uint8 **payload);                       // zeroed kalloc frame + payload pointer
int    week4_ip_send(uint8 *frame, uint32 dst, uint8 proto, int paylen); // 0 = owned by stack
void   week4_ip_tick(void);
void   week4_ip_selftest(void);
void   week4_ip_dump_stats(void);

#endif
