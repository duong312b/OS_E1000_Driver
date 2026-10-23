// Test host cho kernel/net.h + kernel/net.c (chay bang gcc tren may phat trien).
// Build & chay:  make -C tests/host   (hoac xem Makefile ben canh)
// Moi case tu kiem tra va in PASS/FAIL; thoat != 0 neu co case FAIL.
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "net.h"
#include "vectors.h"     // sinh boi gen_vectors.py (checksum tinh doc lap)

static int nfail, ntotal;
#define CHECK(name, cond) do { ntotal++; \
  if (cond) printf("PASS  %s\n", name); \
  else { printf("FAIL  %s  (dong %d)\n", name, __LINE__); nfail++; } } while (0)

// Dua gia tri uint16 (network order trong bo nho) ve mang byte de so sanh doc lap endian.
static int cksum_is(uint16 got, unsigned hi, unsigned lo) {
  unsigned char b[2]; memcpy(b, &got, 2);
  return b[0] == hi && b[1] == lo;
}

int main(void) {
  // ---- Kich thuoc struct (packed, khong padding) ----
  CHECK("sizeof(struct eth)  == 14", sizeof(struct eth)  == 14);
  CHECK("sizeof(struct arp)  == 28", sizeof(struct arp)  == 28);
  CHECK("sizeof(struct ip)   == 20", sizeof(struct ip)   == 20);
  CHECK("sizeof(struct icmp) == 8",  sizeof(struct icmp) == 8);
  CHECK("sizeof(struct udp)  == 8",  sizeof(struct udp)  == 8);

  // ---- Byte order ----
  CHECK("htons(0x0800) -> bytes 08 00", ({ uint16 v = htons(0x0800); unsigned char *p=(unsigned char*)&v; p[0]==0x08 && p[1]==0x00; }));
  CHECK("ntohs(htons(x)) == x", ntohs(htons(0x1234)) == 0x1234);
  CHECK("htonl -> bytes 0a 00 02 0f", ({ uint32 v = htonl(MAKE_IP_ADDR(10,0,2,15)); unsigned char *p=(unsigned char*)&v; p[0]==10&&p[1]==0&&p[2]==2&&p[3]==15; }));

  // ---- Checksum: vector da biet ----
  { unsigned char d[] = {0x00,0x01,0xf2,0x03,0xf4,0xf5,0xf6,0xf7};   // RFC 1071 s.3
    CHECK("RFC1071 example -> 0x220d", cksum_is(in_cksum(d, 8), 0x22, 0x0d)); }
  { unsigned char h[] = {0x45,0x00,0x00,0x73,0x00,0x00,0x40,0x00,0x40,0x11,0x00,0x00,
                         0xc0,0xa8,0x00,0x01,0xc0,0xa8,0x00,0xc7};   // vi du IP header pho bien
    CHECK("IP header example -> 0xb861", cksum_is(in_cksum(h, 20), 0xb8, 0x61));
    h[10] = 0xb8; h[11] = 0x61;
    CHECK("IP header + sum dung -> verify == 0", in_cksum(h, 20) == 0); }

  // ---- Checksum: bien ----
  CHECK("len = 0 -> 0xffff", cksum_is(in_cksum("", 0), 0xff, 0xff));
  { unsigned char o[] = {0xab};   // le: 0xab00 -> ~ = 0x54ff
    CHECK("len = 1 (le) -> 0x54ff", cksum_is(in_cksum(o, 1), 0x54, 0xff)); }
  { unsigned char o[] = {0x12,0x34,0x56};   // 0x1234 + 0x5600 = 0x6834 -> ~ = 0x97cb
    CHECK("len = 3 (le) -> 0x97cb", cksum_is(in_cksum(o, 3), 0x97, 0xcb)); }
  { unsigned char z[1500]; memset(z, 0xff, sizeof z);   // nhieu carry
    uint16 c = in_cksum(z, sizeof z);
    unsigned char zz[1502]; memcpy(zz, z, 1500); memcpy(zz+1500, &c, 2);
    CHECK("1500 byte 0xff, gan sum roi verify == 0", in_cksum(zz, 1502) == 0); }
  { unsigned char b[40]; for (int i=0;i<40;i++) b[i]=i*7+3;
    uint32 s = cksum_partial(0, b, 16); s = cksum_partial(s, b+16, 24);
    CHECK("cksum_partial noi 2 vung (chan) == in_cksum 1 lan", cksum_finish(s) == in_cksum(b, 40)); }

  // ---- Parse khung PING (sinh doc lap bang Python) ----
  { const struct eth *e = (const struct eth *)PING_FRAME;
    const struct ip  *i = (const struct ip  *)(PING_FRAME + ETH_HDR_LEN);
    const struct icmp *c = (const struct icmp *)(PING_FRAME + ETH_HDR_LEN + IP_HDR_MIN_LEN);
    CHECK("PING: ethertype == IP", ntohs(e->type) == ETHTYPE_IP);
    CHECK("PING: version 4, IHL 5", IP_VERSION(i->vhl) == 4 && IP_HDRLEN(i->vhl) == 20);
    CHECK("PING: total length = 36", ntohs(i->len) == 36);
    CHECK("PING: DF set, offset 0, khong phan manh", (ntohs(i->off) & IP_DF) && !(ntohs(i->off) & (IP_MF|IP_OFFMASK)));
    CHECK("PING: ttl 64, proto ICMP", i->ttl == 64 && i->proto == IPPROTO_ICMP);
    CHECK("PING: src 10.0.2.15 / dst 10.0.2.2", ntohl(i->src) == MAKE_IP_ADDR(10,0,2,15) && ntohl(i->dst) == MAKE_IP_ADDR(10,0,2,2));
    CHECK("PING: IP checksum hop le (verify == 0)", in_cksum(i, 20) == 0);
    CHECK("PING: ICMP type 8 code 0 id 1 seq 1", c->type == ICMP_TYPE_ECHO && c->code == 0 && ntohs(c->id) == 1 && ntohs(c->seq) == 1);
    CHECK("PING: ICMP checksum hop le (ca payload)", in_cksum(c, ntohs(i->len) - 20) == 0);
    // Tu xay lai goi echo-reply tu goi request: doi type, tinh lai checksum, so voi cach tinh doc lap
    unsigned char rep[50]; memcpy(rep, PING_FRAME, 50);
    struct icmp *rc = (struct icmp *)(rep + 34);
    rc->type = ICMP_TYPE_ECHOREPLY; rc->sum = 0; rc->sum = in_cksum(rc, 16);
    CHECK("PING: echo-reply tu dung lai checksum hop le", in_cksum(rc, 16) == 0 && rc->type == 0);
    // Gioi han: sua 1 bit -> phai phat hien loi
    unsigned char bad[50]; memcpy(bad, PING_FRAME, 50); bad[40] ^= 0x01;
    CHECK("PING: lat 1 bit payload -> checksum phat hien", in_cksum(bad + 34, 16) != 0);
  }

  // ---- Parse khung ARP request ----
  { const struct eth *e = (const struct eth *)ARP_REQ_FRAME;
    const struct arp *a = (const struct arp *)(ARP_REQ_FRAME + ETH_HDR_LEN);
    static const unsigned char bc[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
    CHECK("ARP: dest broadcast, ethertype ARP", !memcmp(e->dhost, bc, 6) && ntohs(e->type) == ETHTYPE_ARP);
    CHECK("ARP: hrd=1 pro=0x0800 hln=6 pln=4", ntohs(a->hrd) == ARP_HRD_ETHER && ntohs(a->pro) == ETHTYPE_IP && a->hln == 6 && a->pln == 4);
    CHECK("ARP: op == REQUEST", ntohs(a->op) == ARP_OP_REQUEST);
    CHECK("ARP: sip 10.0.2.15, tip 10.0.2.2", ntohl(a->sip) == MAKE_IP_ADDR(10,0,2,15) && ntohl(a->tip) == MAKE_IP_ADDR(10,0,2,2));
    CHECK("ARP: tha toan 0 trong request", ({ static const unsigned char z[6]={0}; !memcmp(a->tha, z, 6); }));
    CHECK("ARP: tong khung = 42 byte (can pad len 60 khi gui)", sizeof ARP_REQ_FRAME == ETH_HDR_LEN + ARP_HDR_LEN);
  }

  printf("\n== %d/%d PASS, %d FAIL ==\n", ntotal - nfail, ntotal, nfail);
  return nfail ? 1 : 0;
}
