// nettests.c – khung test mạng chạy trong xv6. Mỗi test tự kiểm tra, in PASS/FAIL.
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/netinfo.h"

static int npass, nfail, nskip;

// CHECK: chi kiem tra dieu kien, khong can biet wait() tra ve gia tri nao.
// Dung khi khong can biet gia tri tra ve -> tiet kiem tai nguyen
#define CHECK(cond) do { \
  if (!(cond)) { \
    printf("  check failed: %s (dòng %d)\n", #cond, __LINE__); \
    return -1; \
  } \
} while (0)

// CHECK_EQ: kiem tra dieu kien va tra ve gia tri cua wait().
#define CHECK_EQ(a, b) do { \
  int _a = (int)(a), _b = (int)(b); \
  if (_a != _b) { \
    printf("  check failed: %s == %s (%d != %d, dòng %d)\n", #a, #b, _a, _b, __LINE__); \
    return -1; \
  } \
} while(0)

#define SKIP(why) do { \
  printf("  skip: %s\n", why); \
  return 1; \
} while(0)

#define NCHILD 8

struct test { const char *name; int (*fn)(void); };


// ---- Các test ------
static int test_harness_sanity(void) { 
  CHECK(1 + 1 == 2); 
  return 0; 
}

static int test_fork_wait(void) {   
  int pid = fork();
  CHECK(pid >= 0);
  if (pid == 0) exit(7);
  int st = -1;
  CHECK_EQ(wait(&st), pid);
  CHECK_EQ(st, 7);
  return 0;
}

static int test_fork_many(void) {
  for (int i = 0; i < NCHILD; i++) {
    int pid = fork();
    CHECK(pid >= 0);
    if (pid == 0) exit(10 + i);
  }
  int seen = 0; //su dung co che bit, bit i = 1 khi nhan duoc con thu i
  for (int i = 0; i < NCHILD; i++) {
    int st = -1;
    CHECK(wait(&st) > 0); 
    CHECK(st >= 10 && st < 10 + NCHILD);
    seen |= 1 << (st - 10); //seen duoc OR voi 1 dich trai so bit tuong ung
  }
  CHECK_EQ(seen, (1 << NCHILD) - 1);
  return 0;
  
}

#ifdef HAVE_SOCKET
static int test_e1000_init(void) { // pass lhi MAC doc tu E1000 khop MAC cua stack
  struct netinfo st;
  CHECK_EQ(netinfo(&st), 0);
  CHECK(st.mac[0] == 0x52 && st.mac[1] == 0x54 && st.mac[2] == 0x00 &&
        st.mac[3] == 0x12 && st.mac[4] == 0x34 && st.mac[5] == 0x56);
  return 0;
}

static int test_arp_request_tx(void) { // pass khi tu luc boot gui >= 1 khung ARP request ra NIC
  struct netinfo st;
  CHECK_EQ(netinfo(&st), 0);
  CHECK(st.tx_frames >= 1);
  return 0;
}
#else
static int test_e1000_init(void) { SKIP("need HAVE_SOCKET"); }
static int test_arp_request_tx(void) { SKIP("need HAVE_SOCKET"); }
#endif

// chua co syscall van bien dich duoc
#ifdef HAVE_SOCKET
#define TPORT 4000

static int test_socket_open_close(void) {
  int fd = socket();
  CHECK(fd >= 0);
  CHECK_EQ(close(fd), 0);
  return 0;
}

static int test_bind_ok(void) {
  int fd = socket();
  CHECK(fd >= 0);
  CHECK_EQ(bind(fd, TPORT), 0);
  close(fd);
  return 0;
}

static int test_bind_dup_port(void) {      // 2 socket không được cùng cổng
  int a = socket(), b = socket();
  CHECK(a >= 0 && b >= 0);
  CHECK_EQ(bind(a, TPORT), 0);
  CHECK(bind(b, TPORT) < 0);
  close(a); close(b);
  return 0;
}

static int test_bind_bad_fd(void) {
  CHECK(bind(-1, TPORT) < 0);
  CHECK(bind(999, TPORT) < 0);
  CHECK(bind(0, TPORT) < 0);               // fd 0 là console, không phải socket
  return 0;
}

static int test_sendto_non_socket_fd(void) {
  char b[4] = "abc";
  CHECK(sendto(1, b, 3, 0x0a000202, 2000) < 0);
  return 0;
}

static int test_close_frees_port(void) {   // đóng socket thì bind lại cùng cổng được
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(bind(a, TPORT), 0);
  CHECK_EQ(close(a), 0);
  int b = socket();
  CHECK(b >= 0);
  CHECK_EQ(bind(b, TPORT), 0);
  close(b);
  return 0;
}

