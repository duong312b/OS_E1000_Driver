
user/_nettests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_harness_sanity>:
    printf("  check failed: %s (dòng %d)\n", #cond, __LINE__); return -1; } } while (0)

struct test { const char *name; int (*fn)(void); };

// ---- Các test (tuần 1 chỉ có khung; test thật thêm từ tuần 2) --------
static int test_harness_sanity(void) { CHECK(1 + 1 == 2); return 0; }
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
   6:	4501                	li	a0,0
   8:	6422                	ld	s0,8(sp)
   a:	0141                	addi	sp,sp,16
   c:	8082                	ret

000000000000000e <test_fork_wait>:

static int test_fork_wait(void) {      // chạy được tiến trình con (nền cho test đồng thời)
   e:	7179                	addi	sp,sp,-48
  10:	f406                	sd	ra,40(sp)
  12:	f022                	sd	s0,32(sp)
  14:	1800                	addi	s0,sp,48
  int pid = fork();
  16:	3f0000ef          	jal	406 <fork>
  CHECK(pid >= 0);
  1a:	02054963          	bltz	a0,4c <test_fork_wait+0x3e>
  1e:	ec26                	sd	s1,24(sp)
  20:	84aa                	mv	s1,a0
  if (pid == 0) exit(7);
  22:	c131                	beqz	a0,66 <test_fork_wait+0x58>
  int st = -1;
  24:	57fd                	li	a5,-1
  26:	fcf42e23          	sw	a5,-36(s0)
  CHECK(wait(&st) == pid);
  2a:	fdc40513          	addi	a0,s0,-36
  2e:	3e8000ef          	jal	416 <wait>
  32:	02951d63          	bne	a0,s1,6c <test_fork_wait+0x5e>
  CHECK(st == 7);
  36:	fdc42703          	lw	a4,-36(s0)
  3a:	479d                	li	a5,7
  return 0;
  3c:	4501                	li	a0,0
  CHECK(st == 7);
  3e:	04f71563          	bne	a4,a5,88 <test_fork_wait+0x7a>
  42:	64e2                	ld	s1,24(sp)
}
  44:	70a2                	ld	ra,40(sp)
  46:	7402                	ld	s0,32(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret
  CHECK(pid >= 0);
  4c:	4651                	li	a2,20
  4e:	00001597          	auipc	a1,0x1
  52:	9a258593          	addi	a1,a1,-1630 # 9f0 <malloc+0xfe>
  56:	00001517          	auipc	a0,0x1
  5a:	9aa50513          	addi	a0,a0,-1622 # a00 <malloc+0x10e>
  5e:	7e0000ef          	jal	83e <printf>
  62:	557d                	li	a0,-1
  64:	b7c5                	j	44 <test_fork_wait+0x36>
  if (pid == 0) exit(7);
  66:	451d                	li	a0,7
  68:	3a6000ef          	jal	40e <exit>
  CHECK(wait(&st) == pid);
  6c:	465d                	li	a2,23
  6e:	00001597          	auipc	a1,0x1
  72:	9b258593          	addi	a1,a1,-1614 # a20 <malloc+0x12e>
  76:	00001517          	auipc	a0,0x1
  7a:	98a50513          	addi	a0,a0,-1654 # a00 <malloc+0x10e>
  7e:	7c0000ef          	jal	83e <printf>
  82:	557d                	li	a0,-1
  84:	64e2                	ld	s1,24(sp)
  86:	bf7d                	j	44 <test_fork_wait+0x36>
  CHECK(st == 7);
  88:	4661                	li	a2,24
  8a:	00001597          	auipc	a1,0x1
  8e:	9ae58593          	addi	a1,a1,-1618 # a38 <malloc+0x146>
  92:	00001517          	auipc	a0,0x1
  96:	96e50513          	addi	a0,a0,-1682 # a00 <malloc+0x10e>
  9a:	7a4000ef          	jal	83e <printf>
  9e:	557d                	li	a0,-1
  a0:	64e2                	ld	s1,24(sp)
  a2:	b74d                	j	44 <test_fork_wait+0x36>

00000000000000a4 <main>:
  { "fork_wait",      test_fork_wait },
};

int
main(void)
{
  a4:	1101                	addi	sp,sp,-32
  a6:	ec06                	sd	ra,24(sp)
  a8:	e822                	sd	s0,16(sp)
  aa:	e426                	sd	s1,8(sp)
  ac:	1000                	addi	s0,sp,32
  int n = sizeof(tests) / sizeof(tests[0]);
  for (int i = 0; i < n; i++) {
    if (tests[i].fn() == 0) { printf("PASS: %s\n", tests[i].name); npass++; }
  ae:	f53ff0ef          	jal	0 <test_harness_sanity>
  b2:	c141                	beqz	a0,132 <main+0x8e>
    else                    { printf("FAIL: %s\n", tests[i].name); nfail++; }
  b4:	00001597          	auipc	a1,0x1
  b8:	98c58593          	addi	a1,a1,-1652 # a40 <malloc+0x14e>
  bc:	00001517          	auipc	a0,0x1
  c0:	99450513          	addi	a0,a0,-1644 # a50 <malloc+0x15e>
  c4:	77a000ef          	jal	83e <printf>
  c8:	00001717          	auipc	a4,0x1
  cc:	f3870713          	addi	a4,a4,-200 # 1000 <nfail>
  d0:	431c                	lw	a5,0(a4)
  d2:	2785                	addiw	a5,a5,1
  d4:	c31c                	sw	a5,0(a4)
    if (tests[i].fn() == 0) { printf("PASS: %s\n", tests[i].name); npass++; }
  d6:	f39ff0ef          	jal	e <test_fork_wait>
  da:	ed35                	bnez	a0,156 <main+0xb2>
  dc:	00001597          	auipc	a1,0x1
  e0:	99458593          	addi	a1,a1,-1644 # a70 <malloc+0x17e>
  e4:	00001517          	auipc	a0,0x1
  e8:	97c50513          	addi	a0,a0,-1668 # a60 <malloc+0x16e>
  ec:	752000ef          	jal	83e <printf>
  f0:	00001717          	auipc	a4,0x1
  f4:	f1470713          	addi	a4,a4,-236 # 1004 <npass>
  f8:	431c                	lw	a5,0(a4)
  fa:	2785                	addiw	a5,a5,1
  fc:	c31c                	sw	a5,0(a4)
  }
  printf("NETTESTS: %d passed, %d failed\n", npass, nfail);
  fe:	00001497          	auipc	s1,0x1
 102:	f0248493          	addi	s1,s1,-254 # 1000 <nfail>
 106:	4090                	lw	a2,0(s1)
 108:	00001597          	auipc	a1,0x1
 10c:	efc5a583          	lw	a1,-260(a1) # 1004 <npass>
 110:	00001517          	auipc	a0,0x1
 114:	97050513          	addi	a0,a0,-1680 # a80 <malloc+0x18e>
 118:	726000ef          	jal	83e <printf>
  printf("NETTESTS DONE\n");
 11c:	00001517          	auipc	a0,0x1
 120:	98450513          	addi	a0,a0,-1660 # aa0 <malloc+0x1ae>
 124:	71a000ef          	jal	83e <printf>
  exit(nfail ? 1 : 0);
 128:	4088                	lw	a0,0(s1)
 12a:	00a03533          	snez	a0,a0
 12e:	2e0000ef          	jal	40e <exit>
    if (tests[i].fn() == 0) { printf("PASS: %s\n", tests[i].name); npass++; }
 132:	00001597          	auipc	a1,0x1
 136:	90e58593          	addi	a1,a1,-1778 # a40 <malloc+0x14e>
 13a:	00001517          	auipc	a0,0x1
 13e:	92650513          	addi	a0,a0,-1754 # a60 <malloc+0x16e>
 142:	6fc000ef          	jal	83e <printf>
 146:	00001717          	auipc	a4,0x1
 14a:	ebe70713          	addi	a4,a4,-322 # 1004 <npass>
 14e:	431c                	lw	a5,0(a4)
 150:	2785                	addiw	a5,a5,1
 152:	c31c                	sw	a5,0(a4)
 154:	b749                	j	d6 <main+0x32>
    else                    { printf("FAIL: %s\n", tests[i].name); nfail++; }
 156:	00001597          	auipc	a1,0x1
 15a:	91a58593          	addi	a1,a1,-1766 # a70 <malloc+0x17e>
 15e:	00001517          	auipc	a0,0x1
 162:	8f250513          	addi	a0,a0,-1806 # a50 <malloc+0x15e>
 166:	6d8000ef          	jal	83e <printf>
 16a:	00001717          	auipc	a4,0x1
 16e:	e9670713          	addi	a4,a4,-362 # 1000 <nfail>
 172:	431c                	lw	a5,0(a4)
 174:	2785                	addiw	a5,a5,1
 176:	c31c                	sw	a5,0(a4)
 178:	b759                	j	fe <main+0x5a>

000000000000017a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e406                	sd	ra,8(sp)
 17e:	e022                	sd	s0,0(sp)
 180:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 182:	f23ff0ef          	jal	a4 <main>
  exit(r);
 186:	288000ef          	jal	40e <exit>

000000000000018a <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 190:	87aa                	mv	a5,a0
 192:	0585                	addi	a1,a1,1
 194:	0785                	addi	a5,a5,1
 196:	fff5c703          	lbu	a4,-1(a1)
 19a:	fee78fa3          	sb	a4,-1(a5)
 19e:	fb75                	bnez	a4,192 <strcpy+0x8>
    ;
  return os;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb91                	beqz	a5,1c4 <strcmp+0x1e>
 1b2:	0005c703          	lbu	a4,0(a1)
 1b6:	00f71763          	bne	a4,a5,1c4 <strcmp+0x1e>
    p++, q++;
 1ba:	0505                	addi	a0,a0,1
 1bc:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	fbe5                	bnez	a5,1b2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1c4:	0005c503          	lbu	a0,0(a1)
}
 1c8:	40a7853b          	subw	a0,a5,a0
 1cc:	6422                	ld	s0,8(sp)
 1ce:	0141                	addi	sp,sp,16
 1d0:	8082                	ret

00000000000001d2 <strlen>:

uint
strlen(const char *s)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e422                	sd	s0,8(sp)
 1d6:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	cf91                	beqz	a5,1f8 <strlen+0x26>
 1de:	0505                	addi	a0,a0,1
 1e0:	87aa                	mv	a5,a0
 1e2:	86be                	mv	a3,a5
 1e4:	0785                	addi	a5,a5,1
 1e6:	fff7c703          	lbu	a4,-1(a5)
 1ea:	ff65                	bnez	a4,1e2 <strlen+0x10>
 1ec:	40a6853b          	subw	a0,a3,a0
 1f0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret
  for (n = 0; s[n]; n++)
 1f8:	4501                	li	a0,0
 1fa:	bfe5                	j	1f2 <strlen+0x20>

00000000000001fc <memset>:

void *
memset(void *dst, int c, uint n)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e422                	sd	s0,8(sp)
 200:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 202:	ca19                	beqz	a2,218 <memset+0x1c>
 204:	87aa                	mv	a5,a0
 206:	1602                	slli	a2,a2,0x20
 208:	9201                	srli	a2,a2,0x20
 20a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 20e:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 212:	0785                	addi	a5,a5,1
 214:	fee79de3          	bne	a5,a4,20e <memset+0x12>
  }
  return dst;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret

000000000000021e <strchr>:

char *
strchr(const char *s, char c)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  for (; *s; s++)
 224:	00054783          	lbu	a5,0(a0)
 228:	cb99                	beqz	a5,23e <strchr+0x20>
    if (*s == c)
 22a:	00f58763          	beq	a1,a5,238 <strchr+0x1a>
  for (; *s; s++)
 22e:	0505                	addi	a0,a0,1
 230:	00054783          	lbu	a5,0(a0)
 234:	fbfd                	bnez	a5,22a <strchr+0xc>
      return (char *)s;
  return 0;
 236:	4501                	li	a0,0
}
 238:	6422                	ld	s0,8(sp)
 23a:	0141                	addi	sp,sp,16
 23c:	8082                	ret
  return 0;
 23e:	4501                	li	a0,0
 240:	bfe5                	j	238 <strchr+0x1a>

0000000000000242 <gets>:

char *
gets(char *buf, int max)
{
 242:	711d                	addi	sp,sp,-96
 244:	ec86                	sd	ra,88(sp)
 246:	e8a2                	sd	s0,80(sp)
 248:	e4a6                	sd	s1,72(sp)
 24a:	e0ca                	sd	s2,64(sp)
 24c:	fc4e                	sd	s3,56(sp)
 24e:	f852                	sd	s4,48(sp)
 250:	f456                	sd	s5,40(sp)
 252:	f05a                	sd	s6,32(sp)
 254:	ec5e                	sd	s7,24(sp)
 256:	1080                	addi	s0,sp,96
 258:	8baa                	mv	s7,a0
 25a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 25c:	892a                	mv	s2,a0
 25e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 260:	4aa9                	li	s5,10
 262:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 264:	89a6                	mv	s3,s1
 266:	2485                	addiw	s1,s1,1
 268:	0344d663          	bge	s1,s4,294 <gets+0x52>
    cc = read(0, &c, 1);
 26c:	4605                	li	a2,1
 26e:	faf40593          	addi	a1,s0,-81
 272:	4501                	li	a0,0
 274:	1b2000ef          	jal	426 <read>
    if (cc < 1)
 278:	00a05e63          	blez	a0,294 <gets+0x52>
    buf[i++] = c;
 27c:	faf44783          	lbu	a5,-81(s0)
 280:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 284:	01578763          	beq	a5,s5,292 <gets+0x50>
 288:	0905                	addi	s2,s2,1
 28a:	fd679de3          	bne	a5,s6,264 <gets+0x22>
    buf[i++] = c;
 28e:	89a6                	mv	s3,s1
 290:	a011                	j	294 <gets+0x52>
 292:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 294:	99de                	add	s3,s3,s7
 296:	00098023          	sb	zero,0(s3)
  return buf;
}
 29a:	855e                	mv	a0,s7
 29c:	60e6                	ld	ra,88(sp)
 29e:	6446                	ld	s0,80(sp)
 2a0:	64a6                	ld	s1,72(sp)
 2a2:	6906                	ld	s2,64(sp)
 2a4:	79e2                	ld	s3,56(sp)
 2a6:	7a42                	ld	s4,48(sp)
 2a8:	7aa2                	ld	s5,40(sp)
 2aa:	7b02                	ld	s6,32(sp)
 2ac:	6be2                	ld	s7,24(sp)
 2ae:	6125                	addi	sp,sp,96
 2b0:	8082                	ret

