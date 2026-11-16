// udp_echo [port] [count]
// mac dinh port = 2000, count = 0

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define BUFSZ 1500

static char buf[BUFSZ];

static void
print_ip(uint32 ip)
{
  printf("%d.%d.%d.%d", (ip >> 24) & 0xff, (ip >> 16) & 0xff,
         (ip >> 8) & 0xff, ip & 0xff);
}

int
main(int argc, char *argv[])
{
  int port = 2000, count = 0, verbose = 1;
  int fd, n, i, sport;
  uint32 sip;

  if (argc > 1)
    port = atoi(argv[1]);
  if (argc > 2)
    count = atoi(argv[2]);
  if (argc > 3 && strcmp(argv[3], "-q") == 0)
    verbose = 0;
  if (port <= 0 || port > 65535 || count < 0) { // kiem tra cong va so luong goi tin hop le
    fprintf(2, "usage: udp_echo [port] [count] [-q]\n");
    exit(1);
  }

  // khoi tao va bind UDP socket
  if ((fd = socket()) < 0) {
    fprintf(2, "udp_echo: socket failed\n");
    exit(1);
  }
  if (bind(fd, port) < 0) {
    fprintf(2, "udp_echo: bind %d failed\n", port);
    close(fd);
    exit(1);
  }
  printf("udp_echo: listening on port %d\n", port);

  // vong lap chinh
  for (i = 0; count == 0 || i < count; i++) {
    n = recvfrom(fd, buf, sizeof(buf), &sip, &sport); // cho goi tin udp, luu ip va port nguon 
    if (n < 0) {
      fprintf(2, "udp_echo: recvfrom failed\n");
      break;
    }
    // in thong tin
    if (verbose) {
      printf("udp_echo: %d bytes from ", n);
      print_ip(sip);
      printf(":%d\n", sport);
    }
    // gui tra lai n byte ve dung ip va port nguon
    if (sendto(fd, buf, n, sip, sport) != n) {
      fprintf(2, "udp_echo: sendto failed\n");
      break;
    }
  }
  close(fd);
  exit(0);
}