static int test_fd_limit_no_leak(void) {   // mở tới giới hạn rồi đóng hết, sau đó mở lại được
  int fds[64], n = 0;
  while (n < 64) {
    int fd = socket();
    if (fd < 0) break;
    fds[n++] = fd;
  }
  CHECK(n > 0 && n < 64);                  // phải có giới hạn, không được mở vô hạn
  for (int i = 0; i < n; i++) close(fds[i]);
  int again = socket();
  CHECK(again >= 0);
  close(again);
  return 0;
}

// ---------------- Tuan 4/5 (NET-63): sendto / recvfrom / netinfo ----------------
// IP cua xv6 doc tu netinfo() trong main(): 10.0.2.15 (slirp) hoac 192.168.100.2 (TAP).
// Gui toi IP nay (hoac 127.x) la loopback trong kernel: khong ra day, khong can mang.
static uint32 myip;
#define MYIP   myip
#define SLIRP_IP 0x0a00020f          // 10.0.2.15
#define TAP_IP   0xc0a86402          // 192.168.100.2
#define RXQ    16                    // = SOCK_RXQ trong kernel/sysnet.c
#define MAXDG  1472
#define BADPTR ((char *)0x3fffff0000L)   // dia chi user chua map

static char big[MAXDG + 8], rbuf[MAXDG + 8];

static int test_netinfo_basic(void) {
  struct netinfo st;
  CHECK_EQ(netinfo(&st), 0);
  CHECK(st.ip == SLIRP_IP || st.ip == TAP_IP);
  CHECK(st.mac[0] == 0x52 && st.mac[1] == 0x54 && st.mac[5] == 0x56);
  CHECK(netinfo(0) < 0);
  CHECK(netinfo((struct netinfo *)BADPTR) < 0);
  return 0;
}

static int test_loopback_send_recv(void) {
  int a = socket(), b = socket();
  uint32 ip = 0; int port = 0;
  CHECK(a >= 0 && b >= 0);
  CHECK_EQ(bind(a, 4001), 0);
  CHECK_EQ(bind(b, 4002), 0);
  CHECK_EQ(sendto(b, "hello", 5, MYIP, 4001), 5);
  memset(rbuf, 0, 16);
  CHECK_EQ(recvfrom(a, rbuf, sizeof(rbuf), &ip, &port), 5);
  CHECK(memcmp(rbuf, "hello", 5) == 0);
  CHECK(ip == MYIP);
  CHECK_EQ(port, 4002);
  close(a); close(b);
  return 0;
}

static int test_loopback_127(void) {          // 127.0.0.1 cung la loopback
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(bind(a, 4003), 0);
  CHECK_EQ(sendto(a, "x", 1, 0x7f000001, 4003), 1);
  CHECK_EQ(recvfrom(a, rbuf, 8, 0, 0), 1);    // ip/port = 0: khong can biet nguon
  close(a);
  return 0;
}

static int test_recvfrom_truncate(void) {
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(bind(a, 4004), 0);
  for (int i = 0; i < 100; i++) big[i] = 'a' + i % 26;
  CHECK_EQ(sendto(a, big, 100, MYIP, 4004), 100);
  CHECK_EQ(sendto(a, "next", 4, MYIP, 4004), 4);
  CHECK_EQ(recvfrom(a, rbuf, 10, 0, 0), 10);  // 90 byte con lai bi bo
  CHECK(memcmp(rbuf, big, 10) == 0);
  CHECK_EQ(recvfrom(a, rbuf, sizeof(rbuf), 0, 0), 4);   // ranh gioi datagram giu nguyen
  CHECK(memcmp(rbuf, "next", 4) == 0);
  close(a);
  return 0;
}

static int test_zero_and_max_dgram(void) {
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(bind(a, 4005), 0);
  CHECK_EQ(sendto(a, big, 0, MYIP, 4005), 0);
  CHECK_EQ(recvfrom(a, rbuf, sizeof(rbuf), 0, 0), 0);
  for (int i = 0; i < MAXDG; i++) big[i] = i * 7;
  CHECK_EQ(sendto(a, big, MAXDG, MYIP, 4005), MAXDG);
  CHECK_EQ(recvfrom(a, rbuf, sizeof(rbuf), 0, 0), MAXDG);
  CHECK(memcmp(rbuf, big, MAXDG) == 0);
  close(a);
  return 0;
}

