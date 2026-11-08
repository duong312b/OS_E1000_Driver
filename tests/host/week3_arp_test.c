#include <stdio.h>
#include <string.h>
#include "types.h"
#include "net.h"
#include "vectors.h"

static int nfail, ntotal;
#define CHECK(name, cond) do { ntotal++; \
  if (cond) printf("PASS  %s\n", name); \
  else { printf("FAIL  %s  (dong %d)\n", name, __LINE__); nfail++; } } while (0)

#define IP(a, b, c, d) MAKE_IP_ADDR(a, b, c, d)

static const uint8 ME[6]      = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
static const uint8 HOSTMAC[6] = {0x52, 0x55, 0x0a, 0x00, 0x02, 0x02};
static const uint8 M1[6]      = {0x52, 0x54, 0x00, 0x00, 0x00, 0x01};
static const uint8 M2[6]      = {0x52, 0x54, 0x00, 0x00, 0x00, 0x02};
static const uint8 BCASTMAC[6] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
static const uint8 MCASTMAC[6] = {0x01, 0x00, 0x5e, 0x00, 0x00, 0xfb};
static const uint8 ZERO6[6]   = {0, 0, 0, 0, 0, 0};

#define MYIP   IP(10, 0, 2, 15)
#define HOSTIP IP(10, 0, 2, 2)
#define OTHERIP IP(10, 0, 2, 77)

static struct week3_arp_cache C;
static struct week3_arp_pkts SEND, DROP;
static struct week3_arp_timer_out TOUT;
static uint8 REP[64];
static uint8 B1[64], B2[64], B3[64];

static void
fresh(void)
{
  week3_arp_cache_init(&C);
  memset(B1, 0, sizeof B1); B1[14] = 0xa1;
  memset(B2, 0, sizeof B2); B2[14] = 0xa2;
  memset(B3, 0, sizeof B3); B3[14] = 0xa3;
}

static int
count_state(int st)
{
  int i, n = 0;

  for (i = 0; i < WEEK3_ARP_ENTRIES; i++)
    if (C.e[i].state == st)
      n++;
  return n;
}

static int
look(uint32 ip, uint32 now, uint8 *mac)
{
  return week3_arp_lookup(&C, ip, now, mac);
}

static void
mkarp(uint8 *f, int op, const uint8 *dst, const uint8 *sha, uint32 sip, const uint8 *tha, uint32 tip)
{
  struct eth *e = (struct eth *)f;
  struct arp *a = (struct arp *)(f + ETH_HDR_LEN);

  memset(f, 0, 60);
  memcpy(e->dhost, dst, 6);
  memcpy(e->shost, sha, 6);
  e->type = htons(ETHTYPE_ARP);
  a->hrd = htons(ARP_HRD_ETHER);
  a->pro = htons(ETHTYPE_IP);
  a->hln = 6;
  a->pln = 4;
  a->op = htons(op);
  memcpy(a->sha, sha, 6);
  a->sip = htonl(sip);
  memcpy(a->tha, tha, 6);
  a->tip = htonl(tip);
}

static int
proc(const uint8 *f, int len, uint32 now)
{
  memset(REP, 0xAA, sizeof REP);
  return week3_arp_process(&C, f, len, ME, MYIP, now, REP, sizeof REP, &SEND, &DROP);
}

static int hook_calls, hook_len;
static const uint8 *hook_buf;
static void
fake_hook(const uint8 *buf, int len)
{
  hook_calls++;
  hook_buf = buf;
  hook_len = len;
}