00000000000002b2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2b2:	1101                	addi	sp,sp,-32
 2b4:	ec06                	sd	ra,24(sp)
 2b6:	e822                	sd	s0,16(sp)
 2b8:	e04a                	sd	s2,0(sp)
 2ba:	1000                	addi	s0,sp,32
 2bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2be:	4581                	li	a1,0
 2c0:	18e000ef          	jal	44e <open>
  if (fd < 0)
 2c4:	02054263          	bltz	a0,2e8 <stat+0x36>
 2c8:	e426                	sd	s1,8(sp)
 2ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2cc:	85ca                	mv	a1,s2
 2ce:	198000ef          	jal	466 <fstat>
 2d2:	892a                	mv	s2,a0
  close(fd);
 2d4:	8526                	mv	a0,s1
 2d6:	160000ef          	jal	436 <close>
  return r;
 2da:	64a2                	ld	s1,8(sp)
}
 2dc:	854a                	mv	a0,s2
 2de:	60e2                	ld	ra,24(sp)
 2e0:	6442                	ld	s0,16(sp)
 2e2:	6902                	ld	s2,0(sp)
 2e4:	6105                	addi	sp,sp,32
 2e6:	8082                	ret
    return -1;
 2e8:	597d                	li	s2,-1
 2ea:	bfcd                	j	2dc <stat+0x2a>

00000000000002ec <atoi>:

int
atoi(const char *s)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 2f2:	00054683          	lbu	a3,0(a0)
 2f6:	fd06879b          	addiw	a5,a3,-48
 2fa:	0ff7f793          	zext.b	a5,a5
 2fe:	4625                	li	a2,9
 300:	02f66863          	bltu	a2,a5,330 <atoi+0x44>
 304:	872a                	mv	a4,a0
  n = 0;
 306:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 308:	0705                	addi	a4,a4,1
 30a:	0025179b          	slliw	a5,a0,0x2
 30e:	9fa9                	addw	a5,a5,a0
 310:	0017979b          	slliw	a5,a5,0x1
 314:	9fb5                	addw	a5,a5,a3
 316:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 31a:	00074683          	lbu	a3,0(a4)
 31e:	fd06879b          	addiw	a5,a3,-48
 322:	0ff7f793          	zext.b	a5,a5
 326:	fef671e3          	bgeu	a2,a5,308 <atoi+0x1c>
  return n;
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  n = 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <atoi+0x3e>