static int test_sendto_bad_args(void) {
  int a = socket();
  CHECK(a >= 0);
  CHECK(sendto(a, big, -1, MYIP, 4006) < 0);
  CHECK(sendto(a, big, MAXDG + 1, MYIP, 4006) < 0);     // > 1472: can phan manh -> tu choi
  CHECK(sendto(a, big, 4, MYIP, 0) < 0);
  CHECK(sendto(a, big, 4, MYIP, 70000) < 0);
  CHECK(sendto(a, big, 4, 0, 4006) < 0);                // ip 0.0.0.0
  CHECK(sendto(a, 0, 4, MYIP, 4006) < 0);               // buf NULL
  CHECK(sendto(a, BADPTR, 4, MYIP, 4006) < 0);          // copyin loi -> -1, khong leak trang
  CHECK(sendto(-1, big, 4, MYIP, 4006) < 0);
  close(a);
  return 0;
}

static int test_recvfrom_bad_args(void) {
  int a = socket();
  CHECK(a >= 0);
  CHECK(recvfrom(-1, rbuf, 8, 0, 0) < 0);
  CHECK(recvfrom(1, rbuf, 8, 0, 0) < 0);                // console, khong phai socket
  CHECK(recvfrom(a, 0, 8, 0, 0) < 0);
  CHECK(recvfrom(a, rbuf, -1, 0, 0) < 0);
  CHECK_EQ(bind(a, 4007), 0);
  CHECK_EQ(sendto(a, "abc", 3, MYIP, 4007), 3);
  CHECK(recvfrom(a, BADPTR, 8, 0, 0) < 0);              // copyout loi -> -1, khong panic
  close(a);
  return 0;
}

static int test_autobind_ephemeral(void) {
  int a = socket(), b = socket(), port = 0;
  CHECK(a >= 0 && b >= 0);
  CHECK_EQ(bind(a, 4008), 0);
  CHECK_EQ(sendto(b, "e", 1, MYIP, 4008), 1);          // b chua bind -> kernel tu cap cong
  CHECK_EQ(recvfrom(a, rbuf, 8, 0, &port), 1);
  CHECK(port >= 49152 && port <= 65535);
  CHECK(bind(b, 4009) < 0);                            // da co cong roi thi khong bind lai
  close(a); close(b);
  return 0;
}

static int test_noport_drop(void) {
  struct netinfo s0, s1;
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(netinfo(&s0), 0);
  CHECK_EQ(sendto(a, "lost", 4, MYIP, 4999), 4);       // UDP: gui thanh cong du khong ai nghe
  CHECK_EQ(netinfo(&s1), 0);
  CHECK_EQ(s1.udp_noport - s0.udp_noport, 1);
  close(a);
  return 0;
}

static int test_rxq_full_drop(void) {
  struct netinfo s0, s1;
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(bind(a, 4010), 0);
  CHECK_EQ(netinfo(&s0), 0);
  for (int i = 0; i < RXQ + 4; i++) {
    char c = i;
    CHECK_EQ(sendto(a, &c, 1, MYIP, 4010), 1);
  }
  CHECK_EQ(netinfo(&s1), 0);
  CHECK_EQ(s1.udp_qfull - s0.udp_qfull, 4);            // 4 goi thua bi drop, co dem
  for (int i = 0; i < RXQ; i++) {                      // 16 goi dau con nguyen, dung thu tu
    CHECK_EQ(recvfrom(a, rbuf, 8, 0, 0), 1);
    CHECK_EQ(rbuf[0], i);
  }
  close(a);
  return 0;
}

static int test_close_frees_queue(void) {
  struct netinfo s0, s1;
  CHECK_EQ(netinfo(&s0), 0);
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(bind(a, 4011), 0);
  for (int i = 0; i < 5; i++)
    CHECK_EQ(sendto(a, "old", 3, MYIP, 4011), 3);
  CHECK_EQ(close(a), 0);                               // 5 trang trong hang doi phai duoc kfree
  CHECK_EQ(netinfo(&s1), 0);
  CHECK_EQ(s1.nsock, s0.nsock);
  int b = socket();
  CHECK(b >= 0);
  CHECK_EQ(bind(b, 4011), 0);
  CHECK_EQ(sendto(b, "new", 3, MYIP, 4011), 3);
  CHECK_EQ(recvfrom(b, rbuf, 8, 0, 0), 3);
  CHECK(memcmp(rbuf, "new", 3) == 0);                  // khong nhan lai goi cu
  close(b);
  return 0;
}

static int test_rw_on_socket(void) {
  int a = socket();
  CHECK(a >= 0);
  CHECK(write(a, "x", 1) < 0);
  CHECK(read(a, rbuf, 1) < 0);
  close(a);
  return 0;
}

