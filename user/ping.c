#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// usage: ping <a.b.c.d> [count] [data_bytes] [timeout_ticks]
// Output mimics Linux ping. 1 s = 10 ticks in xv6.
// Exit status: 0 if at least one reply was received, 1 otherwise (timeouts, errors, bad usage).

#define TIMEOUT_TICKS 30      // default: wait up to 3 s for each reply
#define MAX_TIMEOUT_TICKS 600 // kernel limit (sys_ping rejects larger values)
#define INTERVAL_TICKS 10     // 1 s between probes

static int
parse_ip(char *s, uint *out)
{
  uint v = 0;
  int part, n, i;

  for (i = 0; i < 4; i++) {
    if (*s < '0' || *s > '9')
      return -1;
    part = 0;
    n = 0;
    while (*s >= '0' && *s <= '9') {
      part = part * 10 + (*s - '0');
      if (part > 255 || ++n > 3)
        return -1;
      s++;
    }
    v = (v << 8) | part;
    if (i < 3) {
      if (*s != '.')
        return -1;
      s++;
    }
  }
  if (*s != 0)
    return -1;
  *out = v;
  return 0;
}

// Prints microseconds as milliseconds with 3 decimals (xv6 printf has no %f / width).
static void
print_ms(uint64 us)
{
  uint ms = us / 1000, f = us % 1000;

  printf("%d.%d%d%d", ms, f / 100, (f / 10) % 10, f % 10);
}

static uint64
isqrt(uint64 x)
{
  uint64 r = 0, bit = 1ULL << 62;

  while (bit > x)
    bit >>= 2;
  while (bit) {
    if (x >= r + bit) {
      x -= r + bit;
      r = (r >> 1) + bit;
    } else
      r >>= 1;
    bit >>= 2;
  }
  return r;
}

int
main(int argc, char *argv[])
{
  uint dst;
  int count = 4, size = 56, tmo = TIMEOUT_TICKS, seq, r, res[3];
  int sent = 0, recvd = 0, errs = 0;
  uint64 sum = 0, sumsq = 0, min = ~0ULL, max = 0, avg, var;

  if (argc < 2 || parse_ip(argv[1], &dst) < 0) {
    fprintf(2, "usage: ping a.b.c.d [count] [data_bytes] [timeout_ticks]\n");
    exit(1);
  }
  if (argc > 2)
    count = atoi(argv[2]);
  if (argc > 3)
    size = atoi(argv[3]);
  if (argc > 4)
    tmo = atoi(argv[4]);
  if (count < 1 || size < 0 || size > 1472) {
    fprintf(2, "ping: count must be >= 1 and data_bytes in 0..1472\n");
    exit(1);
  }
  if (tmo < 1 || tmo > MAX_TIMEOUT_TICKS) {
    fprintf(2, "ping: timeout_ticks must be in 1..%d\n", MAX_TIMEOUT_TICKS);
    exit(1);
  }

  printf("PING %s: %d data bytes\n", argv[1], size);
  for (seq = 1; seq <= count; seq++) {
    r = ping(dst, seq, size, tmo, res);
    sent++;
    if (r == 0) {
      uint64 us = res[0];
      recvd++;
      sum += us;
      sumsq += us * us;
      if (us < min)
        min = us;
      if (us > max)
        max = us;
      printf("%d bytes from %s: icmp_seq=%d ttl=%d time=", res[2], argv[1], seq, res[1]);
      print_ms(us);
      printf(" ms\n");
    } else if (r == -1) {
      printf("Request timeout for icmp_seq %d\n", seq);
    } else {
      errs++;
      printf("ping: error sending icmp_seq %d\n", seq);
    }
    if (seq < count)
      pause(INTERVAL_TICKS);
  }

  printf("--- %s ping statistics ---\n", argv[1]);
  printf("%d packets transmitted, %d received, ", sent, recvd);
  if (errs)
    printf("%d errors, ", errs);
  printf("%d%% packet loss\n", (sent - recvd) * 100 / sent);
  if (recvd > 0) {
    avg = sum / recvd;
    var = sumsq / recvd - avg * avg;
    printf("rtt min/avg/max/mdev = ");
    print_ms(min);
    printf("/");
    print_ms(avg);
    printf("/");
    print_ms(max);
    printf("/");
    print_ms(isqrt(var));
    printf(" ms\n");
  }
  exit(recvd > 0 ? 0 : 1);
}
