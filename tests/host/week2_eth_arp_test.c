#include <stdio.h>
#include <string.h>
#include "types.h"
#include "net.h"
#include "vectors.h"

static int nfail, ntotal;
#define CHECK(name, cond) do { ntotal++; \
  if (cond) printf("PASS  %s\n", name); \
  else { printf("FAIL  %s  (dong %d)\n", name, __LINE__); nfail++; } } while (0)

static const uint8 ME[6]    = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
static const uint8 OTHER[6] = {0x52, 0x54, 0x00, 0x99, 0x99, 0x99};
static const uint8 BCAST[6] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
static const uint8 MCAST[6] = {0x01, 0x00, 0x5e, 0x00, 0x00, 0xfb};

static void
mkframe(uint8 *f, int len, const uint8 *dst, unsigned type)
{
  memset(f, 0, len);
  memcpy(f, dst, 6);
  f[6] = 0x52; f[7] = 0x54; f[8] = 0x00; f[9] = 0xaa; f[10] = 0xbb; f[11] = 0xcc;
  f[12] = type >> 8;
  f[13] = type & 0xff;
}

static int
classify(int len, const uint8 *dst, unsigned type)
{
  uint8 f[1514];
  mkframe(f, len < 14 ? 14 : len, dst, type);
  return week2_eth_classify(f, len, ME);
}