// Con chay server echo (giong user/udp_echo.c) tren loopback.
static int test_fork_udp_echo(void) {
  int ready = socket();
  CHECK(ready >= 0);
  CHECK_EQ(bind(ready, 4012), 0);
  int pid = fork();
  CHECK(pid >= 0);
  if (pid == 0) {
    int s = socket(), sport; uint32 sip; char b[64];
    if (s < 0 || bind(s, 4013) < 0) exit(1);
    sendto(s, "r", 1, MYIP, 4012);                     // bao cho cha: server da san sang
    for (int i = 0; i < 3; i++) {
      int n = recvfrom(s, b, sizeof(b), &sip, &sport);
      if (n < 0 || sendto(s, b, n, sip, sport) != n) exit(2);
    }
    exit(0);
  }
  CHECK_EQ(recvfrom(ready, rbuf, 8, 0, 0), 1);
  int c = socket(), port = 0;
  CHECK(c >= 0);
  for (int i = 0; i < 3; i++) {
    char msg[8] = "ping-0";
    msg[5] = '0' + i;
    CHECK_EQ(sendto(c, msg, 6, MYIP, 4013), 6);
    CHECK_EQ(recvfrom(c, rbuf, sizeof(rbuf), 0, &port), 6);
    CHECK(memcmp(rbuf, msg, 6) == 0);
    CHECK_EQ(port, 4013);
  }
  int st = -1;
  CHECK_EQ(wait(&st), pid);
  CHECK_EQ(st, 0);
  close(c); close(ready);
  return 0;
}

static int test_recvfrom_blocks_kill(void) {   // recvfrom phai ngu, va kill danh thuc duoc
  int pid = fork();
  CHECK(pid >= 0);
  if (pid == 0) {
    int s = socket();
    if (s < 0 || bind(s, 4014) < 0) exit(1);
    recvfrom(s, rbuf, 8, 0, 0);                        // khong ai gui -> chan mai
    exit(5);                                           // khong duoc toi day
  }
  pause(3);
  CHECK_EQ(kill(pid), 0);
  int st = 0;
  CHECK_EQ(wait(&st), pid);
  CHECK_EQ(st, -1);
  return 0;
}

static int test_fork_shares_socket(void) {
  int a = socket(), port = 0;
  CHECK(a >= 0);
  CHECK_EQ(bind(a, 4015), 0);
  int pid = fork();
  CHECK(pid >= 0);
  if (pid == 0) {                                      // con dung fd ke thua
    exit(sendto(a, "kid", 3, MYIP, 4015) == 3 ? 0 : 1);
  }
  int st = -1;
  CHECK_EQ(wait(&st), pid);
  CHECK_EQ(st, 0);
  CHECK_EQ(recvfrom(a, rbuf, 8, 0, &port), 3);
  CHECK_EQ(port, 4015);                                // cung socket -> cung cong nguon
  close(a);
  return 0;
}

#define NSENDER 4
#define PERSENDER 3
static int test_concurrent_senders(void) {     // nhieu tien trinh gui cung luc (CPUS=4)
  int a = socket(), port;
  int seen[NSENDER] = {0};
  CHECK(a >= 0);
  CHECK_EQ(bind(a, 4100), 0);
  for (int i = 0; i < NSENDER; i++) {
    int pid = fork();
    CHECK(pid >= 0);
    if (pid == 0) {
      int s = socket();
      if (s < 0 || bind(s, 4101 + i) < 0) exit(1);
      for (int k = 0; k < PERSENDER; k++)
        if (sendto(s, "c", 1, MYIP, 4100) != 1) exit(2);
      exit(0);
    }
  }
  for (int k = 0; k < NSENDER * PERSENDER; k++) {      // 12 < RXQ: khong drop
    CHECK_EQ(recvfrom(a, rbuf, 8, 0, &port), 1);
    CHECK(port >= 4101 && port < 4101 + NSENDER);
    seen[port - 4101]++;
  }
  for (int i = 0; i < NSENDER; i++) {
    int st = -1;
    CHECK(wait(&st) > 0);
    CHECK_EQ(st, 0);
  }
  for (int i = 0; i < NSENDER; i++)
    CHECK_EQ(seen[i], PERSENDER);
  close(a);
  return 0;
}

// =====================================================================================
// Tuan 5: ICMP/ping, tai + dong thoi tren day that, quan ly bo nho.
// Khong can sua kernel: dung syscall san co (ping, sendto, netinfo, sbrk).
// =====================================================================================
#define DISCARD     9                // cong UDP "discard" cua host: goi ra day roi bi bo
#define PING_SLOTS  4                // = PING_SLOTS trong kernel/week4_ip_kernel.c
static int res[3];                   // ping(): res[0] RTT (us), res[1] ttl, res[2] so byte ICMP

// Gateway: 10.0.2.2 (slirp) hoac 192.168.100.1 (TAP, host phia tap0).
static uint32 gwip(void) { return (myip & 0xffffff00) | (myip == TAP_IP ? 1 : 2); }
// .90 - .99 cung subnet nhung khong ai tra loi ARP -> ARP miss, goi nam trong hang doi ARP
// roi bi huy khi het luot thu (~3-4 s). Moi test dung mot dia chi rieng.
#define UNANS(n)  ((myip & 0xffffff00) | (n))

