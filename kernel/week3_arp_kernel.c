#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "net.h"

extern uint ticks;

struct week3_arp_cache week3_arpc;
struct spinlock week3_arp_lock;
static int week3_arp_ready;

static void
dispose(struct week3_arp_pkts *p)
{
  int i;

  for (i = 0; i < p->n; i++)
    kfree(p->buf[i]);
}

static void
transmit(struct week3_arp_pkts *p)
{
  int i;

  for (i = 0; i < p->n; i++)
    week2_net_tx(p->buf[i], p->len[i]);
}

void
week3_arp_init(void)
{
  initlock(&week3_arp_lock, "week3_arp");
  week3_arp_cache_init(&week3_arpc);
  week3_arp_hook = week3_arp_rx;
  week3_arp_ready = 1;
}

// Runs in interrupt context: holds the spinlock only while touching the cache, never sleeps.
void
week3_arp_rx(const uint8 *buf, int len)
{
  uint8 rep[ETH_MIN_FRAME];
  struct week3_arp_pkts send, drop;
  uint8 *out;
  int n;

  send.n = 0;
  drop.n = 0;
  acquire(&week3_arp_lock);
  n = week3_arp_process(&week3_arpc, buf, len, week2_my_mac, week2_my_ip, ticks,
                        rep, sizeof(rep), &send, &drop);
  release(&week3_arp_lock);

  dispose(&drop);
  transmit(&send);
  if (n > 0) {
    out = kalloc();
    if (out) {
      memmove(out, rep, n);
      week2_net_tx(out, n);
    }
  }
}

int
week3_arp_send(uint32 ip, uint8 *frame, int len)
{
  struct week3_arp_pkts drop;
  uint8 mac[ETHADDR_LEN];
  int r, i, started;

  if (frame == 0 || len < ETH_HDR_LEN)
    return -1;

  started = 0;
  drop.n = 0;
  acquire(&week3_arp_lock);
  r = week3_arp_lookup(&week3_arpc, ip, ticks, mac);
  if (r == WEEK3_ARP_HIT) {
    release(&week3_arp_lock);
    for (i = 0; i < ETHADDR_LEN; i++)
      frame[i] = mac[i];
    return week2_net_tx(frame, len);
  }
  if (r == WEEK3_ARP_MISS)
    started = week3_arp_begin(&week3_arpc, ip, ticks, &drop);
  r = week3_arp_enqueue(&week3_arpc, ip, frame, len);
  release(&week3_arp_lock);

  dispose(&drop);
  if (started == 1)
    week2_arp_send_request(ip);
  return r < 0 ? -1 : 0;
}

// Called from clockintr on hart 0 once per tick (interrupt context): must not sleep.
void
week3_arp_tick(void)
{
  struct week3_arp_timer_out out;
  int i;

  if (!week3_arp_ready)
    return;
  acquire(&week3_arp_lock);
  week3_arp_timer(&week3_arpc, ticks, &out);
  release(&week3_arp_lock);

  for (i = 0; i < out.ndrop; i++)
    kfree(out.drop_buf[i]);
  for (i = 0; i < out.nreq; i++)
    week2_arp_send_request(out.req_ip[i]);
}


void
week3_arp_selftest(void)
{
  uint32 gateway_ip;
  uint8 *f;
  int i;

  // Gateway cua QEMU user-mode networking.
  gateway_ip = MAKE_IP_ADDR(10, 0, 2, 2);

  f = kalloc();
  if (f == 0) {
    printk("week3: ARP selftest allocation failed\n");
    return;
  }

  // Tao Ethernet frame gia lap can gui den gateway.
  for (i = 0; i < ETH_MIN_FRAME; i++)
    f[i] = 0;

  // Source MAC = MAC cua xv6.
  for (i = 0; i < ETHADDR_LEN; i++)
    f[ETHADDR_LEN + i] = week2_my_mac[i];

  // EtherType = IPv4.
  f[12] = 0x08;
  f[13] = 0x00;

  // Payload danh dau de kiem tra.
  f[14] = 0xde;
  f[15] = 0xad;
  f[16] = 0xbe;
  f[17] = 0xef;

  printk("week3: resolve gateway 10.0.2.2\n");

  // Cache ban dau chua co MAC gateway:
  // week3_arp_send se enqueue frame va phat ARP request.
  if (week3_arp_send(gateway_ip, f, ETH_MIN_FRAME) < 0) {
    printk("week3: ARP send failed\n");
    kfree(f);
  }
}

