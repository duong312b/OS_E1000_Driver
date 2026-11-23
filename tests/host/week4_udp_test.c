// Host unit tests for kernel/udp.c (udp_write / udp_parse).
//   make -C tests/host week4_udp_test && tests/host/week4_udp_test
// Frames are built exactly like sys_sendto does: week4_ip_fill (Ethernet + IPv4)
// + udp_write (UDP header + checksum) on a payload already in place.
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "net.h"
#include "week4_ip.h"

static int nfail, ntotal;
#define CHECK(name, cond) do { ntotal++; \
  if (cond) printf("PASS  %s\n", name); \
  else { printf("FAIL  %s  (line %d)\n", name, __LINE__); nfail++; } } while (0)

#define MYIP   MAKE_IP_ADDR(10, 0, 2, 15)
#define HOSTIP MAKE_IP_ADDR(10, 0, 2, 2)
static const uint8 ME[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
static uint8 F[2048];

static struct ip  *iph(void)  { return (struct ip *)(F + ETH_HDR_LEN); }
static struct udp *udph(void) { return (struct udp *)(F + WEEK4_IP_PAYLOAD_OFF); }
static uint8      *pay(void)  { return F + UDP_FRAME_HDR; }

// Build a whole frame src -> dst like the kernel TX path. Returns frame length or -1.
static int
build(uint32 src, uint32 dst, uint16 sport, uint16 dport, const void *msg, int n)
{
  int ulen;

  memset(F, 0xAA, sizeof(F));                 // garbage: catches fields left unwritten
  if (n > 0)
    memcpy(pay(), msg, n);
  ulen = udp_write((uint8 *)udph(), src, dst, sport, dport, n);
  if (ulen < 0)
    return -1;
  return week4_ip_fill(F, ME, src, dst, IPPROTO_UDP, 7, ulen);
}

// Frame host -> xv6 (what udp_parse sees on RX).
static int build_in(const char *msg, int n) { return build(HOSTIP, MYIP, 5555, 2000, msg, n); }
static void refix_ip_sum(void) { iph()->sum = 0; iph()->sum = in_cksum(iph(), IP_HDR_MIN_LEN); }

// Independent RFC 768 check (does not reuse udp.c): pseudo-header + UDP sums to 0xffff.
static int
udp_sum_ok(uint32 src, uint32 dst, const uint8 *u, int ulen)
{
  uint32 s = (src >> 16) + (src & 0xffff) + (dst >> 16) + (dst & 0xffff) + IPPROTO_UDP + ulen;
  int i;

  for (i = 0; i + 1 < ulen; i += 2)
    s += (u[i] << 8) | u[i + 1];
  if (ulen & 1)
    s += u[ulen - 1] << 8;
  while (s >> 16)
    s = (s & 0xffff) + (s >> 16);
  return s == 0xffff;
}

int
main(void)
{
  struct udp_info u;
  uint8 small[UDP_HDR_LEN + 4];
  int n, i, ok;

  // ---- udp_write: header only ----
  memcpy(small + UDP_HDR_LEN, "abcd", 4);
  CHECK("write_returns_ulen", udp_write(small, MYIP, HOSTIP, 2000, 5555, 4) == UDP_HDR_LEN + 4);
  CHECK("write_payload_untouched", memcmp(small + UDP_HDR_LEN, "abcd", 4) == 0);
  CHECK("write_ports_ulen", ntohs(((struct udp *)small)->sport) == 2000 &&
                            ntohs(((struct udp *)small)->dport) == 5555 &&
                            ntohs(((struct udp *)small)->ulen) == 12);
  CHECK("write_cksum_independent_ref", udp_sum_ok(MYIP, HOSTIP, small, 12));
  CHECK("write_reject_1473", udp_write(F, MYIP, HOSTIP, 1, 1, UDP_MAX_PAYLOAD + 1) < 0);
  CHECK("write_reject_neg", udp_write(F, MYIP, HOSTIP, 1, 1, -1) < 0);
  CHECK("write_reject_null", udp_write(0, MYIP, HOSTIP, 1, 1, 0) < 0);
  ok = 1;                                      // checksum must never be sent as 0 (RFC 768)
  for (i = 0; i < 70000 && ok; i++) {
    small[UDP_HDR_LEN] = i; small[UDP_HDR_LEN + 1] = i >> 8;
    udp_write(small, MYIP, HOSTIP, 2000, i & 0xffff, 4);
    ok = ((struct udp *)small)->sum != 0 && udp_sum_ok(MYIP, HOSTIP, small, 12);
  }
  CHECK("write_cksum_never_zero_70000", ok);

  // ---- whole frame, as sys_sendto builds it ----
  n = build(MYIP, HOSTIP, 2000, 5555, "hi", 2);
  CHECK("frame_pad_to_60", n == ETH_MIN_FRAME);
  CHECK("frame_ethertype_ip", F[12] == 0x08 && F[13] == 0x00);
  CHECK("frame_src_mac", memcmp(F + 6, ME, 6) == 0);
  CHECK("frame_dst_mac_zero_until_arp", F[0] == 0 && F[5] == 0);
  CHECK("frame_ip_len", ntohs(iph()->len) == 20 + 8 + 2);
  CHECK("frame_ip_cksum_ok", in_cksum(iph(), IP_HDR_MIN_LEN) == 0);
  CHECK("frame_ip_fields", iph()->vhl == 0x45 && iph()->ttl == 64 && iph()->proto == IPPROTO_UDP);
  CHECK("frame_udp_cksum_ok", udp_sum_ok(MYIP, HOSTIP, (uint8 *)udph(), 10));
  CHECK("frame_payload_kept", memcmp(pay(), "hi", 2) == 0);
  CHECK("frame_pad_zero", F[44] == 0 && F[59] == 0);
  for (i = 0; i < UDP_MAX_PAYLOAD; i++)
    F[UDP_FRAME_HDR + i] = i * 7;
  n = week4_ip_fill(F, ME, MYIP, HOSTIP, IPPROTO_UDP, 1,
                    udp_write((uint8 *)udph(), MYIP, HOSTIP, 1, 1, UDP_MAX_PAYLOAD));
  CHECK("frame_max_1472", n == UDP_FRAME_HDR + 1472 && n == ETH_MAX_FRAME);
  CHECK("frame_max_cksum_ok", udp_sum_ok(MYIP, HOSTIP, (uint8 *)udph(), 8 + UDP_MAX_PAYLOAD));

  // ---- udp_parse: round trip ----
  n = build_in("hello", 5);
  CHECK("parse_ok", udp_parse(F, n, MYIP, &u) == 0);
  CHECK("parse_fields", u.src == HOSTIP && u.dst == MYIP && u.sport == 5555 &&
                        u.dport == 2000 && u.dlen == 5 && memcmp(u.data, "hello", 5) == 0);
  n = build_in("", 0);
  CHECK("parse_empty", udp_parse(F, n, MYIP, &u) == 0 && u.dlen == 0);
  n = build_in("abc", 3);
  udph()->sum = 0;
  CHECK("parse_no_cksum_ok", udp_parse(F, n, MYIP, &u) == 0 && u.dlen == 3);
  n = build(HOSTIP, 0xffffffff, 68, 2000, "bc", 2);
  CHECK("parse_broadcast_ok", udp_parse(F, n, MYIP, &u) == 0 && u.dlen == 2);
  ok = 1;
  for (i = 0; i <= UDP_MAX_PAYLOAD && ok; i++) {
    n = build(HOSTIP, MYIP, 9, 2000, pay(), i);   // payload = whatever is there, i bytes
    ok = udp_parse(F, n, MYIP, &u) == 0 && u.dlen == i && u.data == pay();
  }
  CHECK("parse_every_size_0_1472", ok);

  // ---- udp_parse: drops ----
  n = build_in("hello", 5);
  pay()[0] ^= 1;
  CHECK("parse_bad_udp_cksum", udp_parse(F, n, MYIP, &u) == UDP_PARSE_BADSUM);
  n = build_in("hello", 5);
  iph()->ttl--;                                     // change header without fixing checksum
  CHECK("parse_bad_ip_cksum", udp_parse(F, n, MYIP, &u) == UDP_PARSE_BADIP);
  n = build_in("hello", 5);
  iph()->dst = htonl(MAKE_IP_ADDR(10, 0, 2, 99)); refix_ip_sum();
  CHECK("parse_not_me", udp_parse(F, n, MYIP, &u) == UDP_PARSE_NOTME);
  n = build_in("hello", 5);
  iph()->off = htons(IP_MF); refix_ip_sum();
  CHECK("parse_fragment_mf", udp_parse(F, n, MYIP, &u) == UDP_PARSE_FRAG);
  n = build_in("hello", 5);
  iph()->off = htons(5); refix_ip_sum();
  CHECK("parse_fragment_offset", udp_parse(F, n, MYIP, &u) == UDP_PARSE_FRAG);
  n = build_in("hello", 5);
  iph()->off = htons(IP_DF); refix_ip_sum();
  CHECK("parse_df_ok", udp_parse(F, n, MYIP, &u) == 0);
  n = build_in("hello", 5);
  iph()->proto = IPPROTO_ICMP; refix_ip_sum();
  CHECK("parse_not_udp", udp_parse(F, n, MYIP, &u) == UDP_PARSE_NOTUDP);
  n = build_in("hello", 5);
  F[12] = 0x08; F[13] = 0x06;                       // ARP EtherType
  CHECK("parse_not_ipv4_ethertype", udp_parse(F, n, MYIP, &u) == UDP_PARSE_NOTUDP);
  n = build_in("hello", 5);
  iph()->vhl = 0x65; refix_ip_sum();
  CHECK("parse_bad_version", udp_parse(F, n, MYIP, &u) == UDP_PARSE_BADIP);
  n = build_in("hello", 5);
  iph()->vhl = 0x44; refix_ip_sum();
  CHECK("parse_bad_ihl", udp_parse(F, n, MYIP, &u) == UDP_PARSE_BADIP);
  n = build_in("hello", 5);
  udph()->ulen = htons(200);                        // ulen beyond the IP payload
  CHECK("parse_ulen_too_big", udp_parse(F, n, MYIP, &u) == UDP_PARSE_SHORT);
  n = build_in("hello", 5);
  udph()->ulen = htons(4);
  CHECK("parse_ulen_too_small", udp_parse(F, n, MYIP, &u) == UDP_PARSE_SHORT);
  n = build_in("hello", 5);
  iph()->len = htons(20 + 4); refix_ip_sum();      // IP too short to hold a UDP header
  CHECK("parse_ip_too_short_for_udp", udp_parse(F, n, MYIP, &u) == UDP_PARSE_SHORT);
  n = build_in("0123456789012345678901234567890123456789", 40);
  CHECK("parse_truncated_frame", udp_parse(F, n - 10, MYIP, &u) == UDP_PARSE_SHORT);
  CHECK("parse_short", udp_parse(F, 20, MYIP, &u) == UDP_PARSE_SHORT);
  CHECK("parse_null_frame", udp_parse(0, 60, MYIP, &u) == UDP_PARSE_SHORT);
  CHECK("parse_null_out", udp_parse(F, 60, MYIP, 0) == UDP_PARSE_SHORT);

  printf("week4_udp_test: %d/%d pass\n", ntotal - nfail, ntotal);
  return nfail ? 1 : 0;
}