// So trang vat ly con trong (giong countfree() cua usertests): sbrk tung trang toi khi het
// bo nho roi tra lai. Trang bang trang (page-table) tao ra o lan goi dau duoc giu lai, nen tu
// lan goi thu hai tro di, hai lan do lien tiep chenh nhau dung bang so trang kernel bi mat.
static int countfree(void) {
  int n = 0;
  char *sz0 = sbrk(0);
  while (sbrk(4096) != SBRK_ERROR)
    n++;
  sbrk(-(int)(sbrk(0) - sz0));
  return n;
}

// 0 neu khong mat trang so voi moc `before`. Do lai toi 3 lan: mot ngat dang giu tam
// 1 trang (vd. dang tra loi ARP) dung luc dem se lam ket qua thap hon 1 mot cach gia.
static int leaked_since(int before) {
  int now = 0;
  for (int i = 0; i < 3; i++) {
    now = countfree();
    if (now >= before)
      return 0;
    pause(10);
  }
  printf("  leak: %d trang (truoc %d, sau %d)\n", before - now, before, now);
  return before - now;
}

// ---------------- ICMP / ping ----------------

static int test_ping_gateway(void) {          // xv6 ping host, nhieu kich thuoc
  int sizes[] = { 0, 56, 1000, 1472 };
  for (int i = 0; i < 4; i++) {
    CHECK_EQ(ping(gwip(), i + 1, sizes[i], 30, res), 0);
    CHECK(res[0] >= 0 && res[0] < 1000000);    // RTT < 1 s
    CHECK(res[1] > 0);                          // ttl cua goi tra loi
    CHECK_EQ(res[2], 8 + sizes[i]);             // header ICMP + du lieu echo ve du
  }
  return 0;
}

static int test_ping_timeout(void) {          // khong ai tra loi -> -1 dung han, khong treo
  int t0 = uptime();
  CHECK_EQ(ping(UNANS(99), 1, 56, 10, res), -1);
  int dt = uptime() - t0;
  CHECK(dt >= 9 && dt < 30);
  return 0;
}

static int test_ping_bad_args(void) {
  CHECK_EQ(ping(gwip(), 1, -1, 10, res), -2);
  CHECK_EQ(ping(gwip(), 1, 1473, 10, res), -2);           // > 1472: can phan manh
  CHECK_EQ(ping(gwip(), 1, 56, 0, res), -2);
  CHECK_EQ(ping(gwip(), 1, 56, 601, res), -2);            // > 60 s
  CHECK_EQ(ping(gwip(), 1, 56, 30, (int *)BADPTR), -2);   // co tra loi nhung copyout loi
  CHECK_EQ(ping(gwip(), 2, 56, 30, res), 0);              // slot da duoc tra lai
  return 0;
}

static int test_ping_kill(void) {             // kill khi dang cho reply: thoat, tra slot
  int pid = fork();
  CHECK(pid >= 0);
  if (pid == 0) {
    ping(UNANS(98), 1, 56, 600, res);         // cho toi 60 s
    exit(5);                                  // khong duoc toi day
  }
  pause(5);
  CHECK_EQ(kill(pid), 0);
  int st = 0;
  CHECK_EQ(wait(&st), pid);
  CHECK_EQ(st, -1);
  CHECK_EQ(ping(gwip(), 1, 56, 30, res), 0);
  return 0;
}

static int test_ping_slots_full(void) {       // ca 4 slot ban -> ping thu 5 bao loi ngay
  int pids[PING_SLOTS];
  for (int i = 0; i < PING_SLOTS; i++) {
    pids[i] = fork();
    CHECK(pids[i] >= 0);
    if (pids[i] == 0)                         // moi con mot IP: moi IP mot entry ARP rieng
      exit(ping(UNANS(91 + i), 1, 56, 30, res) == -1 ? 0 : 1);
  }
  pause(10);                                  // 4 con da giu slot va dang cho (3 s)
  int t0 = uptime();
  CHECK_EQ(ping(gwip(), 9, 56, 10, res), -2);
  CHECK(uptime() - t0 < 5);                   // tu choi ngay, khong cho
  for (int i = 0; i < PING_SLOTS; i++) {
    int st = -1;
    CHECK(wait(&st) > 0);
    CHECK_EQ(st, 0);
  }
  CHECK_EQ(ping(gwip(), 10, 56, 30, res), 0); // slot da duoc giai phong het
  return 0;
}