0000000000000334 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e422                	sd	s0,8(sp)
 338:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33a:	02b57463          	bgeu	a0,a1,362 <memmove+0x2e>
    while (n-- > 0)
 33e:	00c05f63          	blez	a2,35c <memmove+0x28>
 342:	1602                	slli	a2,a2,0x20
 344:	9201                	srli	a2,a2,0x20
 346:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34a:	872a                	mv	a4,a0
      *dst++ = *src++;
 34c:	0585                	addi	a1,a1,1
 34e:	0705                	addi	a4,a4,1
 350:	fff5c683          	lbu	a3,-1(a1)
 354:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 358:	fef71ae3          	bne	a4,a5,34c <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35c:	6422                	ld	s0,8(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret
    dst += n;
 362:	00c50733          	add	a4,a0,a2
    src += n;
 366:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 368:	fec05ae3          	blez	a2,35c <memmove+0x28>
 36c:	fff6079b          	addiw	a5,a2,-1
 370:	1782                	slli	a5,a5,0x20
 372:	9381                	srli	a5,a5,0x20
 374:	fff7c793          	not	a5,a5
 378:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37a:	15fd                	addi	a1,a1,-1
 37c:	177d                	addi	a4,a4,-1
 37e:	0005c683          	lbu	a3,0(a1)
 382:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 386:	fee79ae3          	bne	a5,a4,37a <memmove+0x46>
 38a:	bfc9                	j	35c <memmove+0x28>

000000000000038c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 38c:	1141                	addi	sp,sp,-16
 38e:	e422                	sd	s0,8(sp)
 390:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 392:	ca05                	beqz	a2,3c2 <memcmp+0x36>
 394:	fff6069b          	addiw	a3,a2,-1
 398:	1682                	slli	a3,a3,0x20
 39a:	9281                	srli	a3,a3,0x20
 39c:	0685                	addi	a3,a3,1
 39e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a0:	00054783          	lbu	a5,0(a0)
 3a4:	0005c703          	lbu	a4,0(a1)
 3a8:	00e79863          	bne	a5,a4,3b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ac:	0505                	addi	a0,a0,1
    p2++;
 3ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b0:	fed518e3          	bne	a0,a3,3a0 <memcmp+0x14>
  }
  return 0;
 3b4:	4501                	li	a0,0
 3b6:	a019                	j	3bc <memcmp+0x30>
      return *p1 - *p2;
 3b8:	40e7853b          	subw	a0,a5,a4
}
 3bc:	6422                	ld	s0,8(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret
  return 0;
 3c2:	4501                	li	a0,0
 3c4:	bfe5                	j	3bc <memcmp+0x30>

00000000000003c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c6:	1141                	addi	sp,sp,-16
 3c8:	e406                	sd	ra,8(sp)
 3ca:	e022                	sd	s0,0(sp)
 3cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ce:	f67ff0ef          	jal	334 <memmove>
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <sbrk>:

char *
sbrk(int n)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e406                	sd	ra,8(sp)
 3de:	e022                	sd	s0,0(sp)
 3e0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3e2:	4585                	li	a1,1
 3e4:	0b2000ef          	jal	496 <sys_sbrk>
}
 3e8:	60a2                	ld	ra,8(sp)
 3ea:	6402                	ld	s0,0(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret

00000000000003f0 <sbrklazy>:

char *
sbrklazy(int n)
{
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e406                	sd	ra,8(sp)
 3f4:	e022                	sd	s0,0(sp)
 3f6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3f8:	4589                	li	a1,2
 3fa:	09c000ef          	jal	496 <sys_sbrk>
}
 3fe:	60a2                	ld	ra,8(sp)
 400:	6402                	ld	s0,0(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret

0000000000000406 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 406:	4885                	li	a7,1
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <exit>:
.global exit
exit:
 li a7, SYS_exit
 40e:	4889                	li	a7,2
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <wait>:
.global wait
wait:
 li a7, SYS_wait
 416:	488d                	li	a7,3
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 41e:	4891                	li	a7,4
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <read>:
.global read
read:
 li a7, SYS_read
 426:	4895                	li	a7,5
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <write>:
.global write
write:
 li a7, SYS_write
 42e:	48c1                	li	a7,16
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <close>:
.global close
close:
 li a7, SYS_close
 436:	48d5                	li	a7,21
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <kill>:
.global kill
kill:
 li a7, SYS_kill
 43e:	4899                	li	a7,6
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <exec>:
.global exec
exec:
 li a7, SYS_exec
 446:	489d                	li	a7,7
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <open>:
.global open
open:
 li a7, SYS_open
 44e:	48bd                	li	a7,15
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 456:	48c5                	li	a7,17
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 45e:	48c9                	li	a7,18
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 466:	48a1                	li	a7,8
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <link>:
.global link
link:
 li a7, SYS_link
 46e:	48cd                	li	a7,19
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 476:	48d1                	li	a7,20
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 47e:	48a5                	li	a7,9
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <dup>:
.global dup
dup:
 li a7, SYS_dup
 486:	48a9                	li	a7,10
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 48e:	48ad                	li	a7,11
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 496:	48b1                	li	a7,12
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <pause>:
.global pause
pause:
 li a7, SYS_pause
 49e:	48b5                	li	a7,13
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a6:	48b9                	li	a7,14
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sync>:
.global sync
sync:
 li a7, SYS_sync
 4ae:	48d9                	li	a7,22
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b6:	1101                	addi	sp,sp,-32
 4b8:	ec06                	sd	ra,24(sp)
 4ba:	e822                	sd	s0,16(sp)
 4bc:	1000                	addi	s0,sp,32
 4be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c2:	4605                	li	a2,1
 4c4:	fef40593          	addi	a1,s0,-17
 4c8:	f67ff0ef          	jal	42e <write>
}
 4cc:	60e2                	ld	ra,24(sp)
 4ce:	6442                	ld	s0,16(sp)
 4d0:	6105                	addi	sp,sp,32
 4d2:	8082                	ret

00000000000004d4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4d4:	715d                	addi	sp,sp,-80
 4d6:	e486                	sd	ra,72(sp)
 4d8:	e0a2                	sd	s0,64(sp)
 4da:	f84a                	sd	s2,48(sp)
 4dc:	0880                	addi	s0,sp,80
 4de:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 4e0:	c299                	beqz	a3,4e6 <printint+0x12>
 4e2:	0805c363          	bltz	a1,568 <printint+0x94>
  neg = 0;
 4e6:	4881                	li	a7,0
 4e8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ec:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 4ee:	00000517          	auipc	a0,0x0
 4f2:	5ca50513          	addi	a0,a0,1482 # ab8 <digits>
 4f6:	883e                	mv	a6,a5
 4f8:	2785                	addiw	a5,a5,1
 4fa:	02c5f733          	remu	a4,a1,a2
 4fe:	972a                	add	a4,a4,a0
 500:	00074703          	lbu	a4,0(a4)
 504:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 508:	872e                	mv	a4,a1
 50a:	02c5d5b3          	divu	a1,a1,a2
 50e:	0685                	addi	a3,a3,1
 510:	fec773e3          	bgeu	a4,a2,4f6 <printint+0x22>
  if (neg)
 514:	00088b63          	beqz	a7,52a <printint+0x56>
    buf[i++] = '-';
 518:	fd078793          	addi	a5,a5,-48
 51c:	97a2                	add	a5,a5,s0
 51e:	02d00713          	li	a4,45
 522:	fee78423          	sb	a4,-24(a5)
 526:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 52a:	02f05a63          	blez	a5,55e <printint+0x8a>
 52e:	fc26                	sd	s1,56(sp)
 530:	f44e                	sd	s3,40(sp)
 532:	fb840713          	addi	a4,s0,-72
 536:	00f704b3          	add	s1,a4,a5
 53a:	fff70993          	addi	s3,a4,-1
 53e:	99be                	add	s3,s3,a5
 540:	37fd                	addiw	a5,a5,-1
 542:	1782                	slli	a5,a5,0x20
 544:	9381                	srli	a5,a5,0x20
 546:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 54a:	fff4c583          	lbu	a1,-1(s1)
 54e:	854a                	mv	a0,s2
 550:	f67ff0ef          	jal	4b6 <putc>
  while (--i >= 0)
 554:	14fd                	addi	s1,s1,-1
 556:	ff349ae3          	bne	s1,s3,54a <printint+0x76>
 55a:	74e2                	ld	s1,56(sp)
 55c:	79a2                	ld	s3,40(sp)
}
 55e:	60a6                	ld	ra,72(sp)
 560:	6406                	ld	s0,64(sp)
 562:	7942                	ld	s2,48(sp)
 564:	6161                	addi	sp,sp,80
 566:	8082                	ret
    x = -xx;
 568:	40b005b3          	neg	a1,a1
    neg = 1;
 56c:	4885                	li	a7,1
    x = -xx;
 56e:	bfad                	j	4e8 <printint+0x14>

