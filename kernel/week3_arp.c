#include "types.h"
#include "net.h"

static int
age_of(uint32 now, uint32 stamp)
{
  return (int)(now - stamp);
}

static int
mac_zero(const uint8 *m)
{
  int i;

  for (i = 0; i < ETHADDR_LEN; i++)
    if (m[i] != 0)
      return 0;
  return 1;
}

static void
entry_free(struct week3_arp_entry *e)
{
  int i;

  e->state = WEEK3_ARP_FREE;
  e->tries = 0;
  e->nq = 0;
  e->ip = 0;
  e->stamp = 0;
  e->last_req = 0;
  for (i = 0; i < ETHADDR_LEN; i++)
    e->mac[i] = 0;
  for (i = 0; i < WEEK3_ARP_QUEUE; i++) {
    e->q[i] = 0;
    e->qlen[i] = 0;
  }
}

static void
entry_take_queue(struct week3_arp_entry *e, struct week3_arp_pkts *out)
{
  int i;

  for (i = 0; i < e->nq; i++) {
    out->buf[out->n] = e->q[i];
    out->len[out->n] = e->qlen[i];
    out->n++;
    e->q[i] = 0;
    e->qlen[i] = 0;
  }
  e->nq = 0;
}

void
week3_arp_cache_init(struct week3_arp_cache *c)
{
  int i;

  for (i = 0; i < WEEK3_ARP_ENTRIES; i++)
    entry_free(&c->e[i]);
}

static struct week3_arp_entry *
find_raw(struct week3_arp_cache *c, uint32 ip)
{
  int i;

  for (i = 0; i < WEEK3_ARP_ENTRIES; i++)
    if (c->e[i].state != WEEK3_ARP_FREE && c->e[i].ip == ip)
      return &c->e[i];
  return 0;
}

static struct week3_arp_entry *
find(struct week3_arp_cache *c, uint32 ip, uint32 now)
{
  struct week3_arp_entry *e;

  e = find_raw(c, ip);
  if (e && e->state == WEEK3_ARP_VALID && age_of(now, e->stamp) >= WEEK3_ARP_TTL) {
    entry_free(e);
    return 0;
  }
  return e;
}

static struct week3_arp_entry *
alloc_entry(struct week3_arp_cache *c, uint32 now, struct week3_arp_pkts *drop)
{
  struct week3_arp_entry *best;
  int i, age, bestage, pass;
  static const int order[2] = {WEEK3_ARP_VALID, WEEK3_ARP_INCOMPLETE};

  for (i = 0; i < WEEK3_ARP_ENTRIES; i++)
    if (c->e[i].state == WEEK3_ARP_FREE)
      return &c->e[i];

  best = 0;
  bestage = 0;
  for (pass = 0; pass < 2 && best == 0; pass++) {
    for (i = 0; i < WEEK3_ARP_ENTRIES; i++) {
      if (c->e[i].state != order[pass])
        continue;
      age = age_of(now, c->e[i].stamp);
      if (best == 0 || age > bestage) {
        best = &c->e[i];
        bestage = age;
      }
    }
  }
  entry_take_queue(best, drop);
  entry_free(best);
  return best;
}

int
week3_arp_lookup(struct week3_arp_cache *c, uint32 ip, uint32 now, uint8 *mac)
{
  struct week3_arp_entry *e;
  int i;

  e = find(c, ip, now);
  if (e == 0)
    return WEEK3_ARP_MISS;
  if (e->state == WEEK3_ARP_INCOMPLETE)
    return WEEK3_ARP_WAIT;
  if (mac)
    for (i = 0; i < ETHADDR_LEN; i++)
      mac[i] = e->mac[i];
  return WEEK3_ARP_HIT;
}

int
week3_arp_learn(struct week3_arp_cache *c, uint32 ip, const uint8 *mac, uint32 now,
                struct week3_arp_pkts *send, struct week3_arp_pkts *drop)
{
  struct week3_arp_entry *e;
  int i, j, fresh;

  if (c == 0 || mac == 0 || send == 0 || drop == 0 || ip == 0)
    return -1;
  send->n = 0;
  drop->n = 0;

  fresh = 0;
  e = find(c, ip, now);
  if (e == 0) {
    e = alloc_entry(c, now, drop);
    e->ip = ip;
    fresh = 1;
  }
  for (i = 0; i < ETHADDR_LEN; i++)
    e->mac[i] = mac[i];
  e->state = WEEK3_ARP_VALID;
  e->stamp = now;
  e->tries = 0;

  for (i = 0; i < e->nq; i++)
    for (j = 0; j < ETHADDR_LEN; j++)
      e->q[i][j] = mac[j];
  entry_take_queue(e, send);
  return fresh;
}