static int test_ping_concurrent(void) {       // 4 tien trinh ping cung luc, khong lan reply
  for (int i = 0; i < PING_SLOTS; i++) {
    int pid = fork();
    CHECK(pid >= 0);
    if (pid == 0) {
      for (int k = 1; k <= 5; k++)
        if (ping(gwip(), k, 16 * i + k, 30, res) != 0 || res[2] != 8 + 16 * i + k)
          exit(1);
      exit(0);
    }
  }
  for (int i = 0; i < PING_SLOTS; i++) {
    int st = -1;
    CHECK(wait(&st) > 0);
    CHECK_EQ(st, 0);
  }
  return 0;
}

// ---------------- tai + dong thoi tren day that (TX ring, tx_lock, ngat RX) ----------------

#define NBURST 64                    // > so descriptor TX (8): ring phai quay vong nhieu lan
static int test_tx_burst_wire(void) {
  struct netinfo s0, s1;
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(ping(gwip(), 1, 0, 30, res), 0);   // dam bao ARP gateway dang HIT: burst khong
                                              // bi xep hang ARP (hang doi chi 2 khung)
  CHECK_EQ(netinfo(&s0), 0);
  for (int i = 0; i < NBURST; i++)
    CHECK_EQ(sendto(a, big, 1000, gwip(), DISCARD), 1000);
  CHECK_EQ(netinfo(&s1), 0);
  CHECK_EQ(s1.udp_tx - s0.udp_tx, NBURST);
  CHECK((s1.tx_frames - s0.tx_frames) + (s1.tx_err - s0.tx_err) >= NBURST);
  close(a);
  CHECK_EQ(ping(gwip(), 2, 56, 30, res), 0);  // NIC va RX van song sau burst
  return 0;
}

#define NWSEND 3
#define PERWSEND 20
static int test_concurrent_wire_mixed(void) { // 3 tien trinh gui UDP + 1 tien trinh ping
  struct netinfo s0, s1;
  CHECK_EQ(ping(gwip(), 1, 0, 30, res), 0);
  CHECK_EQ(netinfo(&s0), 0);
  for (int i = 0; i <= NWSEND; i++) {
    int pid = fork();
    CHECK(pid >= 0);
    if (pid == 0) {
      if (i == NWSEND) {                      // con cuoi: ping trong luc cac con khac gui
        for (int k = 1; k <= 5; k++)
          if (ping(gwip(), k, 56, 30, res) != 0)
            exit(1);
        exit(0);
      }
      int s = socket();
      if (s < 0) exit(2);
      for (int k = 0; k < PERWSEND; k++)
        if (sendto(s, big, 512, gwip(), DISCARD) != 512)
          exit(3);
      exit(0);
    }
  }
  for (int i = 0; i <= NWSEND; i++) {
    int st = -1;
    CHECK(wait(&st) > 0);
    CHECK_EQ(st, 0);
  }
  CHECK_EQ(netinfo(&s1), 0);
  CHECK(s1.udp_tx - s0.udp_tx >= NWSEND * PERWSEND);
  CHECK((s1.tx_frames - s0.tx_frames) + (s1.tx_err - s0.tx_err) >= NWSEND * PERWSEND + 5);
  return 0;
}

#define NRECV 3
#define NMSG  30
static int test_concurrent_recvfrom_same_socket(void) { // moi datagram chi den dung 1 nguoi
  int srv = socket(), rep = socket(), src = socket();
  int seen[NMSG] = {0};
  CHECK(srv >= 0 && rep >= 0 && src >= 0);
  CHECK_EQ(bind(srv, 4200), 0);
  CHECK_EQ(bind(rep, 4201), 0);
  for (int i = 0; i < NRECV; i++) {
    int pid = fork();
    CHECK(pid >= 0);
    if (pid == 0) {                           // ca 3 con cung chan tren recvfrom(srv)
      unsigned char b[8];
      for (;;) {
        if (recvfrom(srv, b, sizeof(b), 0, 0) != 1) exit(1);
        if (b[0] == 0xff) exit(0);
        if (sendto(srv, b, 1, MYIP, 4201) != 1) exit(2);   // bao cho cha: "toi nhan c"
      }
    }
  }
  for (int batch = 0; batch < NMSG / 10; batch++) {        // 10 goi/lot < SOCK_RXQ
    for (int k = 0; k < 10; k++) {
      unsigned char c = batch * 10 + k;
      CHECK_EQ(sendto(src, &c, 1, MYIP, 4200), 1);
    }
    for (int k = 0; k < 10; k++) {
      CHECK_EQ(recvfrom(rep, rbuf, 8, 0, 0), 1);
      unsigned char c = rbuf[0];
      CHECK(c < NMSG);
      seen[c]++;
    }
  }
  for (int i = 0; i < NRECV; i++) {
    unsigned char end = 0xff;
    CHECK_EQ(sendto(src, &end, 1, MYIP, 4200), 1);
  }
  for (int i = 0; i < NRECV; i++) {
    int st = -1;
    CHECK(wait(&st) > 0);
    CHECK_EQ(st, 0);
  }
  for (int c = 0; c < NMSG; c++)
    CHECK_EQ(seen[c], 1);
  close(srv); close(rep); close(src);
  return 0;
}