0000000000000570 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 570:	711d                	addi	sp,sp,-96
 572:	ec86                	sd	ra,88(sp)
 574:	e8a2                	sd	s0,80(sp)
 576:	e0ca                	sd	s2,64(sp)
 578:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 57a:	0005c903          	lbu	s2,0(a1)
 57e:	28090663          	beqz	s2,80a <vprintf+0x29a>
 582:	e4a6                	sd	s1,72(sp)
 584:	fc4e                	sd	s3,56(sp)
 586:	f852                	sd	s4,48(sp)
 588:	f456                	sd	s5,40(sp)
 58a:	f05a                	sd	s6,32(sp)
 58c:	ec5e                	sd	s7,24(sp)
 58e:	e862                	sd	s8,16(sp)
 590:	e466                	sd	s9,8(sp)
 592:	8b2a                	mv	s6,a0
 594:	8a2e                	mv	s4,a1
 596:	8bb2                	mv	s7,a2
  state = 0;
 598:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 59a:	4481                	li	s1,0
 59c:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 59e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 5a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 5a6:	06c00c93          	li	s9,108
 5aa:	a005                	j	5ca <vprintf+0x5a>
        putc(fd, c0);
 5ac:	85ca                	mv	a1,s2
 5ae:	855a                	mv	a0,s6
 5b0:	f07ff0ef          	jal	4b6 <putc>
 5b4:	a019                	j	5ba <vprintf+0x4a>
    } else if (state == '%') {
 5b6:	03598263          	beq	s3,s5,5da <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 5ba:	2485                	addiw	s1,s1,1
 5bc:	8726                	mv	a4,s1
 5be:	009a07b3          	add	a5,s4,s1
 5c2:	0007c903          	lbu	s2,0(a5)
 5c6:	22090a63          	beqz	s2,7fa <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5ca:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 5ce:	fe0994e3          	bnez	s3,5b6 <vprintf+0x46>
      if (c0 == '%') {
 5d2:	fd579de3          	bne	a5,s5,5ac <vprintf+0x3c>
        state = '%';
 5d6:	89be                	mv	s3,a5
 5d8:	b7cd                	j	5ba <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 5da:	00ea06b3          	add	a3,s4,a4
 5de:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5e2:	8636                	mv	a2,a3
      if (c1)
 5e4:	c681                	beqz	a3,5ec <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 5e6:	9752                	add	a4,a4,s4
 5e8:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 5ec:	05878363          	beq	a5,s8,632 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 5f0:	05978d63          	beq	a5,s9,64a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 5f4:	07500713          	li	a4,117
 5f8:	0ee78763          	beq	a5,a4,6e6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 5fc:	07800713          	li	a4,120
 600:	12e78963          	beq	a5,a4,732 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 604:	07000713          	li	a4,112
 608:	14e78e63          	beq	a5,a4,764 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 60c:	06300713          	li	a4,99
 610:	18e78e63          	beq	a5,a4,7ac <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 614:	07300713          	li	a4,115
 618:	1ae78463          	beq	a5,a4,7c0 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 61c:	02500713          	li	a4,37
 620:	04e79563          	bne	a5,a4,66a <vprintf+0xfa>
        putc(fd, '%');
 624:	02500593          	li	a1,37
 628:	855a                	mv	a0,s6
 62a:	e8dff0ef          	jal	4b6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 62e:	4981                	li	s3,0
 630:	b769                	j	5ba <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 632:	008b8913          	addi	s2,s7,8
 636:	4685                	li	a3,1
 638:	4629                	li	a2,10
 63a:	000ba583          	lw	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	e95ff0ef          	jal	4d4 <printint>
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	bf8d                	j	5ba <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 64a:	06400793          	li	a5,100
 64e:	02f68963          	beq	a3,a5,680 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 652:	06c00793          	li	a5,108
 656:	04f68263          	beq	a3,a5,69a <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 65a:	07500793          	li	a5,117
 65e:	0af68063          	beq	a3,a5,6fe <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 662:	07800793          	li	a5,120
 666:	0ef68263          	beq	a3,a5,74a <vprintf+0x1da>
        putc(fd, '%');
 66a:	02500593          	li	a1,37
 66e:	855a                	mv	a0,s6
 670:	e47ff0ef          	jal	4b6 <putc>
        putc(fd, c0);
 674:	85ca                	mv	a1,s2
 676:	855a                	mv	a0,s6
 678:	e3fff0ef          	jal	4b6 <putc>
      state = 0;
 67c:	4981                	li	s3,0
 67e:	bf35                	j	5ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 680:	008b8913          	addi	s2,s7,8
 684:	4685                	li	a3,1
 686:	4629                	li	a2,10
 688:	000bb583          	ld	a1,0(s7)
 68c:	855a                	mv	a0,s6
 68e:	e47ff0ef          	jal	4d4 <printint>
        i += 1;
 692:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 694:	8bca                	mv	s7,s2
      state = 0;
 696:	4981                	li	s3,0
        i += 1;
 698:	b70d                	j	5ba <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 69a:	06400793          	li	a5,100
 69e:	02f60763          	beq	a2,a5,6cc <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 6a2:	07500793          	li	a5,117
 6a6:	06f60963          	beq	a2,a5,718 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 6aa:	07800793          	li	a5,120
 6ae:	faf61ee3          	bne	a2,a5,66a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b2:	008b8913          	addi	s2,s7,8
 6b6:	4681                	li	a3,0
 6b8:	4641                	li	a2,16
 6ba:	000bb583          	ld	a1,0(s7)
 6be:	855a                	mv	a0,s6
 6c0:	e15ff0ef          	jal	4d4 <printint>
        i += 2;
 6c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
        i += 2;
 6ca:	bdc5                	j	5ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6cc:	008b8913          	addi	s2,s7,8
 6d0:	4685                	li	a3,1
 6d2:	4629                	li	a2,10
 6d4:	000bb583          	ld	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	dfbff0ef          	jal	4d4 <printint>
        i += 2;
 6de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e0:	8bca                	mv	s7,s2
      state = 0;
 6e2:	4981                	li	s3,0
        i += 2;
 6e4:	bdd9                	j	5ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	4681                	li	a3,0
 6ec:	4629                	li	a2,10
 6ee:	000be583          	lwu	a1,0(s7)
 6f2:	855a                	mv	a0,s6
 6f4:	de1ff0ef          	jal	4d4 <printint>
 6f8:	8bca                	mv	s7,s2
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	bd7d                	j	5ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fe:	008b8913          	addi	s2,s7,8
 702:	4681                	li	a3,0
 704:	4629                	li	a2,10
 706:	000bb583          	ld	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	dc9ff0ef          	jal	4d4 <printint>
        i += 1;
 710:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 712:	8bca                	mv	s7,s2
      state = 0;
 714:	4981                	li	s3,0
        i += 1;
 716:	b555                	j	5ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 718:	008b8913          	addi	s2,s7,8
 71c:	4681                	li	a3,0
 71e:	4629                	li	a2,10
 720:	000bb583          	ld	a1,0(s7)
 724:	855a                	mv	a0,s6
 726:	dafff0ef          	jal	4d4 <printint>
        i += 2;
 72a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
        i += 2;
 730:	b569                	j	5ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 732:	008b8913          	addi	s2,s7,8
 736:	4681                	li	a3,0
 738:	4641                	li	a2,16
 73a:	000be583          	lwu	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	d95ff0ef          	jal	4d4 <printint>
 744:	8bca                	mv	s7,s2
      state = 0;
 746:	4981                	li	s3,0
 748:	bd8d                	j	5ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 74a:	008b8913          	addi	s2,s7,8
 74e:	4681                	li	a3,0
 750:	4641                	li	a2,16
 752:	000bb583          	ld	a1,0(s7)
 756:	855a                	mv	a0,s6
 758:	d7dff0ef          	jal	4d4 <printint>
        i += 1;
 75c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 75e:	8bca                	mv	s7,s2
      state = 0;
 760:	4981                	li	s3,0
        i += 1;
 762:	bda1                	j	5ba <vprintf+0x4a>
 764:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 766:	008b8d13          	addi	s10,s7,8
 76a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 76e:	03000593          	li	a1,48
 772:	855a                	mv	a0,s6
 774:	d43ff0ef          	jal	4b6 <putc>
  putc(fd, 'x');
 778:	07800593          	li	a1,120
 77c:	855a                	mv	a0,s6
 77e:	d39ff0ef          	jal	4b6 <putc>
 782:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 784:	00000b97          	auipc	s7,0x0
 788:	334b8b93          	addi	s7,s7,820 # ab8 <digits>
 78c:	03c9d793          	srli	a5,s3,0x3c
 790:	97de                	add	a5,a5,s7
 792:	0007c583          	lbu	a1,0(a5)
 796:	855a                	mv	a0,s6
 798:	d1fff0ef          	jal	4b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 79c:	0992                	slli	s3,s3,0x4
 79e:	397d                	addiw	s2,s2,-1
 7a0:	fe0916e3          	bnez	s2,78c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7a4:	8bea                	mv	s7,s10
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	6d02                	ld	s10,0(sp)
 7aa:	bd01                	j	5ba <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7ac:	008b8913          	addi	s2,s7,8
 7b0:	000bc583          	lbu	a1,0(s7)
 7b4:	855a                	mv	a0,s6
 7b6:	d01ff0ef          	jal	4b6 <putc>
 7ba:	8bca                	mv	s7,s2
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	bbf5                	j	5ba <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 7c0:	008b8993          	addi	s3,s7,8
 7c4:	000bb903          	ld	s2,0(s7)
 7c8:	00090f63          	beqz	s2,7e6 <vprintf+0x276>
        for (; *s; s++)
 7cc:	00094583          	lbu	a1,0(s2)
 7d0:	c195                	beqz	a1,7f4 <vprintf+0x284>
          putc(fd, *s);
 7d2:	855a                	mv	a0,s6
 7d4:	ce3ff0ef          	jal	4b6 <putc>
        for (; *s; s++)
 7d8:	0905                	addi	s2,s2,1
 7da:	00094583          	lbu	a1,0(s2)
 7de:	f9f5                	bnez	a1,7d2 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 7e0:	8bce                	mv	s7,s3
      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	bbd9                	j	5ba <vprintf+0x4a>
          s = "(null)";
 7e6:	00000917          	auipc	s2,0x0
 7ea:	2ca90913          	addi	s2,s2,714 # ab0 <malloc+0x1be>
        for (; *s; s++)
 7ee:	02800593          	li	a1,40
 7f2:	b7c5                	j	7d2 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 7f4:	8bce                	mv	s7,s3
      state = 0;
 7f6:	4981                	li	s3,0
 7f8:	b3c9                	j	5ba <vprintf+0x4a>
 7fa:	64a6                	ld	s1,72(sp)
 7fc:	79e2                	ld	s3,56(sp)
 7fe:	7a42                	ld	s4,48(sp)
 800:	7aa2                	ld	s5,40(sp)
 802:	7b02                	ld	s6,32(sp)
 804:	6be2                	ld	s7,24(sp)
 806:	6c42                	ld	s8,16(sp)
 808:	6ca2                	ld	s9,8(sp)
    }
  }
}
 80a:	60e6                	ld	ra,88(sp)
 80c:	6446                	ld	s0,80(sp)
 80e:	6906                	ld	s2,64(sp)
 810:	6125                	addi	sp,sp,96
 812:	8082                	ret

