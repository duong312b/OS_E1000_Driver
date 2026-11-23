// sysnet.c - UDP socket la mot file descriptor (FD_SOCK) + 5 syscall mang.
//
// Khoa (thu tu luon la socktable.lock -> s->lock, khong bao gio nguoc lai):
//   socktable.lock : bao ve s->used, s->lport cua MOI socket (bind, tim theo cong)
//                    va next_eport.
//   s->lock        : bao ve hang doi nhan q/head/count cua socket s.
// Khong giu bat ky khoa nao trong file nay khi goi week4_ip_send / copyin /
// copyout, nen khong co vong khoa voi week3_arp_lock / net_tx_lock.
//
// So huu bo nho:
//   - Moi datagram trong hang doi nam trong 1 trang kalloc (sock_deliver cap,
//     sys_recvfrom / sockclose giai phong).
//   - Khung TX: sys_sendto cap bang week4_ip_alloc, udp_write ghi header UDP,
//     roi week4_ip_send (IP + ARP). week4_ip_send == 0: stack so huu frame;
//     < 0: sys_sendto van so huu va phai kfree. Loopback: giai phong ngay.
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "net.h"
#include "netinfo.h"
#include "e1000.h"
#include "week4_ip.h"

#define NSOCK        16          // so socket toi da toan he thong
#define SOCK_RXQ     16          // so datagram toi da xep hang moi socket
#define EPORT_FIRST  49152       // cong tu cap (ephemeral) khi sendto chua bind
#define EPORT_LAST   65535

struct dgram {
  uint8 *buf;        // trang kalloc chua payload
  int    len;
  uint32 ip;         // IP nguon (host order)
  uint16 port;       // cong nguon
};

struct sock {
  struct spinlock lock;
  int    used;       // [socktable.lock]
  uint16 lport;      // [socktable.lock] 0 = chua bind
  int    head;       // [lock] vi tri lay ra
  int    count;      // [lock] so datagram dang cho
  struct dgram q[SOCK_RXQ];   // [lock]
};

static struct {
  struct spinlock lock;
  struct sock sock[NSOCK];
  uint16 next_eport;
} socktable;

static int sock_ready;
static struct spinlock netrx_lock;
static uint8 rxbuf[E1000_RX_BUF_SIZE];   // [netrx_lock] static: khong dat 2 KB len stack ngat

static void udp_ip_rx(const uint8 *buf, int len);
static void udp_from_ip(const uint8 *frame, const struct week4_ip_info *ip);

uint32 udp_rx_cnt, udp_tx_cnt, udp_noport, udp_qfull, udp_bad;

void
sockinit(void)
{
  int i;

  initlock(&socktable.lock, "socktable");
  initlock(&netrx_lock, "netrx");
  for (i = 0; i < NSOCK; i++)
    initlock(&socktable.sock[i].lock, "sock");
  socktable.next_eport = EPORT_FIRST;
  // week4_ip_rx (week4_ip_kernel.c) owns week4_ip_hook and demuxes ICMP;
  // UDP frames are handed to us through week4_udp_hook.
  week4_udp_hook = udp_from_ip;
  __atomic_store_n(&sock_ready, 1, __ATOMIC_RELEASE);
}

// ---------------- cap phat / dong ----------------

static struct sock *
sockalloc(void)
{
  struct sock *s;

  acquire(&socktable.lock);
  for (s = socktable.sock; s < socktable.sock + NSOCK; s++) {
    if (!s->used) {
      s->used = 1;
      s->lport = 0;
      release(&socktable.lock);
      acquire(&s->lock);
      s->head = 0;
      s->count = 0;
      release(&s->lock);
      return s;
    }
  }
  release(&socktable.lock);
  return 0;
}

// Goi tu fileclose khi ref ve 0: khong con ai dung socket nay nua.
void
sockclose(struct sock *s)
{
  uint8 *pending[SOCK_RXQ];
  int i, n = 0;

  acquire(&socktable.lock);
  acquire(&s->lock);        // cho sock_deliver (neu dang chay) ra khoi s
  s->lport = 0;             // tu day RX khong tim thay socket nay nua
  s->used = 0;
  while (s->count > 0) {
    pending[n++] = s->q[s->head].buf;
    s->head = (s->head + 1) % SOCK_RXQ;
    s->count--;
  }
  release(&s->lock);
  release(&socktable.lock);
  for (i = 0; i < n; i++)
    kfree(pending[i]);
}

// Tim socket da bind cong port. Tra ve voi s->lock DANG GIU.
static struct sock *
sock_lookup_locked(uint16 port)
{
  struct sock *s;

  acquire(&socktable.lock);
  for (s = socktable.sock; s < socktable.sock + NSOCK; s++) {
    if (s->used && s->lport == port) {
      acquire(&s->lock);
      release(&socktable.lock);
      return s;
    }
  }
  release(&socktable.lock);
  return 0;
}

