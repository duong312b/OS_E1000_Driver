// Host unit tests for kernel/week4_ip.c. Build (from repo root):
//   gcc -Wall -Werror -Ikernel -o /tmp/week4_ip_test tests/host/week4_ip_test.c kernel/net.c kernel/week4_ip.c
//   /tmp/week4_ip_test
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "net.h"
#include "week4_ip.h"

static int fails, total;
#define CHECK(name, cond) do { total++; if (cond) printf("PASS %s\n", name); \
                               else { printf("FAIL %s (line %d)\n", name, __LINE__); fails++; } } while (0)

static const uint8 mymac[6]   = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
static const uint8 peermac[6] = {0x52, 0x55, 0x0a, 0x00, 0x02, 0x02};
#define MYIP   MAKE_IP_ADDR(10, 0, 2, 15)
#define PEERIP MAKE_IP_ADDR(10, 0, 2, 2)

// Independent RFC 1071 reference (does not use in_cksum): returns 1 if the sum verifies.
static int
ref_valid(const uint8 *p, int n)
{
  uint32 s = 0;
  int i;

  for (i = 0; i + 1 < n; i += 2)
    s += (p[i] << 8) | p[i + 1];
  if (n & 1)
    s += p[n - 1] << 8;
  while (s >> 16)
    s = (s & 0xffff) + (s >> 16);
  return s == 0xffff;
}

// Echo request peer -> me, L2-addressed to me. Returns frame length.
static int
mk_req(uint8 *f, int datalen, uint16 id, uint16 seq)
{
  int n, m;

  memset(f, 0xAA, 2048);                    // dirty buffer: catches missing initialisation
  n = week4_icmp_write_echo(f + WEEK4_IP_PAYLOAD_OFF, 2000, id, seq, datalen);
  m = week4_ip_fill(f, peermac, PEERIP, MYIP, IPPROTO_ICMP, 7, n);
  memcpy(f, mymac, 6);
  return m;
}

static void
fix_ip_sum(uint8 *f)
{
  struct ip *ip = (struct ip *)(f + ETH_HDR_LEN);
  int hl = IP_HDRLEN(ip->vhl);

  ip->sum = 0;
  ip->sum = in_cksum(ip, hl);
}

static int
parse(uint8 *f, int len, struct week4_ip_info *ip)
{
  return week4_ip_parse(f, len, MYIP, ip);
}