static int test_close_shared_socket(void) {   // cha close khi con dang chan trong recvfrom
  int a = socket();
  CHECK(a >= 0);
  CHECK_EQ(bind(a, 4210), 0);
  int pid = fork();
  CHECK(pid >= 0);
  if (pid == 0)
    exit(recvfrom(a, rbuf, 8, 0, 0) == 3 ? 0 : 1);
  CHECK_EQ(close(a), 0);                      // con van giu ref -> socket chua bi huy
  pause(3);
  int b = socket();
  CHECK(b >= 0);
  CHECK(bind(b, 4210) < 0);                   // cong van thuoc socket cua con
  CHECK_EQ(sendto(b, "abc", 3, MYIP, 4210), 3);
  int st = -1;
  CHECK_EQ(wait(&st), pid);
  CHECK_EQ(st, 0);
  close(b);
  int c = socket();                           // con thoat -> ref cuoi -> cong duoc tra
  CHECK(c >= 0);
  CHECK_EQ(bind(c, 4210), 0);
  close(c);
  return 0;
}

#define NRACE 8
static int test_bind_race(void) {             // 8 tien trinh cung bind 1 cong: dung 1 thang
  int p[2];
  CHECK_EQ(pipe(p), 0);
  for (int i = 0; i < NRACE; i++) {
    int pid = fork();
    CHECK(pid >= 0);
    if (pid == 0) {
      char c;
      close(p[1]);
      int s = socket();
      int r = (s >= 0) ? bind(s, 4220) : -1;
      read(p[0], &c, 1);                      // giu socket toi khi cha dong pipe
      exit(r == 0 ? 0 : 1);
    }
  }
  close(p[0]);
  pause(5);
  close(p[1]);
  int wins = 0;
  for (int i = 0; i < NRACE; i++) {
    int st = -1;
    CHECK(wait(&st) > 0);
    if (st == 0) wins++;
  }
  CHECK_EQ(wins, 1);
  return 0;
}

// ---------------- quan ly bo nho (dem trang trong tu user space) ----------------

// Hoi quy cho loi leak da sua o NET-65: hang doi ARP day -> week4_ip_send tra < 0 ->
// sys_sendto phai kfree khung. Cac khung da xep hang thi ARP kfree khi het luot thu.
static int test_no_leak_arp_queue_full(void) {
  int free0 = countfree();
  int a = socket(), ok = 0, refused = 0;
  CHECK(a >= 0);
  for (int i = 0; i < 6; i++) {
    int r = sendto(a, big, 512, UNANS(97), DISCARD);
    if (r == 512) ok++;
    else refused++;
  }
  CHECK(ok >= 1 && refused >= 1);             // vai khung xep hang, phan con lai bi tu choi
  close(a);
  pause(60);                                  // ARP bo cuoc sau ~3-4 s va kfree hang doi
  CHECK_EQ(leaked_since(free0), 0);
  return 0;
}

// Cung 1 IP khong tra loi: ping 1 timeout (-1); cac ping sau co the gap hang doi ARP day
// (2 khung) -> sys_ping tra -2 va phai tu kfree khung. Ca hai nhanh deu khong duoc leak.
static int test_no_leak_ping_timeout(void) {
  int free0 = countfree(), full = 0;
  CHECK_EQ(ping(UNANS(96), 1, 512, 5, res), -1);
  for (int i = 2; i <= 4; i++) {
    int r = ping(UNANS(96), i, 512, 5, res);
    CHECK(r == -1 || r == -2);
    full += (r == -2);
  }
  CHECK(full >= 1);                           // nhanh "hang doi ARP day" da thuc su chay
  pause(60);
  CHECK_EQ(leaked_since(free0), 0);
  return 0;
}

static int test_no_leak_socket_churn(void) {  // mo/dong + day hang doi 200 lan
  int free0 = countfree();
  for (int i = 0; i < 200; i++) {
    int a = socket();
    CHECK(a >= 0);
    CHECK_EQ(bind(a, 4300 + i % 4), 0);
    for (int k = 0; k < 3; k++)
      CHECK_EQ(sendto(a, big, 100, MYIP, 4300 + i % 4), 100);
    if (i & 1)
      CHECK_EQ(recvfrom(a, rbuf, sizeof(rbuf), 0, 0), 100);
    CHECK_EQ(close(a), 0);                    // con 2-3 datagram trong hang doi
  }
  CHECK_EQ(leaked_since(free0), 0);
  return 0;
}