static int
port_in_use(uint16 port)     // goi khi dang giu socktable.lock
{
  struct sock *s;

  for (s = socktable.sock; s < socktable.sock + NSOCK; s++)
    if (s->used && s->lport == port)
      return 1;
  return 0;
}

static int
sockbind(struct sock *s, int port)
{
  int r = -1;

  if (port <= 0 || port > 65535)
    return -1;
  acquire(&socktable.lock);
  if (s->lport == 0 && !port_in_use(port)) {
    s->lport = port;
    r = 0;
  }
  release(&socktable.lock);
  return r;
}

// sendto tren socket chua bind: cap cong ephemeral 49152..65535.
static int
sockautobind(struct sock *s)
{
  int tries;
  uint16 p;

  acquire(&socktable.lock);
  if (s->lport != 0) {
    release(&socktable.lock);
    return 0;
  }
  for (tries = 0; tries <= EPORT_LAST - EPORT_FIRST; tries++) {
    p = socktable.next_eport;
    socktable.next_eport = (p == EPORT_LAST) ? EPORT_FIRST : p + 1;
    if (!port_in_use(p)) {
      s->lport = p;
      release(&socktable.lock);
      return 0;
    }
  }
  release(&socktable.lock);
  return -1;
}

// ---------------- duong nhan ----------------

// Dua mot datagram vao hang doi cua socket dang bind dport. Copy payload,
// khong giu con tro data sau khi tra ve. Co the chay trong ngat: khong ngu.
static void
sock_deliver(uint32 src, uint16 sport, uint16 dport, const uint8 *data, int len)
{
  struct sock *s;
  struct dgram *d;
  uint8 *page;

  page = kalloc();
  if (page == 0) {
    __sync_fetch_and_add(&udp_qfull, 1);
    return;
  }
  memmove(page, data, len);

  s = sock_lookup_locked(dport);
  if (s == 0) {
    __sync_fetch_and_add(&udp_noport, 1);
    kfree(page);
    return;
  }
  if (s->count == SOCK_RXQ) {
    release(&s->lock);
    __sync_fetch_and_add(&udp_qfull, 1);
    kfree(page);
    return;
  }
  d = &s->q[(s->head + s->count) % SOCK_RXQ];
  d->buf = page;
  d->len = len;
  d->ip = src;
  d->port = sport;
  s->count++;
  __sync_fetch_and_add(&udp_rx_cnt, 1);
  wakeup(s);
  release(&s->lock);
}

// week4_ip_hook: net_rx goi cho moi khung IPv4 (buf chi duoc muon).
static void
udp_ip_rx(const uint8 *buf, int len)
{
  struct udp_info u;
  int r;

  r = udp_parse(buf, len, week2_my_ip, &u);
  if (r == UDP_PARSE_NOTUDP)
    return;                         // ICMP...: phan cua B
  if (r < 0) {
    __sync_fetch_and_add(&udp_bad, 1);
    return;
  }
  sock_deliver(u.src, u.sport, u.dport, u.data, u.dlen);
}

// week4_udp_hook: week4_ip_rx already validated the IP header.
static void
udp_from_ip(const uint8 *frame, const struct week4_ip_info *ip)
{
  udp_ip_rx(frame, ETH_HDR_LEN + ip->hdrlen + ip->paylen);
}

// Cau noi tam thoi (cho den khi A bat ngat E1000): clockintr tren hart 0 goi
// ham nay ~10 lan/giay, rut het RX ring va dua tung khung vao net_rx.
void
net_poll(void)
{
  int n;

  if (!__atomic_load_n(&sock_ready, __ATOMIC_ACQUIRE))
    return;
  acquire(&netrx_lock);
  while ((n = e1000_receive((char *)rxbuf, sizeof(rxbuf))) != 0) {
    if (n > 0)
      net_rx(rxbuf, n);
  }
  release(&netrx_lock);
}

// ---------------- syscall ----------------

static int
argsock(int n, struct file **pf, struct sock **ps)
{
  int fd;
  struct file *f;

  argint(n, &fd);
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    return -1;
  if (f->type != FD_SOCK)
    return -1;
  if (pf)
    *pf = f;
  *ps = f->sock;
  return 0;
}