int main(void) {
  uint8 mac[6], req[64], f[64], ipf[64];
  uint32 t;
  int i, n, ok;

  fresh();
  CHECK("cache rong: lookup -> MISS", look(IP(10,0,2,2), 100, mac) == WEEK3_ARP_MISS);
  CHECK("learn moi tra ve 1", week3_arp_learn(&C, IP(10,0,2,2), M1, 100, &SEND, &DROP) == 1);
  CHECK("lookup sau learn -> HIT", look(IP(10,0,2,2), 101, mac) == WEEK3_ARP_HIT);
  CHECK("MAC lay ra dung", memcmp(mac, M1, 6) == 0);
  CHECK("learn lai cung IP tra ve 0 (cap nhat)", week3_arp_learn(&C, IP(10,0,2,2), M2, 150, &SEND, &DROP) == 0);
  look(IP(10,0,2,2), 151, mac);
  CHECK("MAC duoc cap nhat", memcmp(mac, M2, 6) == 0);
  CHECK("IP khac -> MISS", look(IP(10,0,2,3), 151, mac) == WEEK3_ARP_MISS);
  CHECK("learn ip = 0 bi tu choi", week3_arp_learn(&C, 0, M1, 100, &SEND, &DROP) == -1);

  fresh();
  week3_arp_learn(&C, IP(10,0,2,2), M1, 1000, &SEND, &DROP);
  CHECK("TTL: truoc han 1 tick van HIT", look(IP(10,0,2,2), 1000 + WEEK3_ARP_TTL - 1, mac) == WEEK3_ARP_HIT);
  CHECK("TTL: dung han -> MISS", look(IP(10,0,2,2), 1000 + WEEK3_ARP_TTL, mac) == WEEK3_ARP_MISS);
  CHECK("TTL: entry het han duoc giai phong", count_state(WEEK3_ARP_VALID) == 0);
  fresh();
  week3_arp_learn(&C, IP(10,0,2,2), M1, 1000, &SEND, &DROP);
  week3_arp_learn(&C, IP(10,0,2,2), M1, 1500, &SEND, &DROP);
  CHECK("TTL: learn lai lam moi dong ho", look(IP(10,0,2,2), 1000 + WEEK3_ARP_TTL + 10, mac) == WEEK3_ARP_HIT);
  fresh();
  t = 0xfffffff0u;
  week3_arp_learn(&C, IP(10,0,2,2), M1, t, &SEND, &DROP);
  CHECK("tick quay vong: tuoi 26 van HIT", look(IP(10,0,2,2), 0x0000000au, mac) == WEEK3_ARP_HIT);
  CHECK("tick quay vong: het han dung luc", look(IP(10,0,2,2), t + WEEK3_ARP_TTL, mac) == WEEK3_ARP_MISS);

  fresh();
  CHECK("begin tao entry moi -> 1", week3_arp_begin(&C, IP(10,0,2,9), 100, &DROP) == 1);
  CHECK("lookup entry INCOMPLETE -> WAIT", look(IP(10,0,2,9), 101, mac) == WEEK3_ARP_WAIT);
  CHECK("begin lan hai cung IP -> 0 (khong gui lai)", week3_arp_begin(&C, IP(10,0,2,9), 102, &DROP) == 0);
  CHECK("enqueue khung 1 -> 0", week3_arp_enqueue(&C, IP(10,0,2,9), B1, 60) == 0);
  CHECK("enqueue khung 2 -> 0", week3_arp_enqueue(&C, IP(10,0,2,9), B2, 60) == 0);
  CHECK("enqueue khung 3 (hang doi day) -> -1", week3_arp_enqueue(&C, IP(10,0,2,9), B3, 60) == -1);
  CHECK("enqueue cho IP chua co entry -> -2", week3_arp_enqueue(&C, IP(10,0,2,10), B3, 60) == -2);
  CHECK("enqueue khung ngan hon 14 byte -> -3", week3_arp_enqueue(&C, IP(10,0,2,9), B3, 13) == -3);
  CHECK("learn giai phong hang doi", week3_arp_learn(&C, IP(10,0,2,9), M1, 110, &SEND, &DROP) == 0 && SEND.n == 2);
  CHECK("khung duoc tra ve dung thu tu", SEND.buf[0] == B1 && SEND.buf[1] == B2 && SEND.len[0] == 60);
  CHECK("MAC dich duoc dien vao byte 0-5 cua khung", memcmp(B1, M1, 6) == 0 && memcmp(B2, M1, 6) == 0);
  CHECK("sau khi giai phong entry la VALID (HIT)", look(IP(10,0,2,9), 111, mac) == WEEK3_ARP_HIT);
  CHECK("enqueue sau khi da VALID -> -2", week3_arp_enqueue(&C, IP(10,0,2,9), B3, 60) == -2);
  fresh();
  week3_arp_begin(&C, IP(10,0,2,9), 100, &DROP);
  week3_arp_learn(&C, IP(10,0,2,9), M1, 105, &SEND, &DROP);
  CHECK("learn entry INCOMPLETE khong co hang doi -> send.n = 0", SEND.n == 0);

  fresh();
  week3_arp_begin(&C, IP(10,0,2,9), 100, &DROP);
  week3_arp_enqueue(&C, IP(10,0,2,9), B1, 60);
  week3_arp_enqueue(&C, IP(10,0,2,9), B2, 60);
  week3_arp_timer(&C, 100 + WEEK3_ARP_RETRY - 1, &TOUT);
  CHECK("timer: chua den han -> khong lam gi", TOUT.nreq == 0 && TOUT.ndrop == 0);
  week3_arp_timer(&C, 100 + WEEK3_ARP_RETRY, &TOUT);
  CHECK("timer: den han -> gui lai request lan 2", TOUT.nreq == 1 && TOUT.req_ip[0] == IP(10,0,2,9));
  week3_arp_timer(&C, 100 + WEEK3_ARP_RETRY + WEEK3_ARP_RETRY - 1, &TOUT);
  CHECK("timer: vua gui xong thi chua gui lai", TOUT.nreq == 0);
  week3_arp_timer(&C, 100 + 2 * WEEK3_ARP_RETRY, &TOUT);
  CHECK("timer: gui request lan 3", TOUT.nreq == 1);
  week3_arp_timer(&C, 100 + 3 * WEEK3_ARP_RETRY, &TOUT);
  CHECK("timer: het luot thu -> khong gui them", TOUT.nreq == 0);
  CHECK("timer: tra ve 2 khung dang cho de giai phong", TOUT.ndrop == 2 && TOUT.drop_buf[0] == B1 && TOUT.drop_buf[1] == B2);
  CHECK("timer: entry bi go bo (MISS)", look(IP(10,0,2,9), 100 + 3 * WEEK3_ARP_RETRY, mac) == WEEK3_ARP_MISS);
  fresh();
  week3_arp_learn(&C, IP(10,0,2,2), M1, 100, &SEND, &DROP);
  week3_arp_timer(&C, 100 + WEEK3_ARP_TTL - 1, &TOUT);
  CHECK("timer: entry VALID chua het han duoc giu", count_state(WEEK3_ARP_VALID) == 1 && TOUT.nreq == 0);
  week3_arp_timer(&C, 100 + WEEK3_ARP_TTL, &TOUT);
  CHECK("timer: don entry VALID het han", count_state(WEEK3_ARP_VALID) == 0);

  fresh();
  for (i = 0; i < WEEK3_ARP_ENTRIES; i++)
    week3_arp_learn(&C, IP(10,0,3,1 + i), M1, 1000 + i, &SEND, &DROP);
  CHECK("day: du 16 entry VALID", count_state(WEEK3_ARP_VALID) == WEEK3_ARP_ENTRIES);
  CHECK("day: them entry thu 17 tra ve 1", week3_arp_learn(&C, IP(10,0,3,100), M2, 1020, &SEND, &DROP) == 1);
  CHECK("day: entry cu nhat bi duoi", look(IP(10,0,3,1), 1021, mac) == WEEK3_ARP_MISS);
  CHECK("day: entry moi co mat", look(IP(10,0,3,100), 1021, mac) == WEEK3_ARP_HIT && memcmp(mac, M2, 6) == 0);
  CHECK("day: cac entry khac con nguyen", look(IP(10,0,3,2), 1021, mac) == WEEK3_ARP_HIT && look(IP(10,0,3,16), 1021, mac) == WEEK3_ARP_HIT);
  fresh();
  for (i = 0; i < WEEK3_ARP_ENTRIES; i++)
    week3_arp_begin(&C, IP(10,0,4,1 + i), 100 + i, &DROP);
  week3_arp_enqueue(&C, IP(10,0,4,1), B1, 60);
  n = week3_arp_begin(&C, IP(10,0,4,100), 120, &DROP);
  CHECK("day toan INCOMPLETE: begin moi tra ve 1", n == 1);
  CHECK("day toan INCOMPLETE: khung cua entry bi duoi duoc tra ve", DROP.n == 1 && DROP.buf[0] == B1);
  CHECK("day toan INCOMPLETE: entry cu nhat bi duoi", look(IP(10,0,4,1), 121, mac) == WEEK3_ARP_MISS);
  fresh();
  for (i = 0; i < WEEK3_ARP_ENTRIES - 1; i++)
    week3_arp_begin(&C, IP(10,0,5,1 + i), 100 + i, &DROP);
  week3_arp_learn(&C, IP(10,0,5,50), M1, 200, &SEND, &DROP);
  week3_arp_learn(&C, IP(10,0,5,60), M2, 210, &SEND, &DROP);
  CHECK("duoi VALID truoc INCOMPLETE: VALID cu bi duoi", look(IP(10,0,5,50), 211, mac) == WEEK3_ARP_MISS);
  CHECK("duoi VALID truoc INCOMPLETE: INCOMPLETE con nguyen", look(IP(10,0,5,1), 211, mac) == WEEK3_ARP_WAIT);

  fresh();
  week2_arp_build_request(req, 60, HOSTMAC, HOSTIP, MYIP);
  n = proc(req, 60, 500);
  CHECK("request hoi IP cua ta: co tra loi 60 byte", n == 60);
  CHECK("reply: MAC dich la nguoi hoi, MAC nguon la ta", memcmp(REP, HOSTMAC, 6) == 0 && memcmp(REP + 6, ME, 6) == 0);
  CHECK("reply: EtherType ARP", REP[12] == 0x08 && REP[13] == 0x06);
  CHECK("reply: hrd, pro, hln, pln dung", REP[14] == 0 && REP[15] == 1 && REP[16] == 0x08 && REP[17] == 0 && REP[18] == 6 && REP[19] == 4);
  CHECK("reply: op = 2", REP[20] == 0 && REP[21] == 2);
  CHECK("reply: sha = MAC cua ta, sip = IP cua ta", memcmp(REP + 22, ME, 6) == 0 && REP[28] == 10 && REP[29] == 0 && REP[30] == 2 && REP[31] == 15);
  CHECK("reply: tha = MAC nguoi hoi, tip = IP nguoi hoi", memcmp(REP + 32, HOSTMAC, 6) == 0 && REP[38] == 10 && REP[39] == 0 && REP[40] == 2 && REP[41] == 2);
  ok = 1; for (i = 42; i < 60; i++) if (REP[i] != 0) ok = 0;
  CHECK("reply: 18 byte dem bang 0 (du buffer ban dau 0xAA)", ok);
  CHECK("reply: nguoi hoi duoc hoc vao cache", look(HOSTIP, 501, mac) == WEEK3_ARP_HIT && memcmp(mac, HOSTMAC, 6) == 0);
  CHECK("reply: phia nguoi hoi nhan ra la ARP (TO_ARP)", week2_eth_classify(REP, 60, HOSTMAC) == WEEK2_ETH_TO_ARP);

  fresh();
  week2_arp_build_request(req, 60, HOSTMAC, HOSTIP, OTHERIP);
  n = proc(req, 60, 500);
  CHECK("request hoi IP cua may khac: khong tra loi", n == 0);
  CHECK("request hoi IP cua may khac: khong them entry moi", look(HOSTIP, 501, mac) == WEEK3_ARP_MISS);

  fresh();
  week3_arp_learn(&C, HOSTIP, M1, 400, &SEND, &DROP);
  n = proc(req, 60, 500);
  CHECK("da co entry: request cho may khac van khong tra loi", n == 0);
  CHECK("da co entry: MAC duoc cap nhat (merge RFC 826)", look(HOSTIP, 501, mac) == WEEK3_ARP_HIT && memcmp(mac, HOSTMAC, 6) == 0);

  fresh();
  mkarp(f, ARP_OP_REPLY, ME, HOSTMAC, HOSTIP, ME, MYIP);
  n = proc(f, 60, 500);
  CHECK("reply gui cho ta: khong tra loi lai", n == 0);
  CHECK("reply gui cho ta: duoc hoc vao cache", look(HOSTIP, 501, mac) == WEEK3_ARP_HIT);

  fresh();
  week3_arp_begin(&C, HOSTIP, 490, &DROP);
  week3_arp_enqueue(&C, HOSTIP, B1, 60);
  n = proc(f, 60, 500);
  CHECK("reply giai phong hang doi: send.n = 1", n == 0 && SEND.n == 1 && SEND.buf[0] == B1);
  CHECK("reply giai phong hang doi: MAC dich duoc dien", memcmp(B1, HOSTMAC, 6) == 0);
  CHECK("reply giai phong hang doi: entry thanh VALID", look(HOSTIP, 501, mac) == WEEK3_ARP_HIT);

  fresh();
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, MYIP, ZERO6, MYIP);
  n = proc(f, 60, 500);
  CHECK("goi co IP nguon trung IP cua ta: bo qua hoan toan", n == 0 && look(MYIP, 501, mac) == WEEK3_ARP_MISS);

  fresh();
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, HOSTIP, ZERO6, MYIP);
  ((struct arp *)(f + ETH_HDR_LEN))->hrd = htons(6);
  CHECK("hrd khac 1 -> -1", proc(f, 60, 500) == -1);
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, HOSTIP, ZERO6, MYIP);
  ((struct arp *)(f + ETH_HDR_LEN))->pro = htons(0x86dd);
  CHECK("pro khac IPv4 -> -1", proc(f, 60, 500) == -1);
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, HOSTIP, ZERO6, MYIP);
  ((struct arp *)(f + ETH_HDR_LEN))->hln = 8;
  CHECK("hln khac 6 -> -1", proc(f, 60, 500) == -1);
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, HOSTIP, ZERO6, MYIP);
  ((struct arp *)(f + ETH_HDR_LEN))->pln = 16;
  CHECK("pln khac 4 -> -1", proc(f, 60, 500) == -1);
  mkarp(f, 3, BCASTMAC, HOSTMAC, HOSTIP, ZERO6, MYIP);
  CHECK("op khac 1 va 2 -> -1", proc(f, 60, 500) == -1);
  CHECK("khung hong khong de lai entry nao", count_state(WEEK3_ARP_VALID) == 0);
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, HOSTIP, ZERO6, MYIP);
  CHECK("khung 41 byte -> -1", proc(f, 41, 500) == -1);
  CHECK("khung 42 byte hop le -> tra loi", proc(f, 42, 500) == 60);
  fresh();
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, HOSTIP, ZERO6, MYIP);
  f[12] = 0x08; f[13] = 0x00;
  CHECK("EtherType khong phai ARP -> -1", proc(f, 60, 500) == -1);
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, HOSTIP, ZERO6, MYIP);
  CHECK("buffer tra loi 59 byte -> -1", week3_arp_process(&C, f, 60, ME, MYIP, 500, REP, 59, &SEND, &DROP) == -1);

  fresh();
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, BCASTMAC, HOSTIP, ZERO6, MYIP);
  CHECK("MAC nguon la broadcast: khong tra loi, khong hoc", proc(f, 60, 500) == 0 && look(HOSTIP, 501, mac) == WEEK3_ARP_MISS);
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, MCASTMAC, HOSTIP, ZERO6, MYIP);
  CHECK("MAC nguon la multicast: khong tra loi, khong hoc", proc(f, 60, 500) == 0 && look(HOSTIP, 501, mac) == WEEK3_ARP_MISS);
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, ZERO6, HOSTIP, ZERO6, MYIP);
  CHECK("MAC nguon toan 0: khong tra loi, khong hoc", proc(f, 60, 500) == 0 && look(HOSTIP, 501, mac) == WEEK3_ARP_MISS);
  mkarp(f, ARP_OP_REQUEST, BCASTMAC, HOSTMAC, 0, ZERO6, MYIP);
  CHECK("ARP probe (IP nguon = 0) hoi IP cua ta: co tra loi", proc(f, 60, 500) == 60);
  CHECK("ARP probe: khong hoc IP 0", count_state(WEEK3_ARP_VALID) == 0);

  week2_arp_build_request(req, 60, HOSTMAC, HOSTIP, MYIP);
  memset(ipf, 0, sizeof ipf); memcpy(ipf, ME, 6); ipf[12] = 0x08; ipf[13] = 0x00;
  week3_arp_hook = fake_hook;
  hook_calls = 0;
  n = net_rx(req, 60);
  CHECK("net_rx: khung ARP -> hook duoc goi 1 lan", n == WEEK2_ETH_TO_ARP && hook_calls == 1);
  CHECK("net_rx: hook nhan dung con tro va do dai", hook_buf == req && hook_len == 60);
  net_rx(ipf, 60);
  CHECK("net_rx: khung IPv4 khong goi hook", hook_calls == 1);
  mkarp(f, ARP_OP_REQUEST, M1, HOSTMAC, HOSTIP, ZERO6, MYIP);
  net_rx(f, 60);
  CHECK("net_rx: ARP gui cho may khac khong goi hook", hook_calls == 1);
  week3_arp_hook = 0;
  CHECK("net_rx: hook NULL khong gay loi", net_rx(req, 60) == WEEK2_ETH_TO_ARP);

  printf("\n== %d/%d PASS, %d FAIL ==\n", ntotal - nfail, ntotal, nfail);
  return nfail ? 1 : 0;
}
