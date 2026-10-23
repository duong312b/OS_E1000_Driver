// net.c - Checksum Internet (RFC 1071).
// Bat bien: du lieu duoc xem la chuoi byte; moi cap byte (b0,b1) la tu 16 bit
// big-endian (b0<<8|b1). Do dai le: byte cuoi duoc dem nhu byte cao, byte thap = 0.
#include "types.h"
#include "net.h"

// Cong don vao tong 32 bit (chua gap carry). Tran 32 bit chi xay ra khi
// len > ~128 KB, xa lon hon MTU nen khong can xu ly.
// Cung dung duoc de noi nhieu vung: chi dung neu moi vung tru vung cuoi
// co do dai CHAN (pseudo-header UDP = 12 byte, header = 8 byte -> thoa).
uint32
cksum_partial(uint32 sum, const void *buf, int len)
{
  const uint8 *p = (const uint8 *)buf;

  while (len > 1) {
    sum += ((uint32)p[0] << 8) | p[1];
    p += 2;
    len -= 2;
  }
  if (len == 1)
    sum += (uint32)p[0] << 8;
  return sum;
}

uint16
cksum_finish(uint32 sum)
{
  while (sum >> 16)
    sum = (sum & 0xffff) + (sum >> 16);
  return htons((uint16)~sum);
}

uint16
in_cksum(const void *buf, int len)
{
  return cksum_finish(cksum_partial(0, buf, len));
}