0000000000000814 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 814:	715d                	addi	sp,sp,-80
 816:	ec06                	sd	ra,24(sp)
 818:	e822                	sd	s0,16(sp)
 81a:	1000                	addi	s0,sp,32
 81c:	e010                	sd	a2,0(s0)
 81e:	e414                	sd	a3,8(s0)
 820:	e818                	sd	a4,16(s0)
 822:	ec1c                	sd	a5,24(s0)
 824:	03043023          	sd	a6,32(s0)
 828:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 82c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 830:	8622                	mv	a2,s0
 832:	d3fff0ef          	jal	570 <vprintf>
}
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6161                	addi	sp,sp,80
 83c:	8082                	ret

000000000000083e <printf>:

void
printf(const char *fmt, ...)
{
 83e:	711d                	addi	sp,sp,-96
 840:	ec06                	sd	ra,24(sp)
 842:	e822                	sd	s0,16(sp)
 844:	1000                	addi	s0,sp,32
 846:	e40c                	sd	a1,8(s0)
 848:	e810                	sd	a2,16(s0)
 84a:	ec14                	sd	a3,24(s0)
 84c:	f018                	sd	a4,32(s0)
 84e:	f41c                	sd	a5,40(s0)
 850:	03043823          	sd	a6,48(s0)
 854:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 858:	00840613          	addi	a2,s0,8
 85c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 860:	85aa                	mv	a1,a0
 862:	4505                	li	a0,1
 864:	d0dff0ef          	jal	570 <vprintf>
}
 868:	60e2                	ld	ra,24(sp)
 86a:	6442                	ld	s0,16(sp)
 86c:	6125                	addi	sp,sp,96
 86e:	8082                	ret