int main(void) {
  CHECK("khung 1: 10 byte -> DROP_SHORT", ({ uint8 f[10] = {0}; week2_eth_classify(f, 10, ME) == WEEK2_ETH_DROP_SHORT; }));
  CHECK("khung 2: unicast cua ta, ARP -> TO_ARP", classify(60, ME, 0x0806) == WEEK2_ETH_TO_ARP);
  CHECK("khung 3: broadcast, ARP -> TO_ARP", classify(60, BCAST, 0x0806) == WEEK2_ETH_TO_ARP);
  CHECK("khung 4: unicast cua ta, IPv4 98 byte -> TO_IP", classify(98, ME, 0x0800) == WEEK2_ETH_TO_IP);
  CHECK("khung 5: unicast may khac, IPv4 -> NOT_FOR_US", classify(60, OTHER, 0x0800) == WEEK2_ETH_DROP_NOT_FOR_US);
  CHECK("khung 6: IPv6 0x86DD -> UNSUPPORTED", classify(74, ME, 0x86dd) == WEEK2_ETH_DROP_UNSUPPORTED);
  CHECK("khung 7: multicast, IPv4 -> NOT_FOR_US", classify(60, MCAST, 0x0800) == WEEK2_ETH_DROP_NOT_FOR_US);
  CHECK("khung 8: type 0x0100 (do dai 802.3) -> UNSUPPORTED", classify(60, ME, 0x0100) == WEEK2_ETH_DROP_UNSUPPORTED);

  CHECK("do dai 13 -> DROP_SHORT", ({ uint8 f[14] = {0}; week2_eth_classify(f, 13, ME) == WEEK2_ETH_DROP_SHORT; }));
  CHECK("do dai 0 -> DROP_SHORT", ({ uint8 f[14] = {0}; week2_eth_classify(f, 0, ME) == WEEK2_ETH_DROP_SHORT; }));
  CHECK("do dai am -> DROP_SHORT", ({ uint8 f[14] = {0}; week2_eth_classify(f, -5, ME) == WEEK2_ETH_DROP_SHORT; }));
  CHECK("buf NULL -> DROP_SHORT", week2_eth_classify(0, 60, ME) == WEEK2_ETH_DROP_SHORT);
  CHECK("ARP 14 byte (chi co header Ethernet) -> DROP_SHORT", classify(14, ME, 0x0806) == WEEK2_ETH_DROP_SHORT);
  CHECK("ARP 41 byte -> DROP_SHORT", classify(41, ME, 0x0806) == WEEK2_ETH_DROP_SHORT);
  CHECK("ARP 42 byte -> TO_ARP", classify(42, ME, 0x0806) == WEEK2_ETH_TO_ARP);
  CHECK("IPv4 33 byte -> DROP_SHORT", classify(33, ME, 0x0800) == WEEK2_ETH_DROP_SHORT);
  CHECK("IPv4 34 byte -> TO_IP", classify(34, ME, 0x0800) == WEEK2_ETH_TO_IP);

  CHECK("broadcast, IPv4 -> TO_IP", classify(60, BCAST, 0x0800) == WEEK2_ETH_TO_IP);
  { uint8 near[6]; memcpy(near, ME, 6); near[5] ^= 1;
    CHECK("MAC chi khac 1 bit o byte cuoi -> NOT_FOR_US", classify(60, near, 0x0806) == WEEK2_ETH_DROP_NOT_FOR_US); }
  { static const uint8 m6[6] = {0x33, 0x33, 0x00, 0x00, 0x00, 0x01};
    CHECK("thu tu: MAC kiem tra truoc type (multicast IPv6 -> NOT_FOR_US)", classify(74, m6, 0x86dd) == WEEK2_ETH_DROP_NOT_FOR_US); }
  { uint8 half[6]; memset(half, 0xff, 6); half[5] = 0xfe;
    CHECK("gan broadcast (ff:..:fe) -> NOT_FOR_US", classify(60, half, 0x0806) == WEEK2_ETH_DROP_NOT_FOR_US); }

  CHECK("ARP_REQ_FRAME (42 byte, broadcast) -> TO_ARP", week2_eth_classify(ARP_REQ_FRAME, 42, ME) == WEEK2_ETH_TO_ARP);
  CHECK("PING_FRAME (dich la host 52:55:0a:00:02:02) -> NOT_FOR_US", week2_eth_classify(PING_FRAME, 50, ME) == WEEK2_ETH_DROP_NOT_FOR_US);
  { uint8 f[50]; memcpy(f, PING_FRAME, 50); memcpy(f, ME, 6);
    CHECK("PING_FRAME doi MAC dich thanh cua ta -> TO_IP", week2_eth_classify(f, 50, ME) == WEEK2_ETH_TO_IP); }

  { uint32 a0, i0, d0; uint8 f[60]; int v;
    a0 = week2_rx_arp; i0 = week2_rx_ip; d0 = week2_rx_drop;
    mkframe(f, 60, BCAST, 0x0806);
    v = net_rx(f, 60);
    CHECK("net_rx ARP: tra TO_ARP", v == WEEK2_ETH_TO_ARP);
    CHECK("net_rx ARP: chi rx_arp tang 1", week2_rx_arp == a0 + 1 && week2_rx_ip == i0 && week2_rx_drop == d0);
    mkframe(f, 60, ME, 0x0800);
    v = net_rx(f, 60);
    CHECK("net_rx IPv4: tra TO_IP", v == WEEK2_ETH_TO_IP);
    CHECK("net_rx IPv4: chi rx_ip tang 1", week2_rx_arp == a0 + 1 && week2_rx_ip == i0 + 1 && week2_rx_drop == d0);
    mkframe(f, 60, OTHER, 0x0800);
    net_rx(f, 60);
    net_rx(f, 5);
    CHECK("net_rx: 2 goi bi bo -> rx_drop tang 2", week2_rx_drop == d0 + 2 && week2_rx_arp == a0 + 1 && week2_rx_ip == i0 + 1); }

  { uint8 f[60]; int n, i, zero;
    memset(f, 0xAA, sizeof f);
    n = week2_arp_build_request(f, 60, ME, MAKE_IP_ADDR(10, 0, 2, 15), MAKE_IP_ADDR(10, 0, 2, 2));
    CHECK("build: tra ve 60", n == 60);
    CHECK("build: 42 byte dau trung khung mau sinh bang Python", memcmp(f, ARP_REQ_FRAME, 42) == 0);
    zero = 1; for (i = 42; i < 60; i++) if (f[i] != 0) zero = 0;
    CHECK("build: 18 byte dem deu bang 0 (du buffer ban dau bang 0xAA)", zero);
    CHECK("build: khung tu dung duoc phan loai TO_ARP", week2_eth_classify(f, n, ME) == WEEK2_ETH_TO_ARP); }
  { uint8 f[64]; int n;
    memset(f, 0xEE, sizeof f);
    n = week2_arp_build_request(f, 64, ME, MAKE_IP_ADDR(10, 0, 2, 15), MAKE_IP_ADDR(10, 0, 2, 2));
    CHECK("build: khong ghi qua byte thu 60 (canary)", n == 60 && f[60] == 0xEE && f[61] == 0xEE && f[62] == 0xEE && f[63] == 0xEE); }
  { uint8 f[64];
    CHECK("build: buflen 59 -> -1", week2_arp_build_request(f, 59, ME, 1, 2) == -1);
    CHECK("build: buflen 60 -> 60", week2_arp_build_request(f, 60, ME, 1, 2) == 60);
    CHECK("build: buf NULL -> -1", week2_arp_build_request(0, 60, ME, 1, 2) == -1);
    CHECK("build: srcmac NULL -> -1", week2_arp_build_request(f, 60, 0, 1, 2) == -1); }
  { uint8 f[60];
    week2_arp_build_request(f, 60, ME, MAKE_IP_ADDR(192, 168, 1, 7), MAKE_IP_ADDR(192, 168, 1, 1));
    CHECK("build: doi IP -> sip/tip dung thu tu byte (c0 a8 01 07 / c0 a8 01 01)",
          f[28] == 0xc0 && f[29] == 0xa8 && f[30] == 0x01 && f[31] == 0x07 &&
          f[38] == 0xc0 && f[39] == 0xa8 && f[40] == 0x01 && f[41] == 0x01); }

  printf("\n== %d/%d PASS, %d FAIL ==\n", ntotal - nfail, ntotal, nfail);
  return nfail ? 1 : 0;
}
