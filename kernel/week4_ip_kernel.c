#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "net.h"
#include "week4_ip.h"

extern uint ticks;
#ifdef NET_POLL_RX
extern void e1000_recv(void);
#endif

// ---------------------------------------------------------------------------
// Locking / ownership invariants (week 4)
//  icmp_lock protects slots[] ONLY. It is a leaf lock: never held while calling kalloc,
//    kfree, week3_arp_send, week2_net_tx or printk.
//  RX (interrupt context): week4_ip_rx borrows `buf` (valid until it returns). Anything
//    kept is copied. The echo reply is built in a fresh kalloc page and handed to
//    week2_net_tx, which frees it.
//  X: week4_ip_send(frame) == 0  -> the stack owns the frame (ARP cache or NIC path frees it).
//                         <  0  -> the caller still owns it and must kfree it.
//    This relies on week3_arp_send() having the same contract: it must return < 0 ONLY when it
//    did not consume the frame. week2_net_tx() always frees, so week3_arp_send() must not
//    forward its failure on the "cache hit" path (see patches/week3_arp_send_ownership.diff),
//    otherwise sys_ping's kfree() below would be a double free after an E1000 TX failure.
//  Timers: week4_ip_tick() is called from clockintr() on EVERY hart (not only hart 0); it
//    only touches slots[] under icmp_lock, so concurrent calls are safe.
// ---------------------------------------------------------------------------

struct week4_stats week4_stats;
void (*week4_udp_hook)(const uint8 *frame, const struct week4_ip_info *ip);

#define STAT(f) __sync_fetch_and_add(&week4_stats.f, 1)

#define PING_SLOTS 4
#define WEEK4_TIMEBASE_HZ 10000000   // QEMU virt: `time` CSR runs at 10 MHz (1 tick = 100 ns)

struct ping_slot {
  int    used;
  int    done;       // reply received
  int    timedout;   // set by week4_ip_tick
  uint16 id, seq;
  uint32 dst;
  uint32 deadline;   // in clock ticks
  uint64 t0, t1;     // `time` CSR at send / at receive
  int    ttl, bytes;
};

static struct ping_slot slots[PING_SLOTS];
static struct spinlock icmp_lock;
static uint32 ip_id_ctr;
static int ready;

// High-resolution timestamp. xv6 `ticks` is only 100 ms, far too coarse for an RTT.
// Build with -DWEEK4_USE_TICKS if the S-mode `time` CSR is not accessible on your kernel.
static inline uint64
week4_now(void)
{
#ifdef WEEK4_USE_TICKS
  return (uint64)ticks * (WEEK4_TIMEBASE_HZ / 10);
#else
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
  return x;
#endif
}

static uint16
next_ipid(void)
{
  return (uint16)__sync_fetch_and_add(&ip_id_ctr, 1);
}

void
week4_ip_init(void)
{
  initlock(&icmp_lock, "week4_icmp");
  week4_ip_hook = week4_ip_rx;
  ready = 1;
}

// ------------------------------- RX ---------------------------------------

static void
ping_got_reply(const struct week4_ip_info *ip, const struct week4_icmp_info *ic, uint64 now)
{
  struct ping_slot *s;
  int i, hit;

  if (!week4_echo_check(ic->data, ic->datalen)) {   // corrupted payload: not a valid reply
    STAT(icmp_drop);
    return;
  }
  hit = 0;
  acquire(&icmp_lock);
  for (i = 0; i < PING_SLOTS; i++) {
    s = &slots[i];
    if (s->used && !s->done && !s->timedout &&
        s->id == ic->id && s->seq == ic->seq && s->dst == ip->src) {
      s->t1 = now;
      s->ttl = ip->ttl;
      s->bytes = ip->paylen;
      s->done = 1;
      wakeup(s);
      hit = 1;
      break;
    }
  }
  release(&icmp_lock);
  if (hit)
    STAT(ping_rx);
  else
    STAT(ping_unmatched);   // late (after timeout) or unsolicited
}

static void
icmp_input(const uint8 *frame, const struct week4_ip_info *ip, uint64 now)
{
  struct week4_icmp_info ic;
  uint8 *out;
  int v, n;

  v = week4_icmp_parse(ip, &ic);
  if (v == WEEK4_ICMP_ECHO_REQ) {
    STAT(icmp_echo_req);
    out = kalloc();
    if (out == 0) {
      STAT(tx_nomem);
      return;
    }
    n = week4_icmp_make_reply(frame, ip, &ic, week2_my_mac, out, PGSIZE, next_ipid());
    if (n < 0) {
      kfree(out);
      return;
    }
    STAT(icmp_echo_reply_tx);
    week2_net_tx(out, n);          // takes ownership, frees
  } else if (v == WEEK4_ICMP_ECHO_REPLY) {
    ping_got_reply(ip, &ic, now);
  } else {
    STAT(icmp_drop);
  }
}