0000000000000870 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 870:	1141                	addi	sp,sp,-16
 872:	e422                	sd	s0,8(sp)
 874:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 876:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87a:	00000797          	auipc	a5,0x0
 87e:	78e7b783          	ld	a5,1934(a5) # 1008 <freep>
 882:	a02d                	j	8ac <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 884:	4618                	lw	a4,8(a2)
 886:	9f2d                	addw	a4,a4,a1
 888:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 88c:	6398                	ld	a4,0(a5)
 88e:	6310                	ld	a2,0(a4)
 890:	a83d                	j	8ce <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 892:	ff852703          	lw	a4,-8(a0)
 896:	9f31                	addw	a4,a4,a2
 898:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 89a:	ff053683          	ld	a3,-16(a0)
 89e:	a091                	j	8e2 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a0:	6398                	ld	a4,0(a5)
 8a2:	00e7e463          	bltu	a5,a4,8aa <free+0x3a>
 8a6:	00e6ea63          	bltu	a3,a4,8ba <free+0x4a>
{
 8aa:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ac:	fed7fae3          	bgeu	a5,a3,8a0 <free+0x30>
 8b0:	6398                	ld	a4,0(a5)
 8b2:	00e6e463          	bltu	a3,a4,8ba <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b6:	fee7eae3          	bltu	a5,a4,8aa <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 8ba:	ff852583          	lw	a1,-8(a0)
 8be:	6390                	ld	a2,0(a5)
 8c0:	02059813          	slli	a6,a1,0x20
 8c4:	01c85713          	srli	a4,a6,0x1c
 8c8:	9736                	add	a4,a4,a3
 8ca:	fae60de3          	beq	a2,a4,884 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8ce:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 8d2:	4790                	lw	a2,8(a5)
 8d4:	02061593          	slli	a1,a2,0x20
 8d8:	01c5d713          	srli	a4,a1,0x1c
 8dc:	973e                	add	a4,a4,a5
 8de:	fae68ae3          	beq	a3,a4,892 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8e2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8e4:	00000717          	auipc	a4,0x0
 8e8:	72f73223          	sd	a5,1828(a4) # 1008 <freep>
}
 8ec:	6422                	ld	s0,8(sp)
 8ee:	0141                	addi	sp,sp,16
 8f0:	8082                	ret