static int
fdalloc(struct file *f)
{
  int fd;
  struct proc *p = myproc();

  for (fd = 0; fd < NOFILE; fd++) {
    if (p->ofile[fd] == 0) {
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
}

// int socket(void)
uint64
sys_socket(void)
{
  struct file *f;
  struct sock *s;
  int fd;

  if ((s = sockalloc()) == 0)
    return -1;
  if ((f = filealloc()) == 0) {
    sockclose(s);
    return -1;
  }
  f->type = FD_SOCK;
  f->readable = 1;
  f->writable = 1;
  f->sock = s;
  if ((fd = fdalloc(f)) < 0) {
    fileclose(f);               // fileclose -> sockclose
    return -1;
  }
  return fd;
}

// int bind(int fd, int port)
uint64
sys_bind(void)
{
  struct sock *s;
  int port;

  if (argsock(0, 0, &s) < 0)
    return -1;
  argint(1, &port);
  return sockbind(s, port);
}

// int sendto(int fd, const void *buf, int n, uint32 ip, int port)
uint64
sys_sendto(void)
{
  struct proc *p = myproc();
  struct sock *s;
  uint64 ubuf;
  int n, port, ulen, ipi;
  uint32 dst;
  uint8 *frame, *udp;

  if (argsock(0, 0, &s) < 0)
    return -1;
  argaddr(1, &ubuf);
  argint(2, &n);
  argint(3, &ipi);
  dst = (uint32)ipi;
  argint(4, &port);
  if (n < 0 || n > UDP_MAX_PAYLOAD || port <= 0 || port > 65535 || dst == 0)
    return -1;
  if (ubuf == 0 && n > 0)
    return -1;
  if (sockautobind(s) < 0)
    return -1;

  // week4_ip_alloc: trang kalloc da xoa, udp = frame + 34 (cho header IP de tang IP ghi).
  if ((frame = week4_ip_alloc(&udp)) == 0)
    return -1;
  if (n > 0 && copyin(p->pagetable, p->sz, (char *)udp + UDP_HDR_LEN, ubuf, n) < 0) {
    kfree(frame);
    return -1;
  }

  // Loopback: gui cho chinh minh thi khong ra day, dua thang vao hang doi.
  if (dst == week2_my_ip || (dst >> 24) == 127) {
    sock_deliver(week2_my_ip, s->lport, port, udp + UDP_HDR_LEN, n);
    kfree(frame);
    __sync_fetch_and_add(&udp_tx_cnt, 1);
    return n;
  }

  ulen = udp_write(udp, week2_my_ip, dst, s->lport, port, n);
  // week4_ip_send: dung header Ethernet/IPv4, chon next hop, giao cho ARP.
  //   0  -> stack so huu frame (gui + kfree, hoac nam trong hang doi ARP)
  //   <0 -> frame van cua ta (vd. hang doi ARP day): phai kfree, neu khong se leak.
  if (ulen < 0 || week4_ip_send(frame, dst, IPPROTO_UDP, ulen) < 0) {
    kfree(frame);
    return -1;
  }
  __sync_fetch_and_add(&udp_tx_cnt, 1);
  return n;
}

// int recvfrom(int fd, void *buf, int n, uint32 *ip, int *port)
// Chan cho den khi co datagram. Datagram dai hon n bi cat (phan thua mat).
uint64
sys_recvfrom(void)
{
  struct proc *p = myproc();
  struct sock *s;
  struct dgram d;
  uint64 ubuf, uip, uport;
  int n, port;

  if (argsock(0, 0, &s) < 0)
    return -1;
  argaddr(1, &ubuf);
  argint(2, &n);
  argaddr(3, &uip);
  argaddr(4, &uport);
  if (n < 0 || ubuf == 0)
    return -1;

  acquire(&s->lock);
  while (s->count == 0) {
    if (killed(p)) {
      release(&s->lock);
      return -1;
    }
    sleep_prepare(s);
    release(&s->lock);
    sleep();
    acquire(&s->lock);
  }
  d = s->q[s->head];
  s->head = (s->head + 1) % SOCK_RXQ;
  s->count--;
  release(&s->lock);

  // Da lay datagram ra khoi hang doi: copyout loi thi datagram cung mat.
  if (n > d.len)
    n = d.len;
  port = d.port;
  if (copyout(p->pagetable, p->sz, ubuf, (char *)d.buf, n) < 0 ||
      (uip && copyout(p->pagetable, p->sz, uip, (char *)&d.ip, sizeof(d.ip)) < 0) ||
      (uport && copyout(p->pagetable, p->sz, uport, (char *)&port, sizeof(port)) < 0)) {
    kfree(d.buf);
    return -1;
  }
  kfree(d.buf);
  return n;
}

// int netinfo(struct netinfo *st)
uint64
sys_netinfo(void)
{
  struct proc *p = myproc();
  struct netinfo st;
  struct sock *s;
  uint64 addr;
  int i;

  argaddr(0, &addr);
  if (addr == 0)
    return -1;
  memset(&st, 0, sizeof(st));
  st.ip = week2_my_ip;
  for (i = 0; i < ETHADDR_LEN; i++)
    st.mac[i] = week2_my_mac[i];
  acquire(&socktable.lock);
  for (s = socktable.sock; s < socktable.sock + NSOCK; s++)
    if (s->used)
      st.nsock++;
  release(&socktable.lock);
  st.rx_arp = week2_rx_arp;
  st.rx_ip = week2_rx_ip;
  st.rx_drop = week2_rx_drop;
  st.tx_frames = week4_tx_frames;
  st.tx_err = week4_tx_err;
  st.udp_rx = udp_rx_cnt;
  st.udp_tx = udp_tx_cnt;
  st.udp_noport = udp_noport;
  st.udp_qfull = udp_qfull;
  st.udp_bad = udp_bad;
  if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    return -1;
  return 0;
}