// Moc do o dau main() truoc khi chay test dau tien; test nay luon dung cuoi bang.
static int free_start;
static int test_no_leak_suite(void) {
  if (free_start == 0)
    SKIP("chi chay khi chay ca bo test");
  pause(60);                                  // cho ARP huy cac khung con xep hang
  CHECK_EQ(leaked_since(free_start), 0);
  return 0;
}
#endif

static struct test tests[] = {
  { "harness_sanity",  test_harness_sanity },
  { "fork_wait",       test_fork_wait },
  { "fork_many",       test_fork_many },
  { "e1000_init",      test_e1000_init },
  { "arp_request_tx",  test_arp_request_tx },

  #ifdef HAVE_SOCKET
    { "socket_open_close",     test_socket_open_close },
    { "bind_ok",               test_bind_ok },
    { "bind_dup_port",         test_bind_dup_port },
    { "bind_bad_fd",           test_bind_bad_fd },
    { "sendto_non_socket_fd",  test_sendto_non_socket_fd },
    { "close_frees_port",      test_close_frees_port },
    { "fd_limit_no_leak",      test_fd_limit_no_leak },
    { "netinfo_basic",         test_netinfo_basic },
    { "loopback_send_recv",    test_loopback_send_recv },
    { "loopback_127",          test_loopback_127 },
    { "recvfrom_truncate",     test_recvfrom_truncate },
    { "zero_and_max_dgram",    test_zero_and_max_dgram },
    { "sendto_bad_args",       test_sendto_bad_args },
    { "recvfrom_bad_args",     test_recvfrom_bad_args },
    { "autobind_ephemeral",    test_autobind_ephemeral },
    { "noport_drop",           test_noport_drop },
    { "rxq_full_drop",         test_rxq_full_drop },
    { "close_frees_queue",     test_close_frees_queue },
    { "rw_on_socket",          test_rw_on_socket },
    { "fork_udp_echo",         test_fork_udp_echo },
    { "recvfrom_blocks_kill",  test_recvfrom_blocks_kill },
    { "fork_shares_socket",    test_fork_shares_socket },
    { "concurrent_senders",    test_concurrent_senders },
    { "ping_gateway",          test_ping_gateway },
    { "ping_timeout",          test_ping_timeout },
    { "ping_bad_args",         test_ping_bad_args },
    { "ping_kill",             test_ping_kill },
    { "ping_slots_full",       test_ping_slots_full },
    { "ping_concurrent",       test_ping_concurrent },
    { "tx_burst_wire",         test_tx_burst_wire },
    { "concurrent_wire_mixed", test_concurrent_wire_mixed },
    { "concurrent_recvfrom_same_socket", test_concurrent_recvfrom_same_socket },
    { "close_shared_socket",   test_close_shared_socket },
    { "bind_race",             test_bind_race },
    { "no_leak_arp_queue_full", test_no_leak_arp_queue_full },
    { "no_leak_ping_timeout",  test_no_leak_ping_timeout },
    { "no_leak_socket_churn",  test_no_leak_socket_churn },
    { "no_leak_suite",         test_no_leak_suite },     // luon de cuoi
  #endif

};

static void run(struct test *t) {
  int r = t->fn();
  if (r == 0) {
    printf("PASS: %s\n", t->name);
    npass++;
  } else if (r == 1) { 
    printf("SKIP: %s\n", t->name); 
    nskip++; 
  } else { 
    printf("FAIL: %s\n", t->name); 
    nfail++; 
  }
}

// nettests        : chay ca bo test
// nettests <ten>  : chi chay 1 test
int main(int argc, char *argv[]) {
  int n = sizeof(tests) / sizeof(tests[0]);
#ifdef HAVE_SOCKET
  struct netinfo st;
  if (netinfo(&st) == 0)
    myip = st.ip;
#endif
  if (argc > 1) {
    int found = 0;
    for (int i = 0; i < n; i++) if (strcmp(tests[i].name, argv[1]) == 0) {
      run(&tests[i]);
      found = 1;
    }
    if (!found) {
      printf("FAIL: test not found '%s'\n", argv[1]);
      nfail++;
    }
  } else {
#ifdef HAVE_SOCKET
    free_start = countfree();                 // moc cho no_leak_suite (cuoi bang)
#endif
    for (int i = 0; i < n; i++) run(&tests[i]);
  }
  printf("NETTESTS: %d passed, %d failed, %d skipped\n", npass, nfail, nskip);
  printf("NETTESTS DONE\n");
  exit(nfail ? 1 : 0);
}