00000000000008f2 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 8f2:	7139                	addi	sp,sp,-64
 8f4:	fc06                	sd	ra,56(sp)
 8f6:	f822                	sd	s0,48(sp)
 8f8:	f426                	sd	s1,40(sp)
 8fa:	ec4e                	sd	s3,24(sp)
 8fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 8fe:	02051493          	slli	s1,a0,0x20
 902:	9081                	srli	s1,s1,0x20
 904:	04bd                	addi	s1,s1,15
 906:	8091                	srli	s1,s1,0x4
 908:	0014899b          	addiw	s3,s1,1
 90c:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 90e:	00000517          	auipc	a0,0x0
 912:	6fa53503          	ld	a0,1786(a0) # 1008 <freep>
 916:	c915                	beqz	a0,94a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 918:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 91a:	4798                	lw	a4,8(a5)
 91c:	08977a63          	bgeu	a4,s1,9b0 <malloc+0xbe>
 920:	f04a                	sd	s2,32(sp)
 922:	e852                	sd	s4,16(sp)
 924:	e456                	sd	s5,8(sp)
 926:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 928:	8a4e                	mv	s4,s3
 92a:	0009871b          	sext.w	a4,s3
 92e:	6685                	lui	a3,0x1
 930:	00d77363          	bgeu	a4,a3,936 <malloc+0x44>
 934:	6a05                	lui	s4,0x1
 936:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 93a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 93e:	00000917          	auipc	s2,0x0
 942:	6ca90913          	addi	s2,s2,1738 # 1008 <freep>
  if (p == SBRK_ERROR)
 946:	5afd                	li	s5,-1
 948:	a081                	j	988 <malloc+0x96>
 94a:	f04a                	sd	s2,32(sp)
 94c:	e852                	sd	s4,16(sp)
 94e:	e456                	sd	s5,8(sp)
 950:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 952:	00000797          	auipc	a5,0x0
 956:	6be78793          	addi	a5,a5,1726 # 1010 <base>
 95a:	00000717          	auipc	a4,0x0
 95e:	6af73723          	sd	a5,1710(a4) # 1008 <freep>
 962:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 964:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 968:	b7c1                	j	928 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 96a:	6398                	ld	a4,0(a5)
 96c:	e118                	sd	a4,0(a0)
 96e:	a8a9                	j	9c8 <malloc+0xd6>
  hp->s.size = nu;
 970:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 974:	0541                	addi	a0,a0,16
 976:	efbff0ef          	jal	870 <free>
  return freep;
 97a:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 97e:	c12d                	beqz	a0,9e0 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 980:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 982:	4798                	lw	a4,8(a5)
 984:	02977263          	bgeu	a4,s1,9a8 <malloc+0xb6>
    if (p == freep)
 988:	00093703          	ld	a4,0(s2)
 98c:	853e                	mv	a0,a5
 98e:	fef719e3          	bne	a4,a5,980 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 992:	8552                	mv	a0,s4
 994:	a47ff0ef          	jal	3da <sbrk>
  if (p == SBRK_ERROR)
 998:	fd551ce3          	bne	a0,s5,970 <malloc+0x7e>
        return 0;
 99c:	4501                	li	a0,0
 99e:	7902                	ld	s2,32(sp)
 9a0:	6a42                	ld	s4,16(sp)
 9a2:	6aa2                	ld	s5,8(sp)
 9a4:	6b02                	ld	s6,0(sp)
 9a6:	a03d                	j	9d4 <malloc+0xe2>
 9a8:	7902                	ld	s2,32(sp)
 9aa:	6a42                	ld	s4,16(sp)
 9ac:	6aa2                	ld	s5,8(sp)
 9ae:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 9b0:	fae48de3          	beq	s1,a4,96a <malloc+0x78>
        p->s.size -= nunits;
 9b4:	4137073b          	subw	a4,a4,s3
 9b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ba:	02071693          	slli	a3,a4,0x20
 9be:	01c6d713          	srli	a4,a3,0x1c
 9c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c8:	00000717          	auipc	a4,0x0
 9cc:	64a73023          	sd	a0,1600(a4) # 1008 <freep>
      return (void *)(p + 1);
 9d0:	01078513          	addi	a0,a5,16
  }
}
 9d4:	70e2                	ld	ra,56(sp)
 9d6:	7442                	ld	s0,48(sp)
 9d8:	74a2                	ld	s1,40(sp)
 9da:	69e2                	ld	s3,24(sp)
 9dc:	6121                	addi	sp,sp,64
 9de:	8082                	ret
 9e0:	7902                	ld	s2,32(sp)
 9e2:	6a42                	ld	s4,16(sp)
 9e4:	6aa2                	ld	s5,8(sp)
 9e6:	6b02                	ld	s6,0(sp)
 9e8:	b7f5                	j	9d4 <malloc+0xe2>