// Interrupt context: must not sleep. Called by net_rx through week4_ip_hook.
void
week4_ip_rx(const uint8 *buf, int len)
{
  struct week4_ip_info ip;
  uint64 now;
  int v;

  now = week4_now();               // timestamp as early as possible
  v = week4_ip_parse(buf, len, week2_my_ip, &ip);
  switch (v) {
  case WEEK4_IP_OK:
    break;
  case WEEK4_IP_DROP_CKSUM: STAT(ip_drop_cksum); return;
  case WEEK4_IP_DROP_FRAG:  STAT(ip_drop_frag);  return;
  case WEEK4_IP_DROP_NOT_US: STAT(ip_drop_notus); return;
  case WEEK4_IP_DROP_ADDR:  STAT(ip_drop_addr);  return;
  case WEEK4_IP_DROP_TTL:   STAT(ip_drop_ttl);   return;
  case WEEK4_IP_DROP_SHORT: STAT(ip_drop_short); return;
  default:                  STAT(ip_drop_hdr);   return;
  }
  STAT(ip_ok);

  if (ip.proto == IPPROTO_ICMP)
    icmp_input(buf, &ip, now);
  else if (ip.proto == IPPROTO_UDP && week4_udp_hook)
    week4_udp_hook(buf, &ip);      
  else
    STAT(ip_unsup_proto);
}

// ------------------------------- TX ---------------------------------------

// A zeroed frame buffer plus a pointer to where the L4 payload goes.
uint8 *
week4_ip_alloc(uint8 **payload)
{
  uint8 *b;

  b = kalloc();
  if (b == 0)
    return 0;
  memset(b, 0, ETH_MAX_FRAME);
  *payload = b + WEEK4_IP_PAYLOAD_OFF;
  return b;
}

// Frame must hold `paylen` bytes of L4 payload at frame+34. Fills Ethernet/IP headers and
// goes through the ARP layer (which fills the destination MAC, queueing the frame if needed).
int
week4_ip_send(uint8 *frame, uint32 dst, uint8 proto, int paylen)
{
  int n;

  if (frame == 0)
    return -1;
  n = week4_ip_fill(frame, week2_my_mac, week2_my_ip, dst, proto, next_ipid(), paylen);
  if (n < 0)
    return -1;
  return week3_arp_send(week4_next_hop(dst, week2_my_ip), frame, n);
}

// Called from clockintr on every hart, once per timer interrupt (interrupt context): must not
// sleep. `ticks` itself is advanced by hart 0 only, so the deadline test is idempotent.
void
week4_ip_tick(void)
{
  struct ping_slot *s;
  int i;

  if (!ready)
    return;
  acquire(&icmp_lock);
  for (i = 0; i < PING_SLOTS; i++) {
    s = &slots[i];
    if (s->used && !s->done && !s->timedout && (int)(ticks - s->deadline) >= 0) {
      s->timedout = 1;
      wakeup(s);
    }
  }
  release(&icmp_lock);
#ifdef NET_POLL_RX
  e1000_recv();   // temporary: only if the E1000 RX interrupt is not wired up yet
#endif
}