int
main(void)
{
  static uint8 f[2048], r[2048];
  struct week4_ip_info ip;
  struct week4_icmp_info ic;
  struct ip *h;
  int n, m, i, ok;

  // ---------- IPv4 parse ----------
  n = mk_req(f, 56, 0x1234, 1);
  CHECK("ip: valid echo request accepted",
        n == 98 && parse(f, n, &ip) == WEEK4_IP_OK && ip.proto == IPPROTO_ICMP &&
        ip.src == PEERIP && ip.dst == MYIP && ip.hdrlen == 20 && ip.paylen == 64 && ip.ttl == 64);
  CHECK("ip: generated header checksum verifies (independent ref)",
        ref_valid(f + ETH_HDR_LEN, 20));

  CHECK("ip: frame shorter than eth+ip", parse(f, 33, &ip) == WEEK4_IP_DROP_SHORT);
  CHECK("ip: NULL buffer", week4_ip_parse(0, 60, MYIP, &ip) == WEEK4_IP_DROP_SHORT);

  mk_req(f, 56, 1, 1); f[12] = 0x08; f[13] = 0x06;
  CHECK("ip: EtherType ARP rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_TYPE);

  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->vhl = 0x65; fix_ip_sum(f);
  CHECK("ip: version 6 rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_VERSION);

  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->vhl = 0x44; fix_ip_sum(f);
  CHECK("ip: IHL < 5 rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_IHL);

  mk_req(f, 56, 1, 1);
  CHECK("ip: total length > frame rejected", parse(f, 90, &ip) == WEEK4_IP_DROP_LEN);

  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->len = htons(10); fix_ip_sum(f);
  CHECK("ip: total length < header rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_LEN);

  mk_req(f, 56, 1, 1); f[14 + 8] ^= 0x01;      // flip a TTL bit, leave checksum stale
  CHECK("ip: bad header checksum rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_CKSUM);

  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->off = htons(IP_MF); fix_ip_sum(f);
  CHECK("ip: More-Fragments rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_FRAG);
  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->off = htons(0x0010); fix_ip_sum(f);
  CHECK("ip: fragment offset != 0 rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_FRAG);
  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->off = htons(IP_DF); fix_ip_sum(f);
  CHECK("ip: DF alone is accepted", parse(f, 98, &ip) == WEEK4_IP_OK);

  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->dst = htonl(MAKE_IP_ADDR(10, 0, 2, 99)); fix_ip_sum(f);
  CHECK("ip: dst != my IP rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_NOT_US);

  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->src = 0; fix_ip_sum(f);
  CHECK("ip: src 0.0.0.0 rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_ADDR);
  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->src = 0xffffffff; fix_ip_sum(f);
  CHECK("ip: src broadcast rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_ADDR);
  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->src = htonl(MAKE_IP_ADDR(224, 0, 0, 1)); fix_ip_sum(f);
  CHECK("ip: src multicast rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_ADDR);

  mk_req(f, 56, 1, 1); h = (struct ip *)(f + 14); h->ttl = 0; fix_ip_sum(f);
  CHECK("ip: ttl 0 rejected", parse(f, 98, &ip) == WEEK4_IP_DROP_TTL);

  // Ethernet padding: 8-byte ICMP in a 60-byte frame -> IP total length is 28, not 46.
  n = mk_req(f, 0, 9, 9);
  CHECK("ip: padded frame uses ip->len, not frame len",
        n == 60 && parse(f, n, &ip) == WEEK4_IP_OK && ip.paylen == 8);

  // IP options (IHL = 6): payload offset moves by 4.
  memset(f, 0, 200);
  memcpy(f, mymac, 6); memcpy(f + 6, peermac, 6); f[12] = 8; f[13] = 0;
  h = (struct ip *)(f + 14);
  h->vhl = 0x46; h->len = htons(24 + 8 + 4); h->ttl = 64; h->proto = IPPROTO_ICMP;
  h->src = htonl(PEERIP); h->dst = htonl(MYIP);
  f[14 + 20] = 1; f[14 + 21] = 1; f[14 + 22] = 1; f[14 + 23] = 0;   // NOP NOP NOP EOL
  fix_ip_sum(f);
  week4_icmp_write_echo(f + 14 + 24, 100, 5, 6, 4);
  CHECK("ip: header with options parsed", parse(f, 14 + 36, &ip) == WEEK4_IP_OK &&
        ip.hdrlen == 24 && ip.paylen == 12 && ip.payload == f + 14 + 24);
  CHECK("icmp: request carried behind IP options",
        week4_icmp_parse(&ip, &ic) == WEEK4_ICMP_ECHO_REQ && ic.id == 5 && ic.seq == 6);
  m = week4_icmp_make_reply(f, &ip, &ic, mymac, r, sizeof(r), 3);
  CHECK("icmp: reply strips IP options (IHL 5, valid checksums)",
        m == 60 && (r[14] >> 4) == 4 && (r[14] & 15) == 5 &&
        ref_valid(r + 14, 20) && ref_valid(r + 34, 12));

  // ---------- ICMP ----------
  n = mk_req(f, 56, 0xbeef, 42);
  parse(f, n, &ip);
  CHECK("icmp: echo request recognised",
        week4_icmp_parse(&ip, &ic) == WEEK4_ICMP_ECHO_REQ && ic.id == 0xbeef && ic.seq == 42 &&
        ic.datalen == 56 && week4_echo_check(ic.data, ic.datalen));
  CHECK("icmp: request checksum verifies (independent ref)", ref_valid(f + 34, 64));

  m = week4_icmp_make_reply(f, &ip, &ic, mymac, r, sizeof(r), 0x4321);
  CHECK("reply: length / L2 addressing",
        m == 98 && memcmp(r, peermac, 6) == 0 && memcmp(r + 6, mymac, 6) == 0 &&
        r[12] == 0x08 && r[13] == 0x00);
  h = (struct ip *)(r + 14);
  CHECK("reply: IP src/dst swapped, ttl 64, proto 1, id",
        ntohl(h->src) == MYIP && ntohl(h->dst) == PEERIP && h->ttl == 64 &&
        h->proto == IPPROTO_ICMP && ntohs(h->id) == 0x4321 && ntohs(h->len) == 84);
  CHECK("reply: IP + ICMP checksums verify (independent ref)",
        ref_valid(r + 14, 20) && ref_valid(r + 34, 64));
  CHECK("reply: type 0 code 0, id/seq/data preserved",
        r[34] == 0 && r[35] == 0 && memcmp(r + 38, f + 38, 60) == 0);

  // reply parses as ECHO_REPLY from the peer's point of view
  ok = week4_ip_parse(r, m, PEERIP, &ip) == WEEK4_IP_OK &&
       week4_icmp_parse(&ip, &ic) == WEEK4_ICMP_ECHO_REPLY && ic.id == 0xbeef && ic.seq == 42;
  CHECK("reply: round trip parses as echo reply", ok);

  // odd data length exercises the odd-byte branch of the checksum
  n = mk_req(f, 33, 1, 2); parse(f, n, &ip); week4_icmp_parse(&ip, &ic);
  m = week4_icmp_make_reply(f, &ip, &ic, mymac, r, sizeof(r), 1);
  CHECK("reply: odd payload length checksum", m == 75 && ref_valid(r + 34, 41));

  // payload sizes 0..1472 all round-trip with valid checksums
  ok = 1;
  for (i = 0; i <= WEEK4_ICMP_MAX_DATA; i += (i < 64 ? 1 : 37)) {
    n = mk_req(f, i, 3, (uint16)i);
    if (parse(f, n, &ip) != WEEK4_IP_OK || week4_icmp_parse(&ip, &ic) != WEEK4_ICMP_ECHO_REQ) { ok = 0; break; }
    m = week4_icmp_make_reply(f, &ip, &ic, mymac, r, sizeof(r), 1);
    if (m < 60 || !ref_valid(r + 14, 20) || !ref_valid(r + 34, 8 + i) || r[34] != 0) { ok = 0; break; }
  }
  CHECK("reply: every payload size 0..1472", ok);
  n = mk_req(f, WEEK4_ICMP_MAX_DATA, 3, 3);
  CHECK("icmp: max data builds a 1514-byte frame", n == 1514);
  CHECK("icmp: data 1473 refused", week4_icmp_write_echo(f, 2000, 1, 1, 1473) == -1);
  CHECK("icmp: negative data refused", week4_icmp_write_echo(f, 2000, 1, 1, -1) == -1);

  n = mk_req(f, 56, 1, 1); parse(f, n, &ip); week4_icmp_parse(&ip, &ic);
  CHECK("reply: buffer too small -> -1", week4_icmp_make_reply(f, &ip, &ic, mymac, r, 90, 1) == -1);

  // bad ICMP checksum
  n = mk_req(f, 56, 1, 1); f[34 + 10] ^= 0xff; parse(f, n, &ip);
  CHECK("icmp: bad checksum rejected", week4_icmp_parse(&ip, &ic) == WEEK4_ICMP_DROP_CKSUM);

  // unsupported type (destination unreachable, type 3) with a valid checksum
  n = mk_req(f, 8, 1, 1); f[34] = 3; f[34 + 2] = 0; f[34 + 3] = 0;
  { struct icmp *hh = (struct icmp *)(f + 34); hh->sum = in_cksum(hh, 16); }
  parse(f, n, &ip);
  CHECK("icmp: type 3 unsupported", week4_icmp_parse(&ip, &ic) == WEEK4_ICMP_DROP_UNSUPPORTED);

  // echo with non-zero code
  n = mk_req(f, 8, 1, 1); f[35] = 1; f[34 + 2] = 0; f[34 + 3] = 0;
  { struct icmp *hh = (struct icmp *)(f + 34); hh->sum = in_cksum(hh, 16); }
  parse(f, n, &ip);
  CHECK("icmp: echo with code != 0 rejected", week4_icmp_parse(&ip, &ic) == WEEK4_ICMP_DROP_UNSUPPORTED);

  // ICMP shorter than its 8-byte header
  n = mk_req(f, 0, 1, 1); h = (struct ip *)(f + 14); h->len = htons(20 + 6); fix_ip_sum(f);
  parse(f, n, &ip);
  CHECK("icmp: payload < 8 bytes rejected", week4_icmp_parse(&ip, &ic) == WEEK4_ICMP_DROP_SHORT);

  // UDP is not ICMP
  n = mk_req(f, 8, 1, 1); h = (struct ip *)(f + 14); h->proto = IPPROTO_UDP; fix_ip_sum(f);
  parse(f, n, &ip);
  CHECK("icmp: non-ICMP protocol not parsed as ICMP",
        ip.proto == IPPROTO_UDP && week4_icmp_parse(&ip, &ic) == WEEK4_ICMP_DROP_SHORT);

  // echo payload pattern
  { uint8 d[16]; week4_echo_fill(d, 16); ok = week4_echo_check(d, 16); d[9] ^= 1;
    CHECK("echo: pattern check detects corruption", ok && !week4_echo_check(d, 16)); }

  // routing
  CHECK("route: on-link destination is its own next hop",
        week4_next_hop(MAKE_IP_ADDR(10, 0, 2, 2), MYIP) == MAKE_IP_ADDR(10, 0, 2, 2));
  CHECK("route: off-link destination goes to the gateway",
        week4_next_hop(MAKE_IP_ADDR(8, 8, 8, 8), MYIP) == WEEK4_GATEWAY);

  // fill argument checks
  CHECK("fill: payload > 1480 refused",
        week4_ip_fill(f, mymac, MYIP, PEERIP, 1, 1, 1481) == -1);
  CHECK("fill: short frame padded to 60 with zeros",
        week4_ip_fill(memset(f, 0xAA, 100), mymac, MYIP, PEERIP, 1, 1, 0) == 60 &&
        f[34] == 0 && f[59] == 0 && f[60] == 0xAA);

  printf("\n%d/%d passed\n", total - fails, total);
  return fails ? 1 : 0;
}