int
week3_arp_begin(struct week3_arp_cache *c, uint32 ip, uint32 now, struct week3_arp_pkts *drop)
{
  struct week3_arp_entry *e;

  if (c == 0 || drop == 0 || ip == 0)
    return -1;
  drop->n = 0;

  if (find(c, ip, now))
    return 0;
  e = alloc_entry(c, now, drop);
  e->state = WEEK3_ARP_INCOMPLETE;
  e->ip = ip;
  e->tries = 1;
  e->stamp = now;
  e->last_req = now;
  return 1;
}

int
week3_arp_enqueue(struct week3_arp_cache *c, uint32 ip, uint8 *buf, int len)
{
  struct week3_arp_entry *e;

  if (c == 0 || buf == 0 || len < ETH_HDR_LEN)
    return -3;
  e = find_raw(c, ip);
  if (e == 0 || e->state != WEEK3_ARP_INCOMPLETE)
    return -2;
  if (e->nq >= WEEK3_ARP_QUEUE)
    return -1;
  e->q[e->nq] = buf;
  e->qlen[e->nq] = len;
  e->nq++;
  return 0;
}

void
week3_arp_timer(struct week3_arp_cache *c, uint32 now, struct week3_arp_timer_out *out)
{
  struct week3_arp_entry *e;
  int i, k;

  out->nreq = 0;
  out->ndrop = 0;
  for (i = 0; i < WEEK3_ARP_ENTRIES; i++) {
    e = &c->e[i];
    if (e->state == WEEK3_ARP_VALID) {
      if (age_of(now, e->stamp) >= WEEK3_ARP_TTL)
        entry_free(e);
    } else if (e->state == WEEK3_ARP_INCOMPLETE) {
      if (age_of(now, e->last_req) < WEEK3_ARP_RETRY)
        continue;
      if (e->tries < WEEK3_ARP_MAX_TRIES) {
        e->tries++;
        e->last_req = now;
        out->req_ip[out->nreq++] = e->ip;
      } else {
        for (k = 0; k < e->nq; k++) {
          out->drop_buf[out->ndrop] = e->q[k];
          out->drop_len[out->ndrop] = e->qlen[k];
          out->ndrop++;
        }
        e->nq = 0;
        entry_free(e);
      }
    }
  }
}

int
week3_arp_process(struct week3_arp_cache *c, const uint8 *frame, int len,
                  const uint8 *mymac, uint32 myip, uint32 now,
                  uint8 *reply, int replymax,
                  struct week3_arp_pkts *send, struct week3_arp_pkts *drop)
{
  const struct eth *e;
  const struct arp *a;
  struct eth *re;
  struct arp *ra;
  uint32 sip, tip;
  int op, i, mac_ok, ip_ok;

  if (send == 0 || drop == 0)
    return -1;
  send->n = 0;
  drop->n = 0;
  if (c == 0 || frame == 0 || mymac == 0 || reply == 0 ||
      replymax < ETH_MIN_FRAME || len < ETH_HDR_LEN + ARP_HDR_LEN)
    return -1;

  e = (const struct eth *)frame;
  a = (const struct arp *)(frame + ETH_HDR_LEN);
  if (ntohs(e->type) != ETHTYPE_ARP)
    return -1;
  if (ntohs(a->hrd) != ARP_HRD_ETHER || ntohs(a->pro) != ETHTYPE_IP ||
      a->hln != ETHADDR_LEN || a->pln != 4)
    return -1;
  op = ntohs(a->op);
  if (op != ARP_OP_REQUEST && op != ARP_OP_REPLY)
    return -1;

  sip = ntohl(a->sip);
  tip = ntohl(a->tip);
  if (sip == myip)
    return 0;

  mac_ok = !mac_zero(a->sha) && !(a->sha[0] & 1);
  ip_ok = sip != 0 && sip != 0xffffffff;

  if (mac_ok && ip_ok && (find(c, sip, now) != 0 || tip == myip))
    week3_arp_learn(c, sip, a->sha, now, send, drop);

  if (op != ARP_OP_REQUEST || tip != myip || !mac_ok)
    return 0;

  for (i = 0; i < ETH_MIN_FRAME; i++)
    reply[i] = 0;
  re = (struct eth *)reply;
  ra = (struct arp *)(reply + ETH_HDR_LEN);
  for (i = 0; i < ETHADDR_LEN; i++) {
    re->dhost[i] = a->sha[i];
    re->shost[i] = mymac[i];
    ra->sha[i] = mymac[i];
    ra->tha[i] = a->sha[i];
  }
  re->type = htons(ETHTYPE_ARP);
  ra->hrd = htons(ARP_HRD_ETHER);
  ra->pro = htons(ETHTYPE_IP);
  ra->hln = ETHADDR_LEN;
  ra->pln = 4;
  ra->op = htons(ARP_OP_REPLY);
  ra->sip = htonl(myip);
  ra->tip = a->sip;
  return ETH_MIN_FRAME;
}