// ---------------------------- ping syscall --------------------------------
// int ping(uint dst, int seq, int size, int timeout_ticks, int *res)
//   res[0] = RTT in microseconds, res[1] = ttl of the reply, res[2] = ICMP bytes received
//   returns 0 = reply, -1 = timeout, -2 = error (bad args / no memory / no slot / tx failed)
uint64
sys_ping(void)
{
  struct proc *p = myproc();
  struct ping_slot *s;
  uint8 *buf, *pl;
  uint64 resp, delta;
  int dst, seq, size, tmo, i, n, done, res[3];

  argint(0, &dst);
  argint(1, &seq);
  argint(2, &size);
  argint(3, &tmo);
  argaddr(4, &resp);
  if (size < 0 || size > WEEK4_ICMP_MAX_DATA || tmo <= 0 || tmo > 600)
    return -2;

  buf = week4_ip_alloc(&pl);
  if (buf == 0)
    return -2;
  n = week4_icmp_write_echo(pl, WEEK4_ICMP_MAX_DATA + ICMP_HDR_LEN,
                            (uint16)p->pid, (uint16)seq, size);
  if (n < 0) {
    kfree(buf);
    return -2;
  }

  // Claim a slot BEFORE sending: the reply may arrive before we go to sleep.
  acquire(&icmp_lock);
  s = 0;
  for (i = 0; i < PING_SLOTS; i++)
    if (!slots[i].used) {
      s = &slots[i];
      break;
    }
  if (s == 0) {
    release(&icmp_lock);
    kfree(buf);
    return -2;
  }
  s->used = 1;
  s->done = 0;
  s->timedout = 0;
  s->id = (uint16)p->pid;
  s->seq = (uint16)seq;
  s->dst = (uint32)dst;
  s->deadline = ticks + tmo;
  release(&icmp_lock);

  // t0 is taken before ARP resolution, so the first probe to a new next hop includes the ARP
  // round trip (ARP miss); later probes do not (ARP hit). Keep it: the difference is what the

  s->t0 = week4_now();             // only this thread reads t0, and only after done is set
  if (week4_ip_send(buf, (uint32)dst, IPPROTO_ICMP, n) < 0) {
    acquire(&icmp_lock);
    s->used = 0;
    release(&icmp_lock);
    kfree(buf);                    // send failed: we still own the frame
    return -2;
  }
  STAT(ping_tx);

  acquire(&icmp_lock);
  while (!s->done && !s->timedout) {
    if (killed(p)) {
      s->used = 0;
      release(&icmp_lock);
      return -2;
    }
    sleep_prepare(s);              // register on chan while still holding icmp_lock
    release(&icmp_lock);           // a wakeup() after this point is not lost: we are registered
    sleep();
    acquire(&icmp_lock);           // re-take the lock before re-checking done/timedout
  }
  done = s->done;
  delta = s->t1 - s->t0;
  res[0] = (int)(delta / (WEEK4_TIMEBASE_HZ / 1000000));
  res[1] = s->ttl;
  res[2] = s->bytes;
  s->used = 0;
  release(&icmp_lock);

  if (!done) {
    STAT(ping_timeout);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, resp, (char *)res, sizeof(res)) < 0)
    return -2;
  return 0;
}

// ------------------------- diagnostics / selftest -------------------------

void
week4_ip_dump_stats(void)
{
  struct week4_stats *s = &week4_stats;

  printk("week4: ip ok=%d short=%d hdr=%d cksum=%d frag=%d ttl=%d notus=%d addr=%d unsup=%d\n",
         s->ip_ok, s->ip_drop_short, s->ip_drop_hdr, s->ip_drop_cksum, s->ip_drop_frag,
         s->ip_drop_ttl, s->ip_drop_notus, s->ip_drop_addr, s->ip_unsup_proto);
  printk("week4: icmp req=%d reply_tx=%d drop=%d | ping tx=%d rx=%d timeout=%d unmatched=%d\n",
         s->icmp_echo_req, s->icmp_echo_reply_tx, s->icmp_drop, s->ping_tx, s->ping_rx,
         s->ping_timeout, s->ping_unmatched);
}

// Round trip through the pure layer on the real RISC-V build (catches endianness / unaligned
// access problems that a host test cannot). Small buffers: the kernel stack is one page.
void
week4_ip_selftest(void)
{
  static const uint8 peermac[ETHADDR_LEN] = {0x52, 0x55, 0x0a, 0x00, 0x02, 0x02};
  uint8 req[128], rep[128];
  struct week4_ip_info ip;
  struct week4_icmp_info ic;
  uint32 peer = WEEK4_GATEWAY;
  int n, m, i, ok;

  ok = 1;
  n = week4_icmp_write_echo(req + WEEK4_IP_PAYLOAD_OFF, sizeof(req) - WEEK4_IP_PAYLOAD_OFF,
                            0x1234, 7, 16);
  m = week4_ip_fill(req, peermac, peer, week2_my_ip, IPPROTO_ICMP, 1, n);
  for (i = 0; i < ETHADDR_LEN; i++)
    req[i] = week2_my_mac[i];

  if (m < 0 || week4_ip_parse(req, m, week2_my_ip, &ip) != WEEK4_IP_OK ||
      week4_icmp_parse(&ip, &ic) != WEEK4_ICMP_ECHO_REQ || ic.id != 0x1234 || ic.seq != 7)
    ok = 0;
  if (ok) {
    n = week4_icmp_make_reply(req, &ip, &ic, week2_my_mac, rep, sizeof(rep), 2);
    if (n < 0 || week4_ip_parse(rep, n, peer, &ip) != WEEK4_IP_OK ||
        week4_icmp_parse(&ip, &ic) != WEEK4_ICMP_ECHO_REPLY || ic.id != 0x1234 ||
        ic.seq != 7 || ic.datalen != 16 || !week4_echo_check(ic.data, ic.datalen))
      ok = 0;
    for (i = 0; ok && i < ETHADDR_LEN; i++)
      if (rep[i] != peermac[i])
        ok = 0;
  }
  printk("week4: IP/ICMP selftest %s\n", ok ? "PASS" : "FAIL");
}
