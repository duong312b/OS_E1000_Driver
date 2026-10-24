
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	1080                	addi	s0,sp,96
  uint64 addrs[] = {0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
       e:	00008797          	auipc	a5,0x8
      12:	3c278793          	addi	a5,a5,962 # 83d0 <malloc+0x2a30>
      16:	638c                	ld	a1,0(a5)
      18:	6790                	ld	a2,8(a5)
      1a:	6b94                	ld	a3,16(a5)
      1c:	6f98                	ld	a4,24(a5)
      1e:	739c                	ld	a5,32(a5)
      20:	fab43423          	sd	a1,-88(s0)
      24:	fac43823          	sd	a2,-80(s0)
      28:	fad43c23          	sd	a3,-72(s0)
      2c:	fce43023          	sd	a4,-64(s0)
      30:	fcf43423          	sd	a5,-56(s0)
                    0xffffffffffffffff};

  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
      34:	fa840493          	addi	s1,s0,-88
      38:	fd040993          	addi	s3,s0,-48
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE | O_WRONLY);
      3c:	0004b903          	ld	s2,0(s1)
      40:	20100593          	li	a1,513
      44:	854a                	mv	a0,s2
      46:	4b6050ef          	jal	54fc <open>
    if (fd >= 0) {
      4a:	00055c63          	bgez	a0,62 <copyinstr1+0x62>
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
      4e:	04a1                	addi	s1,s1,8
      50:	ff3496e3          	bne	s1,s3,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", (void *)addr, fd);
      exit(1);
    }
  }
}
      54:	60e6                	ld	ra,88(sp)
      56:	6446                	ld	s0,80(sp)
      58:	64a6                	ld	s1,72(sp)
      5a:	6906                	ld	s2,64(sp)
      5c:	79e2                	ld	s3,56(sp)
      5e:	6125                	addi	sp,sp,96
      60:	8082                	ret
      printf("open(%p) returned %d, not -1\n", (void *)addr, fd);
      62:	862a                	mv	a2,a0
      64:	85ca                	mv	a1,s2
      66:	00006517          	auipc	a0,0x6
      6a:	a3a50513          	addi	a0,a0,-1478 # 5aa0 <malloc+0x100>
      6e:	07f050ef          	jal	58ec <printf>
      exit(1);
      72:	4505                	li	a0,1
      74:	448050ef          	jal	54bc <exit>

0000000000000078 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for (i = 0; i < sizeof(uninit); i++) {
      78:	0000a797          	auipc	a5,0xa
      7c:	57078793          	addi	a5,a5,1392 # a5e8 <uninit>
      80:	0000d697          	auipc	a3,0xd
      84:	c7868693          	addi	a3,a3,-904 # ccf8 <buf>
    if (uninit[i] != '\0') {
      88:	0007c703          	lbu	a4,0(a5)
      8c:	e709                	bnez	a4,96 <bsstest+0x1e>
  for (i = 0; i < sizeof(uninit); i++) {
      8e:	0785                	addi	a5,a5,1
      90:	fed79ce3          	bne	a5,a3,88 <bsstest+0x10>
      94:	8082                	ret
{
      96:	1141                	addi	sp,sp,-16
      98:	e406                	sd	ra,8(sp)
      9a:	e022                	sd	s0,0(sp)
      9c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      9e:	85aa                	mv	a1,a0
      a0:	00006517          	auipc	a0,0x6
      a4:	a2050513          	addi	a0,a0,-1504 # 5ac0 <malloc+0x120>
      a8:	045050ef          	jal	58ec <printf>
      exit(1);
      ac:	4505                	li	a0,1
      ae:	40e050ef          	jal	54bc <exit>

00000000000000b2 <opentest>:
{
      b2:	1101                	addi	sp,sp,-32
      b4:	ec06                	sd	ra,24(sp)
      b6:	e822                	sd	s0,16(sp)
      b8:	e426                	sd	s1,8(sp)
      ba:	1000                	addi	s0,sp,32
      bc:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      be:	4581                	li	a1,0
      c0:	00006517          	auipc	a0,0x6
      c4:	a1850513          	addi	a0,a0,-1512 # 5ad8 <malloc+0x138>
      c8:	434050ef          	jal	54fc <open>
  if (fd < 0) {
      cc:	02054263          	bltz	a0,f0 <opentest+0x3e>
  close(fd);
      d0:	414050ef          	jal	54e4 <close>
  fd = open("doesnotexist", 0);
      d4:	4581                	li	a1,0
      d6:	00006517          	auipc	a0,0x6
      da:	a2250513          	addi	a0,a0,-1502 # 5af8 <malloc+0x158>
      de:	41e050ef          	jal	54fc <open>
  if (fd >= 0) {
      e2:	02055163          	bgez	a0,104 <opentest+0x52>
}
      e6:	60e2                	ld	ra,24(sp)
      e8:	6442                	ld	s0,16(sp)
      ea:	64a2                	ld	s1,8(sp)
      ec:	6105                	addi	sp,sp,32
      ee:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f0:	85a6                	mv	a1,s1
      f2:	00006517          	auipc	a0,0x6
      f6:	9ee50513          	addi	a0,a0,-1554 # 5ae0 <malloc+0x140>
      fa:	7f2050ef          	jal	58ec <printf>
    exit(1);
      fe:	4505                	li	a0,1
     100:	3bc050ef          	jal	54bc <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     104:	85a6                	mv	a1,s1
     106:	00006517          	auipc	a0,0x6
     10a:	a0250513          	addi	a0,a0,-1534 # 5b08 <malloc+0x168>
     10e:	7de050ef          	jal	58ec <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	3a8050ef          	jal	54bc <exit>

0000000000000118 <truncate2>:
{
     118:	7179                	addi	sp,sp,-48
     11a:	f406                	sd	ra,40(sp)
     11c:	f022                	sd	s0,32(sp)
     11e:	ec26                	sd	s1,24(sp)
     120:	e84a                	sd	s2,16(sp)
     122:	e44e                	sd	s3,8(sp)
     124:	1800                	addi	s0,sp,48
     126:	89aa                	mv	s3,a0
  unlink("truncfile");
     128:	00006517          	auipc	a0,0x6
     12c:	a0850513          	addi	a0,a0,-1528 # 5b30 <malloc+0x190>
     130:	3dc050ef          	jal	550c <unlink>
  int fd1 = open("truncfile", O_CREATE | O_TRUNC | O_WRONLY);
     134:	60100593          	li	a1,1537
     138:	00006517          	auipc	a0,0x6
     13c:	9f850513          	addi	a0,a0,-1544 # 5b30 <malloc+0x190>
     140:	3bc050ef          	jal	54fc <open>
     144:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     146:	4611                	li	a2,4
     148:	00006597          	auipc	a1,0x6
     14c:	9f858593          	addi	a1,a1,-1544 # 5b40 <malloc+0x1a0>
     150:	38c050ef          	jal	54dc <write>
  int fd2 = open("truncfile", O_TRUNC | O_WRONLY);
     154:	40100593          	li	a1,1025
     158:	00006517          	auipc	a0,0x6
     15c:	9d850513          	addi	a0,a0,-1576 # 5b30 <malloc+0x190>
     160:	39c050ef          	jal	54fc <open>
     164:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     166:	4605                	li	a2,1
     168:	00006597          	auipc	a1,0x6
     16c:	9e058593          	addi	a1,a1,-1568 # 5b48 <malloc+0x1a8>
     170:	8526                	mv	a0,s1
     172:	36a050ef          	jal	54dc <write>
  if (n != -1) {
     176:	57fd                	li	a5,-1
     178:	02f51563          	bne	a0,a5,1a2 <truncate2+0x8a>
  unlink("truncfile");
     17c:	00006517          	auipc	a0,0x6
     180:	9b450513          	addi	a0,a0,-1612 # 5b30 <malloc+0x190>
     184:	388050ef          	jal	550c <unlink>
  close(fd1);
     188:	8526                	mv	a0,s1
     18a:	35a050ef          	jal	54e4 <close>
  close(fd2);
     18e:	854a                	mv	a0,s2
     190:	354050ef          	jal	54e4 <close>
}
     194:	70a2                	ld	ra,40(sp)
     196:	7402                	ld	s0,32(sp)
     198:	64e2                	ld	s1,24(sp)
     19a:	6942                	ld	s2,16(sp)
     19c:	69a2                	ld	s3,8(sp)
     19e:	6145                	addi	sp,sp,48
     1a0:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1a2:	862a                	mv	a2,a0
     1a4:	85ce                	mv	a1,s3
     1a6:	00006517          	auipc	a0,0x6
     1aa:	9aa50513          	addi	a0,a0,-1622 # 5b50 <malloc+0x1b0>
     1ae:	73e050ef          	jal	58ec <printf>
    exit(1);
     1b2:	4505                	li	a0,1
     1b4:	308050ef          	jal	54bc <exit>

00000000000001b8 <createtest>:
{
     1b8:	7179                	addi	sp,sp,-48
     1ba:	f406                	sd	ra,40(sp)
     1bc:	f022                	sd	s0,32(sp)
     1be:	ec26                	sd	s1,24(sp)
     1c0:	e84a                	sd	s2,16(sp)
     1c2:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1c4:	06100793          	li	a5,97
     1c8:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1cc:	fc040d23          	sb	zero,-38(s0)
     1d0:	03000493          	li	s1,48
  for (i = 0; i < N; i++) {
     1d4:	06400913          	li	s2,100
    name[1] = '0' + i;
     1d8:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE | O_RDWR);
     1dc:	20200593          	li	a1,514
     1e0:	fd840513          	addi	a0,s0,-40
     1e4:	318050ef          	jal	54fc <open>
    close(fd);
     1e8:	2fc050ef          	jal	54e4 <close>
  for (i = 0; i < N; i++) {
     1ec:	2485                	addiw	s1,s1,1
     1ee:	0ff4f493          	zext.b	s1,s1
     1f2:	ff2493e3          	bne	s1,s2,1d8 <createtest+0x20>
  name[0] = 'a';
     1f6:	06100793          	li	a5,97
     1fa:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1fe:	fc040d23          	sb	zero,-38(s0)
     202:	03000493          	li	s1,48
  for (i = 0; i < N; i++) {
     206:	06400913          	li	s2,100
    name[1] = '0' + i;
     20a:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     20e:	fd840513          	addi	a0,s0,-40
     212:	2fa050ef          	jal	550c <unlink>
  for (i = 0; i < N; i++) {
     216:	2485                	addiw	s1,s1,1
     218:	0ff4f493          	zext.b	s1,s1
     21c:	ff2497e3          	bne	s1,s2,20a <createtest+0x52>
}
     220:	70a2                	ld	ra,40(sp)
     222:	7402                	ld	s0,32(sp)
     224:	64e2                	ld	s1,24(sp)
     226:	6942                	ld	s2,16(sp)
     228:	6145                	addi	sp,sp,48
     22a:	8082                	ret

000000000000022c <bigwrite>:
{
     22c:	715d                	addi	sp,sp,-80
     22e:	e486                	sd	ra,72(sp)
     230:	e0a2                	sd	s0,64(sp)
     232:	fc26                	sd	s1,56(sp)
     234:	f84a                	sd	s2,48(sp)
     236:	f44e                	sd	s3,40(sp)
     238:	f052                	sd	s4,32(sp)
     23a:	ec56                	sd	s5,24(sp)
     23c:	e85a                	sd	s6,16(sp)
     23e:	e45e                	sd	s7,8(sp)
     240:	0880                	addi	s0,sp,80
     242:	8baa                	mv	s7,a0
  unlink("bigwrite");
     244:	00006517          	auipc	a0,0x6
     248:	93450513          	addi	a0,a0,-1740 # 5b78 <malloc+0x1d8>
     24c:	2c0050ef          	jal	550c <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471) {
     250:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     254:	00006a97          	auipc	s5,0x6
     258:	924a8a93          	addi	s5,s5,-1756 # 5b78 <malloc+0x1d8>
      int cc = write(fd, buf, sz);
     25c:	0000da17          	auipc	s4,0xd
     260:	a9ca0a13          	addi	s4,s4,-1380 # ccf8 <buf>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471) {
     264:	6b0d                	lui	s6,0x3
     266:	1c9b0b13          	addi	s6,s6,457 # 31c9 <dirfile+0x69>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     26a:	20200593          	li	a1,514
     26e:	8556                	mv	a0,s5
     270:	28c050ef          	jal	54fc <open>
     274:	892a                	mv	s2,a0
    if (fd < 0) {
     276:	04054563          	bltz	a0,2c0 <bigwrite+0x94>
      int cc = write(fd, buf, sz);
     27a:	8626                	mv	a2,s1
     27c:	85d2                	mv	a1,s4
     27e:	25e050ef          	jal	54dc <write>
     282:	89aa                	mv	s3,a0
      if (cc != sz) {
     284:	04a49863          	bne	s1,a0,2d4 <bigwrite+0xa8>
      int cc = write(fd, buf, sz);
     288:	8626                	mv	a2,s1
     28a:	85d2                	mv	a1,s4
     28c:	854a                	mv	a0,s2
     28e:	24e050ef          	jal	54dc <write>
      if (cc != sz) {
     292:	04951263          	bne	a0,s1,2d6 <bigwrite+0xaa>
    close(fd);
     296:	854a                	mv	a0,s2
     298:	24c050ef          	jal	54e4 <close>
    unlink("bigwrite");
     29c:	8556                	mv	a0,s5
     29e:	26e050ef          	jal	550c <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471) {
     2a2:	1d74849b          	addiw	s1,s1,471
     2a6:	fd6492e3          	bne	s1,s6,26a <bigwrite+0x3e>
}
     2aa:	60a6                	ld	ra,72(sp)
     2ac:	6406                	ld	s0,64(sp)
     2ae:	74e2                	ld	s1,56(sp)
     2b0:	7942                	ld	s2,48(sp)
     2b2:	79a2                	ld	s3,40(sp)
     2b4:	7a02                	ld	s4,32(sp)
     2b6:	6ae2                	ld	s5,24(sp)
     2b8:	6b42                	ld	s6,16(sp)
     2ba:	6ba2                	ld	s7,8(sp)
     2bc:	6161                	addi	sp,sp,80
     2be:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     2c0:	85de                	mv	a1,s7
     2c2:	00006517          	auipc	a0,0x6
     2c6:	8c650513          	addi	a0,a0,-1850 # 5b88 <malloc+0x1e8>
     2ca:	622050ef          	jal	58ec <printf>
      exit(1);
     2ce:	4505                	li	a0,1
     2d0:	1ec050ef          	jal	54bc <exit>
      if (cc != sz) {
     2d4:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     2d6:	86aa                	mv	a3,a0
     2d8:	864e                	mv	a2,s3
     2da:	85de                	mv	a1,s7
     2dc:	00006517          	auipc	a0,0x6
     2e0:	8cc50513          	addi	a0,a0,-1844 # 5ba8 <malloc+0x208>
     2e4:	608050ef          	jal	58ec <printf>
        exit(1);
     2e8:	4505                	li	a0,1
     2ea:	1d2050ef          	jal	54bc <exit>

00000000000002ee <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     2ee:	7179                	addi	sp,sp,-48
     2f0:	f406                	sd	ra,40(sp)
     2f2:	f022                	sd	s0,32(sp)
     2f4:	ec26                	sd	s1,24(sp)
     2f6:	e84a                	sd	s2,16(sp)
     2f8:	e44e                	sd	s3,8(sp)
     2fa:	e052                	sd	s4,0(sp)
     2fc:	1800                	addi	s0,sp,48
  int assumed_free = 600;

  unlink("junk");
     2fe:	00006517          	auipc	a0,0x6
     302:	8c250513          	addi	a0,a0,-1854 # 5bc0 <malloc+0x220>
     306:	206050ef          	jal	550c <unlink>
     30a:	25800913          	li	s2,600
  for (int i = 0; i < assumed_free; i++) {
    int fd = open("junk", O_CREATE | O_WRONLY);
     30e:	00006997          	auipc	s3,0x6
     312:	8b298993          	addi	s3,s3,-1870 # 5bc0 <malloc+0x220>
    if (fd < 0) {
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char *)0xffffffffffL, 1);
     316:	5a7d                	li	s4,-1
     318:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE | O_WRONLY);
     31c:	20100593          	li	a1,513
     320:	854e                	mv	a0,s3
     322:	1da050ef          	jal	54fc <open>
     326:	84aa                	mv	s1,a0
    if (fd < 0) {
     328:	04054d63          	bltz	a0,382 <badwrite+0x94>
    write(fd, (char *)0xffffffffffL, 1);
     32c:	4605                	li	a2,1
     32e:	85d2                	mv	a1,s4
     330:	1ac050ef          	jal	54dc <write>
    close(fd);
     334:	8526                	mv	a0,s1
     336:	1ae050ef          	jal	54e4 <close>
    unlink("junk");
     33a:	854e                	mv	a0,s3
     33c:	1d0050ef          	jal	550c <unlink>
  for (int i = 0; i < assumed_free; i++) {
     340:	397d                	addiw	s2,s2,-1
     342:	fc091de3          	bnez	s2,31c <badwrite+0x2e>
  }

  int fd = open("junk", O_CREATE | O_WRONLY);
     346:	20100593          	li	a1,513
     34a:	00006517          	auipc	a0,0x6
     34e:	87650513          	addi	a0,a0,-1930 # 5bc0 <malloc+0x220>
     352:	1aa050ef          	jal	54fc <open>
     356:	84aa                	mv	s1,a0
  if (fd < 0) {
     358:	02054e63          	bltz	a0,394 <badwrite+0xa6>
    printf("open junk failed\n");
    exit(1);
  }
  if (write(fd, "x", 1) != 1) {
     35c:	4605                	li	a2,1
     35e:	00005597          	auipc	a1,0x5
     362:	7ea58593          	addi	a1,a1,2026 # 5b48 <malloc+0x1a8>
     366:	176050ef          	jal	54dc <write>
     36a:	4785                	li	a5,1
     36c:	02f50d63          	beq	a0,a5,3a6 <badwrite+0xb8>
    printf("write failed\n");
     370:	00006517          	auipc	a0,0x6
     374:	87050513          	addi	a0,a0,-1936 # 5be0 <malloc+0x240>
     378:	574050ef          	jal	58ec <printf>
    exit(1);
     37c:	4505                	li	a0,1
     37e:	13e050ef          	jal	54bc <exit>
      printf("open junk failed\n");
     382:	00006517          	auipc	a0,0x6
     386:	84650513          	addi	a0,a0,-1978 # 5bc8 <malloc+0x228>
     38a:	562050ef          	jal	58ec <printf>
      exit(1);
     38e:	4505                	li	a0,1
     390:	12c050ef          	jal	54bc <exit>
    printf("open junk failed\n");
     394:	00006517          	auipc	a0,0x6
     398:	83450513          	addi	a0,a0,-1996 # 5bc8 <malloc+0x228>
     39c:	550050ef          	jal	58ec <printf>
    exit(1);
     3a0:	4505                	li	a0,1
     3a2:	11a050ef          	jal	54bc <exit>
  }
  close(fd);
     3a6:	8526                	mv	a0,s1
     3a8:	13c050ef          	jal	54e4 <close>
  unlink("junk");
     3ac:	00006517          	auipc	a0,0x6
     3b0:	81450513          	addi	a0,a0,-2028 # 5bc0 <malloc+0x220>
     3b4:	158050ef          	jal	550c <unlink>

  exit(0);
     3b8:	4501                	li	a0,0
     3ba:	102050ef          	jal	54bc <exit>

00000000000003be <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     3be:	715d                	addi	sp,sp,-80
     3c0:	e486                	sd	ra,72(sp)
     3c2:	e0a2                	sd	s0,64(sp)
     3c4:	fc26                	sd	s1,56(sp)
     3c6:	f84a                	sd	s2,48(sp)
     3c8:	f44e                	sd	s3,40(sp)
     3ca:	0880                	addi	s0,sp,80
  int nzz = 32 * 32;
  for (int i = 0; i < nzz; i++) {
     3cc:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     3ce:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++) {
     3d2:	40000993          	li	s3,1024
    name[0] = 'z';
     3d6:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     3da:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     3de:	41f4d71b          	sraiw	a4,s1,0x1f
     3e2:	01b7571b          	srliw	a4,a4,0x1b
     3e6:	009707bb          	addw	a5,a4,s1
     3ea:	4057d69b          	sraiw	a3,a5,0x5
     3ee:	0306869b          	addiw	a3,a3,48
     3f2:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     3f6:	8bfd                	andi	a5,a5,31
     3f8:	9f99                	subw	a5,a5,a4
     3fa:	0307879b          	addiw	a5,a5,48
     3fe:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     402:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     406:	fb040513          	addi	a0,s0,-80
     40a:	102050ef          	jal	550c <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
     40e:	60200593          	li	a1,1538
     412:	fb040513          	addi	a0,s0,-80
     416:	0e6050ef          	jal	54fc <open>
    if (fd < 0) {
     41a:	00054763          	bltz	a0,428 <outofinodes+0x6a>
      // failure is eventually expected.
      break;
    }
    close(fd);
     41e:	0c6050ef          	jal	54e4 <close>
  for (int i = 0; i < nzz; i++) {
     422:	2485                	addiw	s1,s1,1
     424:	fb3499e3          	bne	s1,s3,3d6 <outofinodes+0x18>
     428:	4481                	li	s1,0
  }

  for (int i = 0; i < nzz; i++) {
    char name[32];
    name[0] = 'z';
     42a:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++) {
     42e:	40000993          	li	s3,1024
    name[0] = 'z';
     432:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     436:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     43a:	41f4d71b          	sraiw	a4,s1,0x1f
     43e:	01b7571b          	srliw	a4,a4,0x1b
     442:	009707bb          	addw	a5,a4,s1
     446:	4057d69b          	sraiw	a3,a5,0x5
     44a:	0306869b          	addiw	a3,a3,48
     44e:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     452:	8bfd                	andi	a5,a5,31
     454:	9f99                	subw	a5,a5,a4
     456:	0307879b          	addiw	a5,a5,48
     45a:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     45e:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     462:	fb040513          	addi	a0,s0,-80
     466:	0a6050ef          	jal	550c <unlink>
  for (int i = 0; i < nzz; i++) {
     46a:	2485                	addiw	s1,s1,1
     46c:	fd3493e3          	bne	s1,s3,432 <outofinodes+0x74>
  }
}
     470:	60a6                	ld	ra,72(sp)
     472:	6406                	ld	s0,64(sp)
     474:	74e2                	ld	s1,56(sp)
     476:	7942                	ld	s2,48(sp)
     478:	79a2                	ld	s3,40(sp)
     47a:	6161                	addi	sp,sp,80
     47c:	8082                	ret

000000000000047e <copyin>:
{
     47e:	7159                	addi	sp,sp,-112
     480:	f486                	sd	ra,104(sp)
     482:	f0a2                	sd	s0,96(sp)
     484:	eca6                	sd	s1,88(sp)
     486:	e8ca                	sd	s2,80(sp)
     488:	e4ce                	sd	s3,72(sp)
     48a:	e0d2                	sd	s4,64(sp)
     48c:	fc56                	sd	s5,56(sp)
     48e:	1880                	addi	s0,sp,112
  uint64 addrs[] = {0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     490:	00008797          	auipc	a5,0x8
     494:	f4078793          	addi	a5,a5,-192 # 83d0 <malloc+0x2a30>
     498:	638c                	ld	a1,0(a5)
     49a:	6790                	ld	a2,8(a5)
     49c:	6b94                	ld	a3,16(a5)
     49e:	6f98                	ld	a4,24(a5)
     4a0:	739c                	ld	a5,32(a5)
     4a2:	f8b43c23          	sd	a1,-104(s0)
     4a6:	fac43023          	sd	a2,-96(s0)
     4aa:	fad43423          	sd	a3,-88(s0)
     4ae:	fae43823          	sd	a4,-80(s0)
     4b2:	faf43c23          	sd	a5,-72(s0)
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
     4b6:	f9840913          	addi	s2,s0,-104
     4ba:	fc040a93          	addi	s5,s0,-64
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     4be:	00005a17          	auipc	s4,0x5
     4c2:	732a0a13          	addi	s4,s4,1842 # 5bf0 <malloc+0x250>
    uint64 addr = addrs[ai];
     4c6:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     4ca:	20100593          	li	a1,513
     4ce:	8552                	mv	a0,s4
     4d0:	02c050ef          	jal	54fc <open>
     4d4:	84aa                	mv	s1,a0
    if (fd < 0) {
     4d6:	06054763          	bltz	a0,544 <copyin+0xc6>
    int n = write(fd, (void *)addr, 8192);
     4da:	6609                	lui	a2,0x2
     4dc:	85ce                	mv	a1,s3
     4de:	7ff040ef          	jal	54dc <write>
    if (n >= 0) {
     4e2:	06055a63          	bgez	a0,556 <copyin+0xd8>
    close(fd);
     4e6:	8526                	mv	a0,s1
     4e8:	7fd040ef          	jal	54e4 <close>
    unlink("copyin1");
     4ec:	8552                	mv	a0,s4
     4ee:	01e050ef          	jal	550c <unlink>
    n = write(1, (char *)addr, 8192);
     4f2:	6609                	lui	a2,0x2
     4f4:	85ce                	mv	a1,s3
     4f6:	4505                	li	a0,1
     4f8:	7e5040ef          	jal	54dc <write>
    if (n > 0) {
     4fc:	06a04863          	bgtz	a0,56c <copyin+0xee>
    if (pipe(fds) < 0) {
     500:	f9040513          	addi	a0,s0,-112
     504:	7c9040ef          	jal	54cc <pipe>
     508:	06054d63          	bltz	a0,582 <copyin+0x104>
    n = write(fds[1], (char *)addr, 8192);
     50c:	6609                	lui	a2,0x2
     50e:	85ce                	mv	a1,s3
     510:	f9442503          	lw	a0,-108(s0)
     514:	7c9040ef          	jal	54dc <write>
    if (n > 0) {
     518:	06a04e63          	bgtz	a0,594 <copyin+0x116>
    close(fds[0]);
     51c:	f9042503          	lw	a0,-112(s0)
     520:	7c5040ef          	jal	54e4 <close>
    close(fds[1]);
     524:	f9442503          	lw	a0,-108(s0)
     528:	7bd040ef          	jal	54e4 <close>
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
     52c:	0921                	addi	s2,s2,8
     52e:	f9591ce3          	bne	s2,s5,4c6 <copyin+0x48>
}
     532:	70a6                	ld	ra,104(sp)
     534:	7406                	ld	s0,96(sp)
     536:	64e6                	ld	s1,88(sp)
     538:	6946                	ld	s2,80(sp)
     53a:	69a6                	ld	s3,72(sp)
     53c:	6a06                	ld	s4,64(sp)
     53e:	7ae2                	ld	s5,56(sp)
     540:	6165                	addi	sp,sp,112
     542:	8082                	ret
      printf("open(copyin1) failed\n");
     544:	00005517          	auipc	a0,0x5
     548:	6b450513          	addi	a0,a0,1716 # 5bf8 <malloc+0x258>
     54c:	3a0050ef          	jal	58ec <printf>
      exit(1);
     550:	4505                	li	a0,1
     552:	76b040ef          	jal	54bc <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", (void *)addr, n);
     556:	862a                	mv	a2,a0
     558:	85ce                	mv	a1,s3
     55a:	00005517          	auipc	a0,0x5
     55e:	6b650513          	addi	a0,a0,1718 # 5c10 <malloc+0x270>
     562:	38a050ef          	jal	58ec <printf>
      exit(1);
     566:	4505                	li	a0,1
     568:	755040ef          	jal	54bc <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", (void *)addr, n);
     56c:	862a                	mv	a2,a0
     56e:	85ce                	mv	a1,s3
     570:	00005517          	auipc	a0,0x5
     574:	6d050513          	addi	a0,a0,1744 # 5c40 <malloc+0x2a0>
     578:	374050ef          	jal	58ec <printf>
      exit(1);
     57c:	4505                	li	a0,1
     57e:	73f040ef          	jal	54bc <exit>
      printf("pipe() failed\n");
     582:	00005517          	auipc	a0,0x5
     586:	6ee50513          	addi	a0,a0,1774 # 5c70 <malloc+0x2d0>
     58a:	362050ef          	jal	58ec <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	72d040ef          	jal	54bc <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", (void *)addr,
     594:	862a                	mv	a2,a0
     596:	85ce                	mv	a1,s3
     598:	00005517          	auipc	a0,0x5
     59c:	6e850513          	addi	a0,a0,1768 # 5c80 <malloc+0x2e0>
     5a0:	34c050ef          	jal	58ec <printf>
      exit(1);
     5a4:	4505                	li	a0,1
     5a6:	717040ef          	jal	54bc <exit>

00000000000005aa <copyout>:
{
     5aa:	7119                	addi	sp,sp,-128
     5ac:	fc86                	sd	ra,120(sp)
     5ae:	f8a2                	sd	s0,112(sp)
     5b0:	f4a6                	sd	s1,104(sp)
     5b2:	f0ca                	sd	s2,96(sp)
     5b4:	ecce                	sd	s3,88(sp)
     5b6:	e8d2                	sd	s4,80(sp)
     5b8:	e4d6                	sd	s5,72(sp)
     5ba:	e0da                	sd	s6,64(sp)
     5bc:	0100                	addi	s0,sp,128
  uint64 addrs[] = {0LL,          0x80000000LL, 0x3fffffe000,
     5be:	00008797          	auipc	a5,0x8
     5c2:	e1278793          	addi	a5,a5,-494 # 83d0 <malloc+0x2a30>
     5c6:	7788                	ld	a0,40(a5)
     5c8:	7b8c                	ld	a1,48(a5)
     5ca:	7f90                	ld	a2,56(a5)
     5cc:	63b4                	ld	a3,64(a5)
     5ce:	67b8                	ld	a4,72(a5)
     5d0:	6bbc                	ld	a5,80(a5)
     5d2:	f8a43823          	sd	a0,-112(s0)
     5d6:	f8b43c23          	sd	a1,-104(s0)
     5da:	fac43023          	sd	a2,-96(s0)
     5de:	fad43423          	sd	a3,-88(s0)
     5e2:	fae43823          	sd	a4,-80(s0)
     5e6:	faf43c23          	sd	a5,-72(s0)
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
     5ea:	f9040913          	addi	s2,s0,-112
     5ee:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
     5f2:	00005a17          	auipc	s4,0x5
     5f6:	6bea0a13          	addi	s4,s4,1726 # 5cb0 <malloc+0x310>
    n = write(fds[1], "x", 1);
     5fa:	00005a97          	auipc	s5,0x5
     5fe:	54ea8a93          	addi	s5,s5,1358 # 5b48 <malloc+0x1a8>
    uint64 addr = addrs[ai];
     602:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     606:	4581                	li	a1,0
     608:	8552                	mv	a0,s4
     60a:	6f3040ef          	jal	54fc <open>
     60e:	84aa                	mv	s1,a0
    if (fd < 0) {
     610:	06054763          	bltz	a0,67e <copyout+0xd4>
    int n = read(fd, (void *)addr, 8192);
     614:	6609                	lui	a2,0x2
     616:	85ce                	mv	a1,s3
     618:	6bd040ef          	jal	54d4 <read>
    if (n > 0) {
     61c:	06a04a63          	bgtz	a0,690 <copyout+0xe6>
    close(fd);
     620:	8526                	mv	a0,s1
     622:	6c3040ef          	jal	54e4 <close>
    if (pipe(fds) < 0) {
     626:	f8840513          	addi	a0,s0,-120
     62a:	6a3040ef          	jal	54cc <pipe>
     62e:	06054c63          	bltz	a0,6a6 <copyout+0xfc>
    n = write(fds[1], "x", 1);
     632:	4605                	li	a2,1
     634:	85d6                	mv	a1,s5
     636:	f8c42503          	lw	a0,-116(s0)
     63a:	6a3040ef          	jal	54dc <write>
    if (n != 1) {
     63e:	4785                	li	a5,1
     640:	06f51c63          	bne	a0,a5,6b8 <copyout+0x10e>
    n = read(fds[0], (void *)addr, 8192);
     644:	6609                	lui	a2,0x2
     646:	85ce                	mv	a1,s3
     648:	f8842503          	lw	a0,-120(s0)
     64c:	689040ef          	jal	54d4 <read>
    if (n > 0) {
     650:	06a04d63          	bgtz	a0,6ca <copyout+0x120>
    close(fds[0]);
     654:	f8842503          	lw	a0,-120(s0)
     658:	68d040ef          	jal	54e4 <close>
    close(fds[1]);
     65c:	f8c42503          	lw	a0,-116(s0)
     660:	685040ef          	jal	54e4 <close>
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
     664:	0921                	addi	s2,s2,8
     666:	f9691ee3          	bne	s2,s6,602 <copyout+0x58>
}
     66a:	70e6                	ld	ra,120(sp)
     66c:	7446                	ld	s0,112(sp)
     66e:	74a6                	ld	s1,104(sp)
     670:	7906                	ld	s2,96(sp)
     672:	69e6                	ld	s3,88(sp)
     674:	6a46                	ld	s4,80(sp)
     676:	6aa6                	ld	s5,72(sp)
     678:	6b06                	ld	s6,64(sp)
     67a:	6109                	addi	sp,sp,128
     67c:	8082                	ret
      printf("open(README) failed\n");
     67e:	00005517          	auipc	a0,0x5
     682:	63a50513          	addi	a0,a0,1594 # 5cb8 <malloc+0x318>
     686:	266050ef          	jal	58ec <printf>
      exit(1);
     68a:	4505                	li	a0,1
     68c:	631040ef          	jal	54bc <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", (void *)addr, n);
     690:	862a                	mv	a2,a0
     692:	85ce                	mv	a1,s3
     694:	00005517          	auipc	a0,0x5
     698:	63c50513          	addi	a0,a0,1596 # 5cd0 <malloc+0x330>
     69c:	250050ef          	jal	58ec <printf>
      exit(1);
     6a0:	4505                	li	a0,1
     6a2:	61b040ef          	jal	54bc <exit>
      printf("pipe() failed\n");
     6a6:	00005517          	auipc	a0,0x5
     6aa:	5ca50513          	addi	a0,a0,1482 # 5c70 <malloc+0x2d0>
     6ae:	23e050ef          	jal	58ec <printf>
      exit(1);
     6b2:	4505                	li	a0,1
     6b4:	609040ef          	jal	54bc <exit>
      printf("pipe write failed\n");
     6b8:	00005517          	auipc	a0,0x5
     6bc:	64850513          	addi	a0,a0,1608 # 5d00 <malloc+0x360>
     6c0:	22c050ef          	jal	58ec <printf>
      exit(1);
     6c4:	4505                	li	a0,1
     6c6:	5f7040ef          	jal	54bc <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", (void *)addr,
     6ca:	862a                	mv	a2,a0
     6cc:	85ce                	mv	a1,s3
     6ce:	00005517          	auipc	a0,0x5
     6d2:	64a50513          	addi	a0,a0,1610 # 5d18 <malloc+0x378>
     6d6:	216050ef          	jal	58ec <printf>
      exit(1);
     6da:	4505                	li	a0,1
     6dc:	5e1040ef          	jal	54bc <exit>

00000000000006e0 <truncate1>:
{
     6e0:	711d                	addi	sp,sp,-96
     6e2:	ec86                	sd	ra,88(sp)
     6e4:	e8a2                	sd	s0,80(sp)
     6e6:	e4a6                	sd	s1,72(sp)
     6e8:	e0ca                	sd	s2,64(sp)
     6ea:	fc4e                	sd	s3,56(sp)
     6ec:	f852                	sd	s4,48(sp)
     6ee:	f456                	sd	s5,40(sp)
     6f0:	1080                	addi	s0,sp,96
     6f2:	8aaa                	mv	s5,a0
  unlink("truncfile");
     6f4:	00005517          	auipc	a0,0x5
     6f8:	43c50513          	addi	a0,a0,1084 # 5b30 <malloc+0x190>
     6fc:	611040ef          	jal	550c <unlink>
  int fd1 = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
     700:	60100593          	li	a1,1537
     704:	00005517          	auipc	a0,0x5
     708:	42c50513          	addi	a0,a0,1068 # 5b30 <malloc+0x190>
     70c:	5f1040ef          	jal	54fc <open>
     710:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     712:	4611                	li	a2,4
     714:	00005597          	auipc	a1,0x5
     718:	42c58593          	addi	a1,a1,1068 # 5b40 <malloc+0x1a0>
     71c:	5c1040ef          	jal	54dc <write>
  close(fd1);
     720:	8526                	mv	a0,s1
     722:	5c3040ef          	jal	54e4 <close>
  int fd2 = open("truncfile", O_RDONLY);
     726:	4581                	li	a1,0
     728:	00005517          	auipc	a0,0x5
     72c:	40850513          	addi	a0,a0,1032 # 5b30 <malloc+0x190>
     730:	5cd040ef          	jal	54fc <open>
     734:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     736:	02000613          	li	a2,32
     73a:	fa040593          	addi	a1,s0,-96
     73e:	597040ef          	jal	54d4 <read>
  if (n != 4) {
     742:	4791                	li	a5,4
     744:	0af51863          	bne	a0,a5,7f4 <truncate1+0x114>
  fd1 = open("truncfile", O_WRONLY | O_TRUNC);
     748:	40100593          	li	a1,1025
     74c:	00005517          	auipc	a0,0x5
     750:	3e450513          	addi	a0,a0,996 # 5b30 <malloc+0x190>
     754:	5a9040ef          	jal	54fc <open>
     758:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     75a:	4581                	li	a1,0
     75c:	00005517          	auipc	a0,0x5
     760:	3d450513          	addi	a0,a0,980 # 5b30 <malloc+0x190>
     764:	599040ef          	jal	54fc <open>
     768:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     76a:	02000613          	li	a2,32
     76e:	fa040593          	addi	a1,s0,-96
     772:	563040ef          	jal	54d4 <read>
     776:	8a2a                	mv	s4,a0
  if (n != 0) {
     778:	e949                	bnez	a0,80a <truncate1+0x12a>
  n = read(fd2, buf, sizeof(buf));
     77a:	02000613          	li	a2,32
     77e:	fa040593          	addi	a1,s0,-96
     782:	8526                	mv	a0,s1
     784:	551040ef          	jal	54d4 <read>
     788:	8a2a                	mv	s4,a0
  if (n != 0) {
     78a:	e155                	bnez	a0,82e <truncate1+0x14e>
  write(fd1, "abcdef", 6);
     78c:	4619                	li	a2,6
     78e:	00005597          	auipc	a1,0x5
     792:	61a58593          	addi	a1,a1,1562 # 5da8 <malloc+0x408>
     796:	854e                	mv	a0,s3
     798:	545040ef          	jal	54dc <write>
  n = read(fd3, buf, sizeof(buf));
     79c:	02000613          	li	a2,32
     7a0:	fa040593          	addi	a1,s0,-96
     7a4:	854a                	mv	a0,s2
     7a6:	52f040ef          	jal	54d4 <read>
  if (n != 6) {
     7aa:	4799                	li	a5,6
     7ac:	0af51363          	bne	a0,a5,852 <truncate1+0x172>
  n = read(fd2, buf, sizeof(buf));
     7b0:	02000613          	li	a2,32
     7b4:	fa040593          	addi	a1,s0,-96
     7b8:	8526                	mv	a0,s1
     7ba:	51b040ef          	jal	54d4 <read>
  if (n != 2) {
     7be:	4789                	li	a5,2
     7c0:	0af51463          	bne	a0,a5,868 <truncate1+0x188>
  unlink("truncfile");
     7c4:	00005517          	auipc	a0,0x5
     7c8:	36c50513          	addi	a0,a0,876 # 5b30 <malloc+0x190>
     7cc:	541040ef          	jal	550c <unlink>
  close(fd1);
     7d0:	854e                	mv	a0,s3
     7d2:	513040ef          	jal	54e4 <close>
  close(fd2);
     7d6:	8526                	mv	a0,s1
     7d8:	50d040ef          	jal	54e4 <close>
  close(fd3);
     7dc:	854a                	mv	a0,s2
     7de:	507040ef          	jal	54e4 <close>
}
     7e2:	60e6                	ld	ra,88(sp)
     7e4:	6446                	ld	s0,80(sp)
     7e6:	64a6                	ld	s1,72(sp)
     7e8:	6906                	ld	s2,64(sp)
     7ea:	79e2                	ld	s3,56(sp)
     7ec:	7a42                	ld	s4,48(sp)
     7ee:	7aa2                	ld	s5,40(sp)
     7f0:	6125                	addi	sp,sp,96
     7f2:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     7f4:	862a                	mv	a2,a0
     7f6:	85d6                	mv	a1,s5
     7f8:	00005517          	auipc	a0,0x5
     7fc:	55050513          	addi	a0,a0,1360 # 5d48 <malloc+0x3a8>
     800:	0ec050ef          	jal	58ec <printf>
    exit(1);
     804:	4505                	li	a0,1
     806:	4b7040ef          	jal	54bc <exit>
    printf("aaa fd3=%d\n", fd3);
     80a:	85ca                	mv	a1,s2
     80c:	00005517          	auipc	a0,0x5
     810:	55c50513          	addi	a0,a0,1372 # 5d68 <malloc+0x3c8>
     814:	0d8050ef          	jal	58ec <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     818:	8652                	mv	a2,s4
     81a:	85d6                	mv	a1,s5
     81c:	00005517          	auipc	a0,0x5
     820:	55c50513          	addi	a0,a0,1372 # 5d78 <malloc+0x3d8>
     824:	0c8050ef          	jal	58ec <printf>
    exit(1);
     828:	4505                	li	a0,1
     82a:	493040ef          	jal	54bc <exit>
    printf("bbb fd2=%d\n", fd2);
     82e:	85a6                	mv	a1,s1
     830:	00005517          	auipc	a0,0x5
     834:	56850513          	addi	a0,a0,1384 # 5d98 <malloc+0x3f8>
     838:	0b4050ef          	jal	58ec <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     83c:	8652                	mv	a2,s4
     83e:	85d6                	mv	a1,s5
     840:	00005517          	auipc	a0,0x5
     844:	53850513          	addi	a0,a0,1336 # 5d78 <malloc+0x3d8>
     848:	0a4050ef          	jal	58ec <printf>
    exit(1);
     84c:	4505                	li	a0,1
     84e:	46f040ef          	jal	54bc <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     852:	862a                	mv	a2,a0
     854:	85d6                	mv	a1,s5
     856:	00005517          	auipc	a0,0x5
     85a:	55a50513          	addi	a0,a0,1370 # 5db0 <malloc+0x410>
     85e:	08e050ef          	jal	58ec <printf>
    exit(1);
     862:	4505                	li	a0,1
     864:	459040ef          	jal	54bc <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     868:	862a                	mv	a2,a0
     86a:	85d6                	mv	a1,s5
     86c:	00005517          	auipc	a0,0x5
     870:	56450513          	addi	a0,a0,1380 # 5dd0 <malloc+0x430>
     874:	078050ef          	jal	58ec <printf>
    exit(1);
     878:	4505                	li	a0,1
     87a:	443040ef          	jal	54bc <exit>

000000000000087e <writetest>:
{
     87e:	7139                	addi	sp,sp,-64
     880:	fc06                	sd	ra,56(sp)
     882:	f822                	sd	s0,48(sp)
     884:	f426                	sd	s1,40(sp)
     886:	f04a                	sd	s2,32(sp)
     888:	ec4e                	sd	s3,24(sp)
     88a:	e852                	sd	s4,16(sp)
     88c:	e456                	sd	s5,8(sp)
     88e:	e05a                	sd	s6,0(sp)
     890:	0080                	addi	s0,sp,64
     892:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE | O_RDWR);
     894:	20200593          	li	a1,514
     898:	00005517          	auipc	a0,0x5
     89c:	55850513          	addi	a0,a0,1368 # 5df0 <malloc+0x450>
     8a0:	45d040ef          	jal	54fc <open>
  if (fd < 0) {
     8a4:	08054f63          	bltz	a0,942 <writetest+0xc4>
     8a8:	892a                	mv	s2,a0
     8aa:	4481                	li	s1,0
    if (write(fd, "aaaaaaaaaa", SZ) != SZ) {
     8ac:	00005997          	auipc	s3,0x5
     8b0:	56c98993          	addi	s3,s3,1388 # 5e18 <malloc+0x478>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ) {
     8b4:	00005a97          	auipc	s5,0x5
     8b8:	59ca8a93          	addi	s5,s5,1436 # 5e50 <malloc+0x4b0>
  for (i = 0; i < N; i++) {
     8bc:	06400a13          	li	s4,100
    if (write(fd, "aaaaaaaaaa", SZ) != SZ) {
     8c0:	4629                	li	a2,10
     8c2:	85ce                	mv	a1,s3
     8c4:	854a                	mv	a0,s2
     8c6:	417040ef          	jal	54dc <write>
     8ca:	47a9                	li	a5,10
     8cc:	08f51563          	bne	a0,a5,956 <writetest+0xd8>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ) {
     8d0:	4629                	li	a2,10
     8d2:	85d6                	mv	a1,s5
     8d4:	854a                	mv	a0,s2
     8d6:	407040ef          	jal	54dc <write>
     8da:	47a9                	li	a5,10
     8dc:	08f51863          	bne	a0,a5,96c <writetest+0xee>
  for (i = 0; i < N; i++) {
     8e0:	2485                	addiw	s1,s1,1
     8e2:	fd449fe3          	bne	s1,s4,8c0 <writetest+0x42>
  close(fd);
     8e6:	854a                	mv	a0,s2
     8e8:	3fd040ef          	jal	54e4 <close>
  fd = open("small", O_RDONLY);
     8ec:	4581                	li	a1,0
     8ee:	00005517          	auipc	a0,0x5
     8f2:	50250513          	addi	a0,a0,1282 # 5df0 <malloc+0x450>
     8f6:	407040ef          	jal	54fc <open>
     8fa:	84aa                	mv	s1,a0
  if (fd < 0) {
     8fc:	08054363          	bltz	a0,982 <writetest+0x104>
  i = read(fd, buf, N * SZ * 2);
     900:	7d000613          	li	a2,2000
     904:	0000c597          	auipc	a1,0xc
     908:	3f458593          	addi	a1,a1,1012 # ccf8 <buf>
     90c:	3c9040ef          	jal	54d4 <read>
  if (i != N * SZ * 2) {
     910:	7d000793          	li	a5,2000
     914:	08f51163          	bne	a0,a5,996 <writetest+0x118>
  close(fd);
     918:	8526                	mv	a0,s1
     91a:	3cb040ef          	jal	54e4 <close>
  if (unlink("small") < 0) {
     91e:	00005517          	auipc	a0,0x5
     922:	4d250513          	addi	a0,a0,1234 # 5df0 <malloc+0x450>
     926:	3e7040ef          	jal	550c <unlink>
     92a:	08054063          	bltz	a0,9aa <writetest+0x12c>
}
     92e:	70e2                	ld	ra,56(sp)
     930:	7442                	ld	s0,48(sp)
     932:	74a2                	ld	s1,40(sp)
     934:	7902                	ld	s2,32(sp)
     936:	69e2                	ld	s3,24(sp)
     938:	6a42                	ld	s4,16(sp)
     93a:	6aa2                	ld	s5,8(sp)
     93c:	6b02                	ld	s6,0(sp)
     93e:	6121                	addi	sp,sp,64
     940:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     942:	85da                	mv	a1,s6
     944:	00005517          	auipc	a0,0x5
     948:	4b450513          	addi	a0,a0,1204 # 5df8 <malloc+0x458>
     94c:	7a1040ef          	jal	58ec <printf>
    exit(1);
     950:	4505                	li	a0,1
     952:	36b040ef          	jal	54bc <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     956:	8626                	mv	a2,s1
     958:	85da                	mv	a1,s6
     95a:	00005517          	auipc	a0,0x5
     95e:	4ce50513          	addi	a0,a0,1230 # 5e28 <malloc+0x488>
     962:	78b040ef          	jal	58ec <printf>
      exit(1);
     966:	4505                	li	a0,1
     968:	355040ef          	jal	54bc <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     96c:	8626                	mv	a2,s1
     96e:	85da                	mv	a1,s6
     970:	00005517          	auipc	a0,0x5
     974:	4f050513          	addi	a0,a0,1264 # 5e60 <malloc+0x4c0>
     978:	775040ef          	jal	58ec <printf>
      exit(1);
     97c:	4505                	li	a0,1
     97e:	33f040ef          	jal	54bc <exit>
    printf("%s: error: open small failed!\n", s);
     982:	85da                	mv	a1,s6
     984:	00005517          	auipc	a0,0x5
     988:	50450513          	addi	a0,a0,1284 # 5e88 <malloc+0x4e8>
     98c:	761040ef          	jal	58ec <printf>
    exit(1);
     990:	4505                	li	a0,1
     992:	32b040ef          	jal	54bc <exit>
    printf("%s: read failed\n", s);
     996:	85da                	mv	a1,s6
     998:	00005517          	auipc	a0,0x5
     99c:	51050513          	addi	a0,a0,1296 # 5ea8 <malloc+0x508>
     9a0:	74d040ef          	jal	58ec <printf>
    exit(1);
     9a4:	4505                	li	a0,1
     9a6:	317040ef          	jal	54bc <exit>
    printf("%s: unlink small failed\n", s);
     9aa:	85da                	mv	a1,s6
     9ac:	00005517          	auipc	a0,0x5
     9b0:	51450513          	addi	a0,a0,1300 # 5ec0 <malloc+0x520>
     9b4:	739040ef          	jal	58ec <printf>
    exit(1);
     9b8:	4505                	li	a0,1
     9ba:	303040ef          	jal	54bc <exit>

00000000000009be <writebig>:
{
     9be:	7139                	addi	sp,sp,-64
     9c0:	fc06                	sd	ra,56(sp)
     9c2:	f822                	sd	s0,48(sp)
     9c4:	f426                	sd	s1,40(sp)
     9c6:	f04a                	sd	s2,32(sp)
     9c8:	ec4e                	sd	s3,24(sp)
     9ca:	e852                	sd	s4,16(sp)
     9cc:	e456                	sd	s5,8(sp)
     9ce:	0080                	addi	s0,sp,64
     9d0:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE | O_RDWR);
     9d2:	20200593          	li	a1,514
     9d6:	00005517          	auipc	a0,0x5
     9da:	50a50513          	addi	a0,a0,1290 # 5ee0 <malloc+0x540>
     9de:	31f040ef          	jal	54fc <open>
     9e2:	89aa                	mv	s3,a0
  for (i = 0; i < MAXFILE; i++) {
     9e4:	4481                	li	s1,0
    ((int *)buf)[0] = i;
     9e6:	0000c917          	auipc	s2,0xc
     9ea:	31290913          	addi	s2,s2,786 # ccf8 <buf>
  for (i = 0; i < MAXFILE; i++) {
     9ee:	10c00a13          	li	s4,268
  if (fd < 0) {
     9f2:	06054463          	bltz	a0,a5a <writebig+0x9c>
    ((int *)buf)[0] = i;
     9f6:	00992023          	sw	s1,0(s2)
    if (write(fd, buf, BSIZE) != BSIZE) {
     9fa:	40000613          	li	a2,1024
     9fe:	85ca                	mv	a1,s2
     a00:	854e                	mv	a0,s3
     a02:	2db040ef          	jal	54dc <write>
     a06:	40000793          	li	a5,1024
     a0a:	06f51263          	bne	a0,a5,a6e <writebig+0xb0>
  for (i = 0; i < MAXFILE; i++) {
     a0e:	2485                	addiw	s1,s1,1
     a10:	ff4493e3          	bne	s1,s4,9f6 <writebig+0x38>
  close(fd);
     a14:	854e                	mv	a0,s3
     a16:	2cf040ef          	jal	54e4 <close>
  fd = open("big", O_RDONLY);
     a1a:	4581                	li	a1,0
     a1c:	00005517          	auipc	a0,0x5
     a20:	4c450513          	addi	a0,a0,1220 # 5ee0 <malloc+0x540>
     a24:	2d9040ef          	jal	54fc <open>
     a28:	89aa                	mv	s3,a0
  n = 0;
     a2a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a2c:	0000c917          	auipc	s2,0xc
     a30:	2cc90913          	addi	s2,s2,716 # ccf8 <buf>
  if (fd < 0) {
     a34:	04054863          	bltz	a0,a84 <writebig+0xc6>
    i = read(fd, buf, BSIZE);
     a38:	40000613          	li	a2,1024
     a3c:	85ca                	mv	a1,s2
     a3e:	854e                	mv	a0,s3
     a40:	295040ef          	jal	54d4 <read>
    if (i == 0) {
     a44:	c931                	beqz	a0,a98 <writebig+0xda>
    } else if (i != BSIZE) {
     a46:	40000793          	li	a5,1024
     a4a:	08f51a63          	bne	a0,a5,ade <writebig+0x120>
    if (((int *)buf)[0] != n) {
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0a969163          	bne	a3,s1,af4 <writebig+0x136>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	b7c5                	j	a38 <writebig+0x7a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00005517          	auipc	a0,0x5
     a60:	48c50513          	addi	a0,a0,1164 # 5ee8 <malloc+0x548>
     a64:	689040ef          	jal	58ec <printf>
    exit(1);
     a68:	4505                	li	a0,1
     a6a:	253040ef          	jal	54bc <exit>
      printf("%s: error: write big file failed i=%d\n", s, i);
     a6e:	8626                	mv	a2,s1
     a70:	85d6                	mv	a1,s5
     a72:	00005517          	auipc	a0,0x5
     a76:	49650513          	addi	a0,a0,1174 # 5f08 <malloc+0x568>
     a7a:	673040ef          	jal	58ec <printf>
      exit(1);
     a7e:	4505                	li	a0,1
     a80:	23d040ef          	jal	54bc <exit>
    printf("%s: error: open big failed!\n", s);
     a84:	85d6                	mv	a1,s5
     a86:	00005517          	auipc	a0,0x5
     a8a:	4aa50513          	addi	a0,a0,1194 # 5f30 <malloc+0x590>
     a8e:	65f040ef          	jal	58ec <printf>
    exit(1);
     a92:	4505                	li	a0,1
     a94:	229040ef          	jal	54bc <exit>
      if (n != MAXFILE) {
     a98:	10c00793          	li	a5,268
     a9c:	02f49663          	bne	s1,a5,ac8 <writebig+0x10a>
  close(fd);
     aa0:	854e                	mv	a0,s3
     aa2:	243040ef          	jal	54e4 <close>
  if (unlink("big") < 0) {
     aa6:	00005517          	auipc	a0,0x5
     aaa:	43a50513          	addi	a0,a0,1082 # 5ee0 <malloc+0x540>
     aae:	25f040ef          	jal	550c <unlink>
     ab2:	04054c63          	bltz	a0,b0a <writebig+0x14c>
}
     ab6:	70e2                	ld	ra,56(sp)
     ab8:	7442                	ld	s0,48(sp)
     aba:	74a2                	ld	s1,40(sp)
     abc:	7902                	ld	s2,32(sp)
     abe:	69e2                	ld	s3,24(sp)
     ac0:	6a42                	ld	s4,16(sp)
     ac2:	6aa2                	ld	s5,8(sp)
     ac4:	6121                	addi	sp,sp,64
     ac6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ac8:	8626                	mv	a2,s1
     aca:	85d6                	mv	a1,s5
     acc:	00005517          	auipc	a0,0x5
     ad0:	48450513          	addi	a0,a0,1156 # 5f50 <malloc+0x5b0>
     ad4:	619040ef          	jal	58ec <printf>
        exit(1);
     ad8:	4505                	li	a0,1
     ada:	1e3040ef          	jal	54bc <exit>
      printf("%s: read failed %d\n", s, i);
     ade:	862a                	mv	a2,a0
     ae0:	85d6                	mv	a1,s5
     ae2:	00005517          	auipc	a0,0x5
     ae6:	49650513          	addi	a0,a0,1174 # 5f78 <malloc+0x5d8>
     aea:	603040ef          	jal	58ec <printf>
      exit(1);
     aee:	4505                	li	a0,1
     af0:	1cd040ef          	jal	54bc <exit>
      printf("%s: read content of block %d is %d\n", s, n, ((int *)buf)[0]);
     af4:	8626                	mv	a2,s1
     af6:	85d6                	mv	a1,s5
     af8:	00005517          	auipc	a0,0x5
     afc:	49850513          	addi	a0,a0,1176 # 5f90 <malloc+0x5f0>
     b00:	5ed040ef          	jal	58ec <printf>
      exit(1);
     b04:	4505                	li	a0,1
     b06:	1b7040ef          	jal	54bc <exit>
    printf("%s: unlink big failed\n", s);
     b0a:	85d6                	mv	a1,s5
     b0c:	00005517          	auipc	a0,0x5
     b10:	4ac50513          	addi	a0,a0,1196 # 5fb8 <malloc+0x618>
     b14:	5d9040ef          	jal	58ec <printf>
    exit(1);
     b18:	4505                	li	a0,1
     b1a:	1a3040ef          	jal	54bc <exit>

0000000000000b1e <unlinkread>:
{
     b1e:	7179                	addi	sp,sp,-48
     b20:	f406                	sd	ra,40(sp)
     b22:	f022                	sd	s0,32(sp)
     b24:	ec26                	sd	s1,24(sp)
     b26:	e84a                	sd	s2,16(sp)
     b28:	e44e                	sd	s3,8(sp)
     b2a:	1800                	addi	s0,sp,48
     b2c:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b2e:	20200593          	li	a1,514
     b32:	00005517          	auipc	a0,0x5
     b36:	49e50513          	addi	a0,a0,1182 # 5fd0 <malloc+0x630>
     b3a:	1c3040ef          	jal	54fc <open>
  if (fd < 0) {
     b3e:	0a054f63          	bltz	a0,bfc <unlinkread+0xde>
     b42:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b44:	4615                	li	a2,5
     b46:	00005597          	auipc	a1,0x5
     b4a:	4ba58593          	addi	a1,a1,1210 # 6000 <malloc+0x660>
     b4e:	18f040ef          	jal	54dc <write>
  close(fd);
     b52:	8526                	mv	a0,s1
     b54:	191040ef          	jal	54e4 <close>
  fd = open("unlinkread", O_RDWR);
     b58:	4589                	li	a1,2
     b5a:	00005517          	auipc	a0,0x5
     b5e:	47650513          	addi	a0,a0,1142 # 5fd0 <malloc+0x630>
     b62:	19b040ef          	jal	54fc <open>
     b66:	84aa                	mv	s1,a0
  if (fd < 0) {
     b68:	0a054463          	bltz	a0,c10 <unlinkread+0xf2>
  if (unlink("unlinkread") != 0) {
     b6c:	00005517          	auipc	a0,0x5
     b70:	46450513          	addi	a0,a0,1124 # 5fd0 <malloc+0x630>
     b74:	199040ef          	jal	550c <unlink>
     b78:	e555                	bnez	a0,c24 <unlinkread+0x106>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     b7a:	20200593          	li	a1,514
     b7e:	00005517          	auipc	a0,0x5
     b82:	45250513          	addi	a0,a0,1106 # 5fd0 <malloc+0x630>
     b86:	177040ef          	jal	54fc <open>
     b8a:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     b8c:	460d                	li	a2,3
     b8e:	00005597          	auipc	a1,0x5
     b92:	4ba58593          	addi	a1,a1,1210 # 6048 <malloc+0x6a8>
     b96:	147040ef          	jal	54dc <write>
  close(fd1);
     b9a:	854a                	mv	a0,s2
     b9c:	149040ef          	jal	54e4 <close>
  if (read(fd, buf, sizeof(buf)) != SZ) {
     ba0:	660d                	lui	a2,0x3
     ba2:	0000c597          	auipc	a1,0xc
     ba6:	15658593          	addi	a1,a1,342 # ccf8 <buf>
     baa:	8526                	mv	a0,s1
     bac:	129040ef          	jal	54d4 <read>
     bb0:	4795                	li	a5,5
     bb2:	08f51363          	bne	a0,a5,c38 <unlinkread+0x11a>
  if (buf[0] != 'h') {
     bb6:	0000c717          	auipc	a4,0xc
     bba:	14274703          	lbu	a4,322(a4) # ccf8 <buf>
     bbe:	06800793          	li	a5,104
     bc2:	08f71563          	bne	a4,a5,c4c <unlinkread+0x12e>
  if (write(fd, buf, 10) != 10) {
     bc6:	4629                	li	a2,10
     bc8:	0000c597          	auipc	a1,0xc
     bcc:	13058593          	addi	a1,a1,304 # ccf8 <buf>
     bd0:	8526                	mv	a0,s1
     bd2:	10b040ef          	jal	54dc <write>
     bd6:	47a9                	li	a5,10
     bd8:	08f51463          	bne	a0,a5,c60 <unlinkread+0x142>
  close(fd);
     bdc:	8526                	mv	a0,s1
     bde:	107040ef          	jal	54e4 <close>
  unlink("unlinkread");
     be2:	00005517          	auipc	a0,0x5
     be6:	3ee50513          	addi	a0,a0,1006 # 5fd0 <malloc+0x630>
     bea:	123040ef          	jal	550c <unlink>
}
     bee:	70a2                	ld	ra,40(sp)
     bf0:	7402                	ld	s0,32(sp)
     bf2:	64e2                	ld	s1,24(sp)
     bf4:	6942                	ld	s2,16(sp)
     bf6:	69a2                	ld	s3,8(sp)
     bf8:	6145                	addi	sp,sp,48
     bfa:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     bfc:	85ce                	mv	a1,s3
     bfe:	00005517          	auipc	a0,0x5
     c02:	3e250513          	addi	a0,a0,994 # 5fe0 <malloc+0x640>
     c06:	4e7040ef          	jal	58ec <printf>
    exit(1);
     c0a:	4505                	li	a0,1
     c0c:	0b1040ef          	jal	54bc <exit>
    printf("%s: open unlinkread failed\n", s);
     c10:	85ce                	mv	a1,s3
     c12:	00005517          	auipc	a0,0x5
     c16:	3f650513          	addi	a0,a0,1014 # 6008 <malloc+0x668>
     c1a:	4d3040ef          	jal	58ec <printf>
    exit(1);
     c1e:	4505                	li	a0,1
     c20:	09d040ef          	jal	54bc <exit>
    printf("%s: unlink unlinkread failed\n", s);
     c24:	85ce                	mv	a1,s3
     c26:	00005517          	auipc	a0,0x5
     c2a:	40250513          	addi	a0,a0,1026 # 6028 <malloc+0x688>
     c2e:	4bf040ef          	jal	58ec <printf>
    exit(1);
     c32:	4505                	li	a0,1
     c34:	089040ef          	jal	54bc <exit>
    printf("%s: unlinkread read failed", s);
     c38:	85ce                	mv	a1,s3
     c3a:	00005517          	auipc	a0,0x5
     c3e:	41650513          	addi	a0,a0,1046 # 6050 <malloc+0x6b0>
     c42:	4ab040ef          	jal	58ec <printf>
    exit(1);
     c46:	4505                	li	a0,1
     c48:	075040ef          	jal	54bc <exit>
    printf("%s: unlinkread wrong data\n", s);
     c4c:	85ce                	mv	a1,s3
     c4e:	00005517          	auipc	a0,0x5
     c52:	42250513          	addi	a0,a0,1058 # 6070 <malloc+0x6d0>
     c56:	497040ef          	jal	58ec <printf>
    exit(1);
     c5a:	4505                	li	a0,1
     c5c:	061040ef          	jal	54bc <exit>
    printf("%s: unlinkread write failed\n", s);
     c60:	85ce                	mv	a1,s3
     c62:	00005517          	auipc	a0,0x5
     c66:	42e50513          	addi	a0,a0,1070 # 6090 <malloc+0x6f0>
     c6a:	483040ef          	jal	58ec <printf>
    exit(1);
     c6e:	4505                	li	a0,1
     c70:	04d040ef          	jal	54bc <exit>

0000000000000c74 <linktest>:
{
     c74:	1101                	addi	sp,sp,-32
     c76:	ec06                	sd	ra,24(sp)
     c78:	e822                	sd	s0,16(sp)
     c7a:	e426                	sd	s1,8(sp)
     c7c:	e04a                	sd	s2,0(sp)
     c7e:	1000                	addi	s0,sp,32
     c80:	892a                	mv	s2,a0
  unlink("lf1");
     c82:	00005517          	auipc	a0,0x5
     c86:	42e50513          	addi	a0,a0,1070 # 60b0 <malloc+0x710>
     c8a:	083040ef          	jal	550c <unlink>
  unlink("lf2");
     c8e:	00005517          	auipc	a0,0x5
     c92:	42a50513          	addi	a0,a0,1066 # 60b8 <malloc+0x718>
     c96:	077040ef          	jal	550c <unlink>
  fd = open("lf1", O_CREATE | O_RDWR);
     c9a:	20200593          	li	a1,514
     c9e:	00005517          	auipc	a0,0x5
     ca2:	41250513          	addi	a0,a0,1042 # 60b0 <malloc+0x710>
     ca6:	057040ef          	jal	54fc <open>
  if (fd < 0) {
     caa:	0c054f63          	bltz	a0,d88 <linktest+0x114>
     cae:	84aa                	mv	s1,a0
  if (write(fd, "hello", SZ) != SZ) {
     cb0:	4615                	li	a2,5
     cb2:	00005597          	auipc	a1,0x5
     cb6:	34e58593          	addi	a1,a1,846 # 6000 <malloc+0x660>
     cba:	023040ef          	jal	54dc <write>
     cbe:	4795                	li	a5,5
     cc0:	0cf51e63          	bne	a0,a5,d9c <linktest+0x128>
  close(fd);
     cc4:	8526                	mv	a0,s1
     cc6:	01f040ef          	jal	54e4 <close>
  if (link("lf1", "lf2") < 0) {
     cca:	00005597          	auipc	a1,0x5
     cce:	3ee58593          	addi	a1,a1,1006 # 60b8 <malloc+0x718>
     cd2:	00005517          	auipc	a0,0x5
     cd6:	3de50513          	addi	a0,a0,990 # 60b0 <malloc+0x710>
     cda:	043040ef          	jal	551c <link>
     cde:	0c054963          	bltz	a0,db0 <linktest+0x13c>
  unlink("lf1");
     ce2:	00005517          	auipc	a0,0x5
     ce6:	3ce50513          	addi	a0,a0,974 # 60b0 <malloc+0x710>
     cea:	023040ef          	jal	550c <unlink>
  if (open("lf1", 0) >= 0) {
     cee:	4581                	li	a1,0
     cf0:	00005517          	auipc	a0,0x5
     cf4:	3c050513          	addi	a0,a0,960 # 60b0 <malloc+0x710>
     cf8:	005040ef          	jal	54fc <open>
     cfc:	0c055463          	bgez	a0,dc4 <linktest+0x150>
  fd = open("lf2", 0);
     d00:	4581                	li	a1,0
     d02:	00005517          	auipc	a0,0x5
     d06:	3b650513          	addi	a0,a0,950 # 60b8 <malloc+0x718>
     d0a:	7f2040ef          	jal	54fc <open>
     d0e:	84aa                	mv	s1,a0
  if (fd < 0) {
     d10:	0c054463          	bltz	a0,dd8 <linktest+0x164>
  if (read(fd, buf, sizeof(buf)) != SZ) {
     d14:	660d                	lui	a2,0x3
     d16:	0000c597          	auipc	a1,0xc
     d1a:	fe258593          	addi	a1,a1,-30 # ccf8 <buf>
     d1e:	7b6040ef          	jal	54d4 <read>
     d22:	4795                	li	a5,5
     d24:	0cf51463          	bne	a0,a5,dec <linktest+0x178>
  close(fd);
     d28:	8526                	mv	a0,s1
     d2a:	7ba040ef          	jal	54e4 <close>
  if (link("lf2", "lf2") >= 0) {
     d2e:	00005597          	auipc	a1,0x5
     d32:	38a58593          	addi	a1,a1,906 # 60b8 <malloc+0x718>
     d36:	852e                	mv	a0,a1
     d38:	7e4040ef          	jal	551c <link>
     d3c:	0c055263          	bgez	a0,e00 <linktest+0x18c>
  unlink("lf2");
     d40:	00005517          	auipc	a0,0x5
     d44:	37850513          	addi	a0,a0,888 # 60b8 <malloc+0x718>
     d48:	7c4040ef          	jal	550c <unlink>
  if (link("lf2", "lf1") >= 0) {
     d4c:	00005597          	auipc	a1,0x5
     d50:	36458593          	addi	a1,a1,868 # 60b0 <malloc+0x710>
     d54:	00005517          	auipc	a0,0x5
     d58:	36450513          	addi	a0,a0,868 # 60b8 <malloc+0x718>
     d5c:	7c0040ef          	jal	551c <link>
     d60:	0a055a63          	bgez	a0,e14 <linktest+0x1a0>
  if (link(".", "lf1") >= 0) {
     d64:	00005597          	auipc	a1,0x5
     d68:	34c58593          	addi	a1,a1,844 # 60b0 <malloc+0x710>
     d6c:	00005517          	auipc	a0,0x5
     d70:	45450513          	addi	a0,a0,1108 # 61c0 <malloc+0x820>
     d74:	7a8040ef          	jal	551c <link>
     d78:	0a055863          	bgez	a0,e28 <linktest+0x1b4>
}
     d7c:	60e2                	ld	ra,24(sp)
     d7e:	6442                	ld	s0,16(sp)
     d80:	64a2                	ld	s1,8(sp)
     d82:	6902                	ld	s2,0(sp)
     d84:	6105                	addi	sp,sp,32
     d86:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     d88:	85ca                	mv	a1,s2
     d8a:	00005517          	auipc	a0,0x5
     d8e:	33650513          	addi	a0,a0,822 # 60c0 <malloc+0x720>
     d92:	35b040ef          	jal	58ec <printf>
    exit(1);
     d96:	4505                	li	a0,1
     d98:	724040ef          	jal	54bc <exit>
    printf("%s: write lf1 failed\n", s);
     d9c:	85ca                	mv	a1,s2
     d9e:	00005517          	auipc	a0,0x5
     da2:	33a50513          	addi	a0,a0,826 # 60d8 <malloc+0x738>
     da6:	347040ef          	jal	58ec <printf>
    exit(1);
     daa:	4505                	li	a0,1
     dac:	710040ef          	jal	54bc <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     db0:	85ca                	mv	a1,s2
     db2:	00005517          	auipc	a0,0x5
     db6:	33e50513          	addi	a0,a0,830 # 60f0 <malloc+0x750>
     dba:	333040ef          	jal	58ec <printf>
    exit(1);
     dbe:	4505                	li	a0,1
     dc0:	6fc040ef          	jal	54bc <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     dc4:	85ca                	mv	a1,s2
     dc6:	00005517          	auipc	a0,0x5
     dca:	34a50513          	addi	a0,a0,842 # 6110 <malloc+0x770>
     dce:	31f040ef          	jal	58ec <printf>
    exit(1);
     dd2:	4505                	li	a0,1
     dd4:	6e8040ef          	jal	54bc <exit>
    printf("%s: open lf2 failed\n", s);
     dd8:	85ca                	mv	a1,s2
     dda:	00005517          	auipc	a0,0x5
     dde:	36650513          	addi	a0,a0,870 # 6140 <malloc+0x7a0>
     de2:	30b040ef          	jal	58ec <printf>
    exit(1);
     de6:	4505                	li	a0,1
     de8:	6d4040ef          	jal	54bc <exit>
    printf("%s: read lf2 failed\n", s);
     dec:	85ca                	mv	a1,s2
     dee:	00005517          	auipc	a0,0x5
     df2:	36a50513          	addi	a0,a0,874 # 6158 <malloc+0x7b8>
     df6:	2f7040ef          	jal	58ec <printf>
    exit(1);
     dfa:	4505                	li	a0,1
     dfc:	6c0040ef          	jal	54bc <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     e00:	85ca                	mv	a1,s2
     e02:	00005517          	auipc	a0,0x5
     e06:	36e50513          	addi	a0,a0,878 # 6170 <malloc+0x7d0>
     e0a:	2e3040ef          	jal	58ec <printf>
    exit(1);
     e0e:	4505                	li	a0,1
     e10:	6ac040ef          	jal	54bc <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     e14:	85ca                	mv	a1,s2
     e16:	00005517          	auipc	a0,0x5
     e1a:	38250513          	addi	a0,a0,898 # 6198 <malloc+0x7f8>
     e1e:	2cf040ef          	jal	58ec <printf>
    exit(1);
     e22:	4505                	li	a0,1
     e24:	698040ef          	jal	54bc <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     e28:	85ca                	mv	a1,s2
     e2a:	00005517          	auipc	a0,0x5
     e2e:	39e50513          	addi	a0,a0,926 # 61c8 <malloc+0x828>
     e32:	2bb040ef          	jal	58ec <printf>
    exit(1);
     e36:	4505                	li	a0,1
     e38:	684040ef          	jal	54bc <exit>

0000000000000e3c <validatetest>:
{
     e3c:	7139                	addi	sp,sp,-64
     e3e:	fc06                	sd	ra,56(sp)
     e40:	f822                	sd	s0,48(sp)
     e42:	f426                	sd	s1,40(sp)
     e44:	f04a                	sd	s2,32(sp)
     e46:	ec4e                	sd	s3,24(sp)
     e48:	e852                	sd	s4,16(sp)
     e4a:	e456                	sd	s5,8(sp)
     e4c:	e05a                	sd	s6,0(sp)
     e4e:	0080                	addi	s0,sp,64
     e50:	8b2a                	mv	s6,a0
  for (p = 0; p <= (uint)hi; p += PGSIZE) {
     e52:	4481                	li	s1,0
    if (link("nosuchfile", (char *)p) != -1) {
     e54:	00005997          	auipc	s3,0x5
     e58:	39498993          	addi	s3,s3,916 # 61e8 <malloc+0x848>
     e5c:	597d                	li	s2,-1
  for (p = 0; p <= (uint)hi; p += PGSIZE) {
     e5e:	6a85                	lui	s5,0x1
     e60:	00114a37          	lui	s4,0x114
    if (link("nosuchfile", (char *)p) != -1) {
     e64:	85a6                	mv	a1,s1
     e66:	854e                	mv	a0,s3
     e68:	6b4040ef          	jal	551c <link>
     e6c:	01251f63          	bne	a0,s2,e8a <validatetest+0x4e>
  for (p = 0; p <= (uint)hi; p += PGSIZE) {
     e70:	94d6                	add	s1,s1,s5
     e72:	ff4499e3          	bne	s1,s4,e64 <validatetest+0x28>
}
     e76:	70e2                	ld	ra,56(sp)
     e78:	7442                	ld	s0,48(sp)
     e7a:	74a2                	ld	s1,40(sp)
     e7c:	7902                	ld	s2,32(sp)
     e7e:	69e2                	ld	s3,24(sp)
     e80:	6a42                	ld	s4,16(sp)
     e82:	6aa2                	ld	s5,8(sp)
     e84:	6b02                	ld	s6,0(sp)
     e86:	6121                	addi	sp,sp,64
     e88:	8082                	ret
      printf("%s: link should not succeed\n", s);
     e8a:	85da                	mv	a1,s6
     e8c:	00005517          	auipc	a0,0x5
     e90:	36c50513          	addi	a0,a0,876 # 61f8 <malloc+0x858>
     e94:	259040ef          	jal	58ec <printf>
      exit(1);
     e98:	4505                	li	a0,1
     e9a:	622040ef          	jal	54bc <exit>

0000000000000e9e <bigdir>:
{
     e9e:	715d                	addi	sp,sp,-80
     ea0:	e486                	sd	ra,72(sp)
     ea2:	e0a2                	sd	s0,64(sp)
     ea4:	fc26                	sd	s1,56(sp)
     ea6:	f84a                	sd	s2,48(sp)
     ea8:	f44e                	sd	s3,40(sp)
     eaa:	f052                	sd	s4,32(sp)
     eac:	ec56                	sd	s5,24(sp)
     eae:	e85a                	sd	s6,16(sp)
     eb0:	0880                	addi	s0,sp,80
     eb2:	89aa                	mv	s3,a0
  unlink("bd");
     eb4:	00005517          	auipc	a0,0x5
     eb8:	36450513          	addi	a0,a0,868 # 6218 <malloc+0x878>
     ebc:	650040ef          	jal	550c <unlink>
  fd = open("bd", O_CREATE);
     ec0:	20000593          	li	a1,512
     ec4:	00005517          	auipc	a0,0x5
     ec8:	35450513          	addi	a0,a0,852 # 6218 <malloc+0x878>
     ecc:	630040ef          	jal	54fc <open>
  if (fd < 0) {
     ed0:	0c054163          	bltz	a0,f92 <bigdir+0xf4>
  close(fd);
     ed4:	610040ef          	jal	54e4 <close>
  for (i = 0; i < N; i++) {
     ed8:	4901                	li	s2,0
    name[0] = 'x';
     eda:	07800a93          	li	s5,120
    if (link("bd", name) != 0) {
     ede:	00005a17          	auipc	s4,0x5
     ee2:	33aa0a13          	addi	s4,s4,826 # 6218 <malloc+0x878>
  for (i = 0; i < N; i++) {
     ee6:	1f400b13          	li	s6,500
    name[0] = 'x';
     eea:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     eee:	41f9571b          	sraiw	a4,s2,0x1f
     ef2:	01a7571b          	srliw	a4,a4,0x1a
     ef6:	012707bb          	addw	a5,a4,s2
     efa:	4067d69b          	sraiw	a3,a5,0x6
     efe:	0306869b          	addiw	a3,a3,48
     f02:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f06:	03f7f793          	andi	a5,a5,63
     f0a:	9f99                	subw	a5,a5,a4
     f0c:	0307879b          	addiw	a5,a5,48
     f10:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f14:	fa0409a3          	sb	zero,-77(s0)
    if (link("bd", name) != 0) {
     f18:	fb040593          	addi	a1,s0,-80
     f1c:	8552                	mv	a0,s4
     f1e:	5fe040ef          	jal	551c <link>
     f22:	84aa                	mv	s1,a0
     f24:	e149                	bnez	a0,fa6 <bigdir+0x108>
  for (i = 0; i < N; i++) {
     f26:	2905                	addiw	s2,s2,1
     f28:	fd6911e3          	bne	s2,s6,eea <bigdir+0x4c>
  unlink("bd");
     f2c:	00005517          	auipc	a0,0x5
     f30:	2ec50513          	addi	a0,a0,748 # 6218 <malloc+0x878>
     f34:	5d8040ef          	jal	550c <unlink>
    name[0] = 'x';
     f38:	07800913          	li	s2,120
  for (i = 0; i < N; i++) {
     f3c:	1f400a13          	li	s4,500
    name[0] = 'x';
     f40:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
     f44:	41f4d71b          	sraiw	a4,s1,0x1f
     f48:	01a7571b          	srliw	a4,a4,0x1a
     f4c:	009707bb          	addw	a5,a4,s1
     f50:	4067d69b          	sraiw	a3,a5,0x6
     f54:	0306869b          	addiw	a3,a3,48
     f58:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f5c:	03f7f793          	andi	a5,a5,63
     f60:	9f99                	subw	a5,a5,a4
     f62:	0307879b          	addiw	a5,a5,48
     f66:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f6a:	fa0409a3          	sb	zero,-77(s0)
    if (unlink(name) != 0) {
     f6e:	fb040513          	addi	a0,s0,-80
     f72:	59a040ef          	jal	550c <unlink>
     f76:	e529                	bnez	a0,fc0 <bigdir+0x122>
  for (i = 0; i < N; i++) {
     f78:	2485                	addiw	s1,s1,1
     f7a:	fd4493e3          	bne	s1,s4,f40 <bigdir+0xa2>
}
     f7e:	60a6                	ld	ra,72(sp)
     f80:	6406                	ld	s0,64(sp)
     f82:	74e2                	ld	s1,56(sp)
     f84:	7942                	ld	s2,48(sp)
     f86:	79a2                	ld	s3,40(sp)
     f88:	7a02                	ld	s4,32(sp)
     f8a:	6ae2                	ld	s5,24(sp)
     f8c:	6b42                	ld	s6,16(sp)
     f8e:	6161                	addi	sp,sp,80
     f90:	8082                	ret
    printf("%s: bigdir create failed\n", s);
     f92:	85ce                	mv	a1,s3
     f94:	00005517          	auipc	a0,0x5
     f98:	28c50513          	addi	a0,a0,652 # 6220 <malloc+0x880>
     f9c:	151040ef          	jal	58ec <printf>
    exit(1);
     fa0:	4505                	li	a0,1
     fa2:	51a040ef          	jal	54bc <exit>
      printf("%s: bigdir i=%d link(bd, %s) failed\n", s, i, name);
     fa6:	fb040693          	addi	a3,s0,-80
     faa:	864a                	mv	a2,s2
     fac:	85ce                	mv	a1,s3
     fae:	00005517          	auipc	a0,0x5
     fb2:	29250513          	addi	a0,a0,658 # 6240 <malloc+0x8a0>
     fb6:	137040ef          	jal	58ec <printf>
      exit(1);
     fba:	4505                	li	a0,1
     fbc:	500040ef          	jal	54bc <exit>
      printf("%s: bigdir unlink failed", s);
     fc0:	85ce                	mv	a1,s3
     fc2:	00005517          	auipc	a0,0x5
     fc6:	2a650513          	addi	a0,a0,678 # 6268 <malloc+0x8c8>
     fca:	123040ef          	jal	58ec <printf>
      exit(1);
     fce:	4505                	li	a0,1
     fd0:	4ec040ef          	jal	54bc <exit>

0000000000000fd4 <pgbug>:
{
     fd4:	7179                	addi	sp,sp,-48
     fd6:	f406                	sd	ra,40(sp)
     fd8:	f022                	sd	s0,32(sp)
     fda:	ec26                	sd	s1,24(sp)
     fdc:	1800                	addi	s0,sp,48
  argv[0] = 0;
     fde:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
     fe2:	00008497          	auipc	s1,0x8
     fe6:	01e48493          	addi	s1,s1,30 # 9000 <big>
     fea:	fd840593          	addi	a1,s0,-40
     fee:	6088                	ld	a0,0(s1)
     ff0:	504040ef          	jal	54f4 <exec>
  pipe(big);
     ff4:	6088                	ld	a0,0(s1)
     ff6:	4d6040ef          	jal	54cc <pipe>
  exit(0);
     ffa:	4501                	li	a0,0
     ffc:	4c0040ef          	jal	54bc <exit>

0000000000001000 <badarg>:
{
    1000:	7139                	addi	sp,sp,-64
    1002:	fc06                	sd	ra,56(sp)
    1004:	f822                	sd	s0,48(sp)
    1006:	f426                	sd	s1,40(sp)
    1008:	f04a                	sd	s2,32(sp)
    100a:	ec4e                	sd	s3,24(sp)
    100c:	0080                	addi	s0,sp,64
    100e:	64b1                	lui	s1,0xc
    1010:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1d68>
    argv[0] = (char *)0xffffffff;
    1014:	597d                	li	s2,-1
    1016:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    101a:	00005997          	auipc	s3,0x5
    101e:	abe98993          	addi	s3,s3,-1346 # 5ad8 <malloc+0x138>
    argv[0] = (char *)0xffffffff;
    1022:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1026:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    102a:	fc040593          	addi	a1,s0,-64
    102e:	854e                	mv	a0,s3
    1030:	4c4040ef          	jal	54f4 <exec>
  for (int i = 0; i < 50000; i++) {
    1034:	34fd                	addiw	s1,s1,-1
    1036:	f4f5                	bnez	s1,1022 <badarg+0x22>
  exit(0);
    1038:	4501                	li	a0,0
    103a:	482040ef          	jal	54bc <exit>

000000000000103e <copyinstr2>:
{
    103e:	7155                	addi	sp,sp,-208
    1040:	e586                	sd	ra,200(sp)
    1042:	e1a2                	sd	s0,192(sp)
    1044:	0980                	addi	s0,sp,208
  for (int i = 0; i < MAXPATH; i++)
    1046:	f6840793          	addi	a5,s0,-152
    104a:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    104e:	07800713          	li	a4,120
    1052:	00e78023          	sb	a4,0(a5)
  for (int i = 0; i < MAXPATH; i++)
    1056:	0785                	addi	a5,a5,1
    1058:	fed79de3          	bne	a5,a3,1052 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    105c:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1060:	f6840513          	addi	a0,s0,-152
    1064:	4a8040ef          	jal	550c <unlink>
  if (ret != -1) {
    1068:	57fd                	li	a5,-1
    106a:	0cf51263          	bne	a0,a5,112e <copyinstr2+0xf0>
  int fd = open(b, O_CREATE | O_WRONLY);
    106e:	20100593          	li	a1,513
    1072:	f6840513          	addi	a0,s0,-152
    1076:	486040ef          	jal	54fc <open>
  if (fd != -1) {
    107a:	57fd                	li	a5,-1
    107c:	0cf51563          	bne	a0,a5,1146 <copyinstr2+0x108>
  ret = link(b, b);
    1080:	f6840593          	addi	a1,s0,-152
    1084:	852e                	mv	a0,a1
    1086:	496040ef          	jal	551c <link>
  if (ret != -1) {
    108a:	57fd                	li	a5,-1
    108c:	0cf51963          	bne	a0,a5,115e <copyinstr2+0x120>
  char *args[] = {"xx", 0};
    1090:	00006797          	auipc	a5,0x6
    1094:	2c078793          	addi	a5,a5,704 # 7350 <malloc+0x19b0>
    1098:	f4f43c23          	sd	a5,-168(s0)
    109c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    10a0:	f5840593          	addi	a1,s0,-168
    10a4:	f6840513          	addi	a0,s0,-152
    10a8:	44c040ef          	jal	54f4 <exec>
  if (ret != -1) {
    10ac:	57fd                	li	a5,-1
    10ae:	0cf51563          	bne	a0,a5,1178 <copyinstr2+0x13a>
  int pid = fork();
    10b2:	402040ef          	jal	54b4 <fork>
  if (pid < 0) {
    10b6:	0c054d63          	bltz	a0,1190 <copyinstr2+0x152>
  if (pid == 0) {
    10ba:	0e051863          	bnez	a0,11aa <copyinstr2+0x16c>
    10be:	00008797          	auipc	a5,0x8
    10c2:	52278793          	addi	a5,a5,1314 # 95e0 <big.0>
    10c6:	00009697          	auipc	a3,0x9
    10ca:	51a68693          	addi	a3,a3,1306 # a5e0 <big.0+0x1000>
      big[i] = 'x';
    10ce:	07800713          	li	a4,120
    10d2:	00e78023          	sb	a4,0(a5)
    for (int i = 0; i < PGSIZE; i++)
    10d6:	0785                	addi	a5,a5,1
    10d8:	fed79de3          	bne	a5,a3,10d2 <copyinstr2+0x94>
    big[PGSIZE] = '\0';
    10dc:	00009797          	auipc	a5,0x9
    10e0:	50078223          	sb	zero,1284(a5) # a5e0 <big.0+0x1000>
    char *args2[] = {big, big, big, 0};
    10e4:	00007797          	auipc	a5,0x7
    10e8:	2ec78793          	addi	a5,a5,748 # 83d0 <malloc+0x2a30>
    10ec:	6fb0                	ld	a2,88(a5)
    10ee:	73b4                	ld	a3,96(a5)
    10f0:	77b8                	ld	a4,104(a5)
    10f2:	7bbc                	ld	a5,112(a5)
    10f4:	f2c43823          	sd	a2,-208(s0)
    10f8:	f2d43c23          	sd	a3,-200(s0)
    10fc:	f4e43023          	sd	a4,-192(s0)
    1100:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1104:	f3040593          	addi	a1,s0,-208
    1108:	00005517          	auipc	a0,0x5
    110c:	9d050513          	addi	a0,a0,-1584 # 5ad8 <malloc+0x138>
    1110:	3e4040ef          	jal	54f4 <exec>
    if (ret != -1) {
    1114:	57fd                	li	a5,-1
    1116:	08f50663          	beq	a0,a5,11a2 <copyinstr2+0x164>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    111a:	55fd                	li	a1,-1
    111c:	00005517          	auipc	a0,0x5
    1120:	1f450513          	addi	a0,a0,500 # 6310 <malloc+0x970>
    1124:	7c8040ef          	jal	58ec <printf>
      exit(1);
    1128:	4505                	li	a0,1
    112a:	392040ef          	jal	54bc <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    112e:	862a                	mv	a2,a0
    1130:	f6840593          	addi	a1,s0,-152
    1134:	00005517          	auipc	a0,0x5
    1138:	15450513          	addi	a0,a0,340 # 6288 <malloc+0x8e8>
    113c:	7b0040ef          	jal	58ec <printf>
    exit(1);
    1140:	4505                	li	a0,1
    1142:	37a040ef          	jal	54bc <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1146:	862a                	mv	a2,a0
    1148:	f6840593          	addi	a1,s0,-152
    114c:	00005517          	auipc	a0,0x5
    1150:	15c50513          	addi	a0,a0,348 # 62a8 <malloc+0x908>
    1154:	798040ef          	jal	58ec <printf>
    exit(1);
    1158:	4505                	li	a0,1
    115a:	362040ef          	jal	54bc <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    115e:	86aa                	mv	a3,a0
    1160:	f6840613          	addi	a2,s0,-152
    1164:	85b2                	mv	a1,a2
    1166:	00005517          	auipc	a0,0x5
    116a:	16250513          	addi	a0,a0,354 # 62c8 <malloc+0x928>
    116e:	77e040ef          	jal	58ec <printf>
    exit(1);
    1172:	4505                	li	a0,1
    1174:	348040ef          	jal	54bc <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1178:	567d                	li	a2,-1
    117a:	f6840593          	addi	a1,s0,-152
    117e:	00005517          	auipc	a0,0x5
    1182:	17250513          	addi	a0,a0,370 # 62f0 <malloc+0x950>
    1186:	766040ef          	jal	58ec <printf>
    exit(1);
    118a:	4505                	li	a0,1
    118c:	330040ef          	jal	54bc <exit>
    printf("fork failed\n");
    1190:	00007517          	auipc	a0,0x7
    1194:	8c850513          	addi	a0,a0,-1848 # 7a58 <malloc+0x20b8>
    1198:	754040ef          	jal	58ec <printf>
    exit(1);
    119c:	4505                	li	a0,1
    119e:	31e040ef          	jal	54bc <exit>
    exit(747); // OK
    11a2:	2eb00513          	li	a0,747
    11a6:	316040ef          	jal	54bc <exit>
  int st = 0;
    11aa:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    11ae:	f5440513          	addi	a0,s0,-172
    11b2:	312040ef          	jal	54c4 <wait>
  if (st != 747) {
    11b6:	f5442703          	lw	a4,-172(s0)
    11ba:	2eb00793          	li	a5,747
    11be:	00f71663          	bne	a4,a5,11ca <copyinstr2+0x18c>
}
    11c2:	60ae                	ld	ra,200(sp)
    11c4:	640e                	ld	s0,192(sp)
    11c6:	6169                	addi	sp,sp,208
    11c8:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    11ca:	00005517          	auipc	a0,0x5
    11ce:	16e50513          	addi	a0,a0,366 # 6338 <malloc+0x998>
    11d2:	71a040ef          	jal	58ec <printf>
    exit(1);
    11d6:	4505                	li	a0,1
    11d8:	2e4040ef          	jal	54bc <exit>

00000000000011dc <truncate3>:
{
    11dc:	7159                	addi	sp,sp,-112
    11de:	f486                	sd	ra,104(sp)
    11e0:	f0a2                	sd	s0,96(sp)
    11e2:	e8ca                	sd	s2,80(sp)
    11e4:	1880                	addi	s0,sp,112
    11e6:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE | O_TRUNC | O_WRONLY));
    11e8:	60100593          	li	a1,1537
    11ec:	00005517          	auipc	a0,0x5
    11f0:	94450513          	addi	a0,a0,-1724 # 5b30 <malloc+0x190>
    11f4:	308040ef          	jal	54fc <open>
    11f8:	2ec040ef          	jal	54e4 <close>
  pid = fork();
    11fc:	2b8040ef          	jal	54b4 <fork>
  if (pid < 0) {
    1200:	06054663          	bltz	a0,126c <truncate3+0x90>
  if (pid == 0) {
    1204:	e55d                	bnez	a0,12b2 <truncate3+0xd6>
    1206:	eca6                	sd	s1,88(sp)
    1208:	e4ce                	sd	s3,72(sp)
    120a:	e0d2                	sd	s4,64(sp)
    120c:	fc56                	sd	s5,56(sp)
    120e:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    1212:	00005a17          	auipc	s4,0x5
    1216:	91ea0a13          	addi	s4,s4,-1762 # 5b30 <malloc+0x190>
      int n = write(fd, "1234567890", 10);
    121a:	00005a97          	auipc	s5,0x5
    121e:	17ea8a93          	addi	s5,s5,382 # 6398 <malloc+0x9f8>
      int fd = open("truncfile", O_WRONLY);
    1222:	4585                	li	a1,1
    1224:	8552                	mv	a0,s4
    1226:	2d6040ef          	jal	54fc <open>
    122a:	84aa                	mv	s1,a0
      if (fd < 0) {
    122c:	04054e63          	bltz	a0,1288 <truncate3+0xac>
      int n = write(fd, "1234567890", 10);
    1230:	4629                	li	a2,10
    1232:	85d6                	mv	a1,s5
    1234:	2a8040ef          	jal	54dc <write>
      if (n != 10) {
    1238:	47a9                	li	a5,10
    123a:	06f51163          	bne	a0,a5,129c <truncate3+0xc0>
      close(fd);
    123e:	8526                	mv	a0,s1
    1240:	2a4040ef          	jal	54e4 <close>
      fd = open("truncfile", O_RDONLY);
    1244:	4581                	li	a1,0
    1246:	8552                	mv	a0,s4
    1248:	2b4040ef          	jal	54fc <open>
    124c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    124e:	02000613          	li	a2,32
    1252:	f9840593          	addi	a1,s0,-104
    1256:	27e040ef          	jal	54d4 <read>
      close(fd);
    125a:	8526                	mv	a0,s1
    125c:	288040ef          	jal	54e4 <close>
    for (int i = 0; i < 100; i++) {
    1260:	39fd                	addiw	s3,s3,-1
    1262:	fc0990e3          	bnez	s3,1222 <truncate3+0x46>
    exit(0);
    1266:	4501                	li	a0,0
    1268:	254040ef          	jal	54bc <exit>
    126c:	eca6                	sd	s1,88(sp)
    126e:	e4ce                	sd	s3,72(sp)
    1270:	e0d2                	sd	s4,64(sp)
    1272:	fc56                	sd	s5,56(sp)
    printf("%s: fork failed\n", s);
    1274:	85ca                	mv	a1,s2
    1276:	00005517          	auipc	a0,0x5
    127a:	0f250513          	addi	a0,a0,242 # 6368 <malloc+0x9c8>
    127e:	66e040ef          	jal	58ec <printf>
    exit(1);
    1282:	4505                	li	a0,1
    1284:	238040ef          	jal	54bc <exit>
        printf("%s: open failed\n", s);
    1288:	85ca                	mv	a1,s2
    128a:	00005517          	auipc	a0,0x5
    128e:	0f650513          	addi	a0,a0,246 # 6380 <malloc+0x9e0>
    1292:	65a040ef          	jal	58ec <printf>
        exit(1);
    1296:	4505                	li	a0,1
    1298:	224040ef          	jal	54bc <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    129c:	862a                	mv	a2,a0
    129e:	85ca                	mv	a1,s2
    12a0:	00005517          	auipc	a0,0x5
    12a4:	10850513          	addi	a0,a0,264 # 63a8 <malloc+0xa08>
    12a8:	644040ef          	jal	58ec <printf>
        exit(1);
    12ac:	4505                	li	a0,1
    12ae:	20e040ef          	jal	54bc <exit>
    12b2:	eca6                	sd	s1,88(sp)
    12b4:	e4ce                	sd	s3,72(sp)
    12b6:	e0d2                	sd	s4,64(sp)
    12b8:	fc56                	sd	s5,56(sp)
    12ba:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    12be:	00005a17          	auipc	s4,0x5
    12c2:	872a0a13          	addi	s4,s4,-1934 # 5b30 <malloc+0x190>
    int n = write(fd, "xxx", 3);
    12c6:	00005a97          	auipc	s5,0x5
    12ca:	102a8a93          	addi	s5,s5,258 # 63c8 <malloc+0xa28>
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    12ce:	60100593          	li	a1,1537
    12d2:	8552                	mv	a0,s4
    12d4:	228040ef          	jal	54fc <open>
    12d8:	84aa                	mv	s1,a0
    if (fd < 0) {
    12da:	02054d63          	bltz	a0,1314 <truncate3+0x138>
    int n = write(fd, "xxx", 3);
    12de:	460d                	li	a2,3
    12e0:	85d6                	mv	a1,s5
    12e2:	1fa040ef          	jal	54dc <write>
    if (n != 3) {
    12e6:	478d                	li	a5,3
    12e8:	04f51063          	bne	a0,a5,1328 <truncate3+0x14c>
    close(fd);
    12ec:	8526                	mv	a0,s1
    12ee:	1f6040ef          	jal	54e4 <close>
  for (int i = 0; i < 150; i++) {
    12f2:	39fd                	addiw	s3,s3,-1
    12f4:	fc099de3          	bnez	s3,12ce <truncate3+0xf2>
  wait(&xstatus);
    12f8:	fbc40513          	addi	a0,s0,-68
    12fc:	1c8040ef          	jal	54c4 <wait>
  unlink("truncfile");
    1300:	00005517          	auipc	a0,0x5
    1304:	83050513          	addi	a0,a0,-2000 # 5b30 <malloc+0x190>
    1308:	204040ef          	jal	550c <unlink>
  exit(xstatus);
    130c:	fbc42503          	lw	a0,-68(s0)
    1310:	1ac040ef          	jal	54bc <exit>
      printf("%s: open failed\n", s);
    1314:	85ca                	mv	a1,s2
    1316:	00005517          	auipc	a0,0x5
    131a:	06a50513          	addi	a0,a0,106 # 6380 <malloc+0x9e0>
    131e:	5ce040ef          	jal	58ec <printf>
      exit(1);
    1322:	4505                	li	a0,1
    1324:	198040ef          	jal	54bc <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1328:	862a                	mv	a2,a0
    132a:	85ca                	mv	a1,s2
    132c:	00005517          	auipc	a0,0x5
    1330:	0a450513          	addi	a0,a0,164 # 63d0 <malloc+0xa30>
    1334:	5b8040ef          	jal	58ec <printf>
      exit(1);
    1338:	4505                	li	a0,1
    133a:	182040ef          	jal	54bc <exit>

000000000000133e <pipe1>:
{
    133e:	711d                	addi	sp,sp,-96
    1340:	ec86                	sd	ra,88(sp)
    1342:	e8a2                	sd	s0,80(sp)
    1344:	fc4e                	sd	s3,56(sp)
    1346:	1080                	addi	s0,sp,96
    1348:	89aa                	mv	s3,a0
  if (pipe(fds) != 0) {
    134a:	fa840513          	addi	a0,s0,-88
    134e:	17e040ef          	jal	54cc <pipe>
    1352:	e92d                	bnez	a0,13c4 <pipe1+0x86>
    1354:	e4a6                	sd	s1,72(sp)
    1356:	f852                	sd	s4,48(sp)
    1358:	84aa                	mv	s1,a0
  pid = fork();
    135a:	15a040ef          	jal	54b4 <fork>
    135e:	8a2a                	mv	s4,a0
  if (pid == 0) {
    1360:	c151                	beqz	a0,13e4 <pipe1+0xa6>
  } else if (pid > 0) {
    1362:	14a05e63          	blez	a0,14be <pipe1+0x180>
    1366:	e0ca                	sd	s2,64(sp)
    1368:	f456                	sd	s5,40(sp)
    close(fds[1]);
    136a:	fac42503          	lw	a0,-84(s0)
    136e:	176040ef          	jal	54e4 <close>
    total = 0;
    1372:	8a26                	mv	s4,s1
    cc = 1;
    1374:	4905                	li	s2,1
    while ((n = read(fds[0], buf, cc)) > 0) {
    1376:	0000ca97          	auipc	s5,0xc
    137a:	982a8a93          	addi	s5,s5,-1662 # ccf8 <buf>
    137e:	864a                	mv	a2,s2
    1380:	85d6                	mv	a1,s5
    1382:	fa842503          	lw	a0,-88(s0)
    1386:	14e040ef          	jal	54d4 <read>
    138a:	0ea05a63          	blez	a0,147e <pipe1+0x140>
      for (i = 0; i < n; i++) {
    138e:	0000c717          	auipc	a4,0xc
    1392:	96a70713          	addi	a4,a4,-1686 # ccf8 <buf>
    1396:	00a4863b          	addw	a2,s1,a0
        if ((buf[i] & 0xff) != (seq++ & 0xff)) {
    139a:	00074683          	lbu	a3,0(a4)
    139e:	0ff4f793          	zext.b	a5,s1
    13a2:	2485                	addiw	s1,s1,1
    13a4:	0af69d63          	bne	a3,a5,145e <pipe1+0x120>
      for (i = 0; i < n; i++) {
    13a8:	0705                	addi	a4,a4,1
    13aa:	fec498e3          	bne	s1,a2,139a <pipe1+0x5c>
      total += n;
    13ae:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    13b2:	0019179b          	slliw	a5,s2,0x1
    13b6:	0007891b          	sext.w	s2,a5
      if (cc > sizeof(buf))
    13ba:	670d                	lui	a4,0x3
    13bc:	fd2771e3          	bgeu	a4,s2,137e <pipe1+0x40>
        cc = sizeof(buf);
    13c0:	690d                	lui	s2,0x3
    13c2:	bf75                	j	137e <pipe1+0x40>
    13c4:	e4a6                	sd	s1,72(sp)
    13c6:	e0ca                	sd	s2,64(sp)
    13c8:	f852                	sd	s4,48(sp)
    13ca:	f456                	sd	s5,40(sp)
    13cc:	f05a                	sd	s6,32(sp)
    13ce:	ec5e                	sd	s7,24(sp)
    printf("%s: pipe() failed\n", s);
    13d0:	85ce                	mv	a1,s3
    13d2:	00005517          	auipc	a0,0x5
    13d6:	01e50513          	addi	a0,a0,30 # 63f0 <malloc+0xa50>
    13da:	512040ef          	jal	58ec <printf>
    exit(1);
    13de:	4505                	li	a0,1
    13e0:	0dc040ef          	jal	54bc <exit>
    13e4:	e0ca                	sd	s2,64(sp)
    13e6:	f456                	sd	s5,40(sp)
    13e8:	f05a                	sd	s6,32(sp)
    13ea:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    13ec:	fa842503          	lw	a0,-88(s0)
    13f0:	0f4040ef          	jal	54e4 <close>
    for (n = 0; n < N; n++) {
    13f4:	0000cb17          	auipc	s6,0xc
    13f8:	904b0b13          	addi	s6,s6,-1788 # ccf8 <buf>
    13fc:	416004bb          	negw	s1,s6
    1400:	0ff4f493          	zext.b	s1,s1
    1404:	409b0913          	addi	s2,s6,1033
      if (write(fds[1], buf, SZ) != SZ) {
    1408:	8bda                	mv	s7,s6
    for (n = 0; n < N; n++) {
    140a:	6a85                	lui	s5,0x1
    140c:	42da8a93          	addi	s5,s5,1069 # 142d <pipe1+0xef>
{
    1410:	87da                	mv	a5,s6
        buf[i] = seq++;
    1412:	0097873b          	addw	a4,a5,s1
    1416:	00e78023          	sb	a4,0(a5)
      for (i = 0; i < SZ; i++)
    141a:	0785                	addi	a5,a5,1
    141c:	ff279be3          	bne	a5,s2,1412 <pipe1+0xd4>
    1420:	409a0a1b          	addiw	s4,s4,1033
      if (write(fds[1], buf, SZ) != SZ) {
    1424:	40900613          	li	a2,1033
    1428:	85de                	mv	a1,s7
    142a:	fac42503          	lw	a0,-84(s0)
    142e:	0ae040ef          	jal	54dc <write>
    1432:	40900793          	li	a5,1033
    1436:	00f51a63          	bne	a0,a5,144a <pipe1+0x10c>
    for (n = 0; n < N; n++) {
    143a:	24a5                	addiw	s1,s1,9
    143c:	0ff4f493          	zext.b	s1,s1
    1440:	fd5a18e3          	bne	s4,s5,1410 <pipe1+0xd2>
    exit(0);
    1444:	4501                	li	a0,0
    1446:	076040ef          	jal	54bc <exit>
        printf("%s: pipe1 oops 1\n", s);
    144a:	85ce                	mv	a1,s3
    144c:	00005517          	auipc	a0,0x5
    1450:	fbc50513          	addi	a0,a0,-68 # 6408 <malloc+0xa68>
    1454:	498040ef          	jal	58ec <printf>
        exit(1);
    1458:	4505                	li	a0,1
    145a:	062040ef          	jal	54bc <exit>
          printf("%s: pipe1 oops 2\n", s);
    145e:	85ce                	mv	a1,s3
    1460:	00005517          	auipc	a0,0x5
    1464:	fc050513          	addi	a0,a0,-64 # 6420 <malloc+0xa80>
    1468:	484040ef          	jal	58ec <printf>
          return;
    146c:	64a6                	ld	s1,72(sp)
    146e:	6906                	ld	s2,64(sp)
    1470:	7a42                	ld	s4,48(sp)
    1472:	7aa2                	ld	s5,40(sp)
}
    1474:	60e6                	ld	ra,88(sp)
    1476:	6446                	ld	s0,80(sp)
    1478:	79e2                	ld	s3,56(sp)
    147a:	6125                	addi	sp,sp,96
    147c:	8082                	ret
    if (total != N * SZ) {
    147e:	6785                	lui	a5,0x1
    1480:	42d78793          	addi	a5,a5,1069 # 142d <pipe1+0xef>
    1484:	00fa0f63          	beq	s4,a5,14a2 <pipe1+0x164>
    1488:	f05a                	sd	s6,32(sp)
    148a:	ec5e                	sd	s7,24(sp)
      printf("%s: pipe1 oops 3 total %d\n", s, total);
    148c:	8652                	mv	a2,s4
    148e:	85ce                	mv	a1,s3
    1490:	00005517          	auipc	a0,0x5
    1494:	fa850513          	addi	a0,a0,-88 # 6438 <malloc+0xa98>
    1498:	454040ef          	jal	58ec <printf>
      exit(1);
    149c:	4505                	li	a0,1
    149e:	01e040ef          	jal	54bc <exit>
    14a2:	f05a                	sd	s6,32(sp)
    14a4:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    14a6:	fa842503          	lw	a0,-88(s0)
    14aa:	03a040ef          	jal	54e4 <close>
    wait(&xstatus);
    14ae:	fa440513          	addi	a0,s0,-92
    14b2:	012040ef          	jal	54c4 <wait>
    exit(xstatus);
    14b6:	fa442503          	lw	a0,-92(s0)
    14ba:	002040ef          	jal	54bc <exit>
    14be:	e0ca                	sd	s2,64(sp)
    14c0:	f456                	sd	s5,40(sp)
    14c2:	f05a                	sd	s6,32(sp)
    14c4:	ec5e                	sd	s7,24(sp)
    printf("%s: fork() failed\n", s);
    14c6:	85ce                	mv	a1,s3
    14c8:	00005517          	auipc	a0,0x5
    14cc:	f9050513          	addi	a0,a0,-112 # 6458 <malloc+0xab8>
    14d0:	41c040ef          	jal	58ec <printf>
    exit(1);
    14d4:	4505                	li	a0,1
    14d6:	7e7030ef          	jal	54bc <exit>

00000000000014da <exitwait>:
{
    14da:	7139                	addi	sp,sp,-64
    14dc:	fc06                	sd	ra,56(sp)
    14de:	f822                	sd	s0,48(sp)
    14e0:	f426                	sd	s1,40(sp)
    14e2:	f04a                	sd	s2,32(sp)
    14e4:	ec4e                	sd	s3,24(sp)
    14e6:	e852                	sd	s4,16(sp)
    14e8:	0080                	addi	s0,sp,64
    14ea:	8a2a                	mv	s4,a0
  for (i = 0; i < 100; i++) {
    14ec:	4901                	li	s2,0
    14ee:	06400993          	li	s3,100
    pid = fork();
    14f2:	7c3030ef          	jal	54b4 <fork>
    14f6:	84aa                	mv	s1,a0
    if (pid < 0) {
    14f8:	02054863          	bltz	a0,1528 <exitwait+0x4e>
    if (pid) {
    14fc:	c525                	beqz	a0,1564 <exitwait+0x8a>
      if (wait(&xstate) != pid) {
    14fe:	fcc40513          	addi	a0,s0,-52
    1502:	7c3030ef          	jal	54c4 <wait>
    1506:	02951b63          	bne	a0,s1,153c <exitwait+0x62>
      if (i != xstate) {
    150a:	fcc42783          	lw	a5,-52(s0)
    150e:	05279163          	bne	a5,s2,1550 <exitwait+0x76>
  for (i = 0; i < 100; i++) {
    1512:	2905                	addiw	s2,s2,1 # 3001 <subdir+0x5b5>
    1514:	fd391fe3          	bne	s2,s3,14f2 <exitwait+0x18>
}
    1518:	70e2                	ld	ra,56(sp)
    151a:	7442                	ld	s0,48(sp)
    151c:	74a2                	ld	s1,40(sp)
    151e:	7902                	ld	s2,32(sp)
    1520:	69e2                	ld	s3,24(sp)
    1522:	6a42                	ld	s4,16(sp)
    1524:	6121                	addi	sp,sp,64
    1526:	8082                	ret
      printf("%s: fork failed\n", s);
    1528:	85d2                	mv	a1,s4
    152a:	00005517          	auipc	a0,0x5
    152e:	e3e50513          	addi	a0,a0,-450 # 6368 <malloc+0x9c8>
    1532:	3ba040ef          	jal	58ec <printf>
      exit(1);
    1536:	4505                	li	a0,1
    1538:	785030ef          	jal	54bc <exit>
        printf("%s: wait wrong pid\n", s);
    153c:	85d2                	mv	a1,s4
    153e:	00005517          	auipc	a0,0x5
    1542:	f3250513          	addi	a0,a0,-206 # 6470 <malloc+0xad0>
    1546:	3a6040ef          	jal	58ec <printf>
        exit(1);
    154a:	4505                	li	a0,1
    154c:	771030ef          	jal	54bc <exit>
        printf("%s: wait wrong exit status\n", s);
    1550:	85d2                	mv	a1,s4
    1552:	00005517          	auipc	a0,0x5
    1556:	f3650513          	addi	a0,a0,-202 # 6488 <malloc+0xae8>
    155a:	392040ef          	jal	58ec <printf>
        exit(1);
    155e:	4505                	li	a0,1
    1560:	75d030ef          	jal	54bc <exit>
      exit(i);
    1564:	854a                	mv	a0,s2
    1566:	757030ef          	jal	54bc <exit>

000000000000156a <twochildren>:
{
    156a:	1101                	addi	sp,sp,-32
    156c:	ec06                	sd	ra,24(sp)
    156e:	e822                	sd	s0,16(sp)
    1570:	e426                	sd	s1,8(sp)
    1572:	e04a                	sd	s2,0(sp)
    1574:	1000                	addi	s0,sp,32
    1576:	892a                	mv	s2,a0
    1578:	3e800493          	li	s1,1000
    int pid1 = fork();
    157c:	739030ef          	jal	54b4 <fork>
    if (pid1 < 0) {
    1580:	02054663          	bltz	a0,15ac <twochildren+0x42>
    if (pid1 == 0) {
    1584:	cd15                	beqz	a0,15c0 <twochildren+0x56>
      int pid2 = fork();
    1586:	72f030ef          	jal	54b4 <fork>
      if (pid2 < 0) {
    158a:	02054d63          	bltz	a0,15c4 <twochildren+0x5a>
      if (pid2 == 0) {
    158e:	c529                	beqz	a0,15d8 <twochildren+0x6e>
        wait(0);
    1590:	4501                	li	a0,0
    1592:	733030ef          	jal	54c4 <wait>
        wait(0);
    1596:	4501                	li	a0,0
    1598:	72d030ef          	jal	54c4 <wait>
  for (int i = 0; i < 1000; i++) {
    159c:	34fd                	addiw	s1,s1,-1
    159e:	fcf9                	bnez	s1,157c <twochildren+0x12>
}
    15a0:	60e2                	ld	ra,24(sp)
    15a2:	6442                	ld	s0,16(sp)
    15a4:	64a2                	ld	s1,8(sp)
    15a6:	6902                	ld	s2,0(sp)
    15a8:	6105                	addi	sp,sp,32
    15aa:	8082                	ret
      printf("%s: fork failed\n", s);
    15ac:	85ca                	mv	a1,s2
    15ae:	00005517          	auipc	a0,0x5
    15b2:	dba50513          	addi	a0,a0,-582 # 6368 <malloc+0x9c8>
    15b6:	336040ef          	jal	58ec <printf>
      exit(1);
    15ba:	4505                	li	a0,1
    15bc:	701030ef          	jal	54bc <exit>
      exit(0);
    15c0:	6fd030ef          	jal	54bc <exit>
        printf("%s: fork failed\n", s);
    15c4:	85ca                	mv	a1,s2
    15c6:	00005517          	auipc	a0,0x5
    15ca:	da250513          	addi	a0,a0,-606 # 6368 <malloc+0x9c8>
    15ce:	31e040ef          	jal	58ec <printf>
        exit(1);
    15d2:	4505                	li	a0,1
    15d4:	6e9030ef          	jal	54bc <exit>
        exit(0);
    15d8:	6e5030ef          	jal	54bc <exit>

00000000000015dc <forkfork>:
{
    15dc:	7179                	addi	sp,sp,-48
    15de:	f406                	sd	ra,40(sp)
    15e0:	f022                	sd	s0,32(sp)
    15e2:	ec26                	sd	s1,24(sp)
    15e4:	1800                	addi	s0,sp,48
    15e6:	84aa                	mv	s1,a0
    int pid = fork();
    15e8:	6cd030ef          	jal	54b4 <fork>
    if (pid < 0) {
    15ec:	02054b63          	bltz	a0,1622 <forkfork+0x46>
    if (pid == 0) {
    15f0:	c139                	beqz	a0,1636 <forkfork+0x5a>
    int pid = fork();
    15f2:	6c3030ef          	jal	54b4 <fork>
    if (pid < 0) {
    15f6:	02054663          	bltz	a0,1622 <forkfork+0x46>
    if (pid == 0) {
    15fa:	cd15                	beqz	a0,1636 <forkfork+0x5a>
    wait(&xstatus);
    15fc:	fdc40513          	addi	a0,s0,-36
    1600:	6c5030ef          	jal	54c4 <wait>
    if (xstatus != 0) {
    1604:	fdc42783          	lw	a5,-36(s0)
    1608:	ebb9                	bnez	a5,165e <forkfork+0x82>
    wait(&xstatus);
    160a:	fdc40513          	addi	a0,s0,-36
    160e:	6b7030ef          	jal	54c4 <wait>
    if (xstatus != 0) {
    1612:	fdc42783          	lw	a5,-36(s0)
    1616:	e7a1                	bnez	a5,165e <forkfork+0x82>
}
    1618:	70a2                	ld	ra,40(sp)
    161a:	7402                	ld	s0,32(sp)
    161c:	64e2                	ld	s1,24(sp)
    161e:	6145                	addi	sp,sp,48
    1620:	8082                	ret
      printf("%s: fork failed", s);
    1622:	85a6                	mv	a1,s1
    1624:	00005517          	auipc	a0,0x5
    1628:	e8450513          	addi	a0,a0,-380 # 64a8 <malloc+0xb08>
    162c:	2c0040ef          	jal	58ec <printf>
      exit(1);
    1630:	4505                	li	a0,1
    1632:	68b030ef          	jal	54bc <exit>
{
    1636:	0c800493          	li	s1,200
        int pid1 = fork();
    163a:	67b030ef          	jal	54b4 <fork>
        if (pid1 < 0) {
    163e:	00054b63          	bltz	a0,1654 <forkfork+0x78>
        if (pid1 == 0) {
    1642:	cd01                	beqz	a0,165a <forkfork+0x7e>
        wait(0);
    1644:	4501                	li	a0,0
    1646:	67f030ef          	jal	54c4 <wait>
      for (int j = 0; j < 200; j++) {
    164a:	34fd                	addiw	s1,s1,-1
    164c:	f4fd                	bnez	s1,163a <forkfork+0x5e>
      exit(0);
    164e:	4501                	li	a0,0
    1650:	66d030ef          	jal	54bc <exit>
          exit(1);
    1654:	4505                	li	a0,1
    1656:	667030ef          	jal	54bc <exit>
          exit(0);
    165a:	663030ef          	jal	54bc <exit>
      printf("%s: fork in child failed", s);
    165e:	85a6                	mv	a1,s1
    1660:	00005517          	auipc	a0,0x5
    1664:	e5850513          	addi	a0,a0,-424 # 64b8 <malloc+0xb18>
    1668:	284040ef          	jal	58ec <printf>
      exit(1);
    166c:	4505                	li	a0,1
    166e:	64f030ef          	jal	54bc <exit>

0000000000001672 <reparent2>:
{
    1672:	1101                	addi	sp,sp,-32
    1674:	ec06                	sd	ra,24(sp)
    1676:	e822                	sd	s0,16(sp)
    1678:	e426                	sd	s1,8(sp)
    167a:	1000                	addi	s0,sp,32
    167c:	32000493          	li	s1,800
    int pid1 = fork();
    1680:	635030ef          	jal	54b4 <fork>
    if (pid1 < 0) {
    1684:	00054b63          	bltz	a0,169a <reparent2+0x28>
    if (pid1 == 0) {
    1688:	c115                	beqz	a0,16ac <reparent2+0x3a>
    wait(0);
    168a:	4501                	li	a0,0
    168c:	639030ef          	jal	54c4 <wait>
  for (int i = 0; i < 800; i++) {
    1690:	34fd                	addiw	s1,s1,-1
    1692:	f4fd                	bnez	s1,1680 <reparent2+0xe>
  exit(0);
    1694:	4501                	li	a0,0
    1696:	627030ef          	jal	54bc <exit>
      printf("fork failed\n");
    169a:	00006517          	auipc	a0,0x6
    169e:	3be50513          	addi	a0,a0,958 # 7a58 <malloc+0x20b8>
    16a2:	24a040ef          	jal	58ec <printf>
      exit(1);
    16a6:	4505                	li	a0,1
    16a8:	615030ef          	jal	54bc <exit>
      fork();
    16ac:	609030ef          	jal	54b4 <fork>
      fork();
    16b0:	605030ef          	jal	54b4 <fork>
      exit(0);
    16b4:	4501                	li	a0,0
    16b6:	607030ef          	jal	54bc <exit>

00000000000016ba <createdelete>:
{
    16ba:	7175                	addi	sp,sp,-144
    16bc:	e506                	sd	ra,136(sp)
    16be:	e122                	sd	s0,128(sp)
    16c0:	fca6                	sd	s1,120(sp)
    16c2:	f8ca                	sd	s2,112(sp)
    16c4:	f4ce                	sd	s3,104(sp)
    16c6:	f0d2                	sd	s4,96(sp)
    16c8:	ecd6                	sd	s5,88(sp)
    16ca:	e8da                	sd	s6,80(sp)
    16cc:	e4de                	sd	s7,72(sp)
    16ce:	e0e2                	sd	s8,64(sp)
    16d0:	fc66                	sd	s9,56(sp)
    16d2:	0900                	addi	s0,sp,144
    16d4:	8caa                	mv	s9,a0
  for (pi = 0; pi < NCHILD; pi++) {
    16d6:	4901                	li	s2,0
    16d8:	4991                	li	s3,4
    pid = fork();
    16da:	5db030ef          	jal	54b4 <fork>
    16de:	84aa                	mv	s1,a0
    if (pid < 0) {
    16e0:	02054d63          	bltz	a0,171a <createdelete+0x60>
    if (pid == 0) {
    16e4:	c529                	beqz	a0,172e <createdelete+0x74>
  for (pi = 0; pi < NCHILD; pi++) {
    16e6:	2905                	addiw	s2,s2,1
    16e8:	ff3919e3          	bne	s2,s3,16da <createdelete+0x20>
    16ec:	4491                	li	s1,4
    wait(&xstatus);
    16ee:	f7c40513          	addi	a0,s0,-132
    16f2:	5d3030ef          	jal	54c4 <wait>
    if (xstatus != 0)
    16f6:	f7c42903          	lw	s2,-132(s0)
    16fa:	0a091e63          	bnez	s2,17b6 <createdelete+0xfc>
  for (pi = 0; pi < NCHILD; pi++) {
    16fe:	34fd                	addiw	s1,s1,-1
    1700:	f4fd                	bnez	s1,16ee <createdelete+0x34>
  name[0] = name[1] = name[2] = 0;
    1702:	f8040123          	sb	zero,-126(s0)
    1706:	03000993          	li	s3,48
    170a:	5a7d                	li	s4,-1
    170c:	07000c13          	li	s8,112
      if ((i == 0 || i >= N / 2) && fd < 0) {
    1710:	4b25                	li	s6,9
      } else if ((i >= 1 && i < N / 2) && fd >= 0) {
    1712:	4ba1                	li	s7,8
    for (pi = 0; pi < NCHILD; pi++) {
    1714:	07400a93          	li	s5,116
    1718:	aa39                	j	1836 <createdelete+0x17c>
      printf("%s: fork failed\n", s);
    171a:	85e6                	mv	a1,s9
    171c:	00005517          	auipc	a0,0x5
    1720:	c4c50513          	addi	a0,a0,-948 # 6368 <malloc+0x9c8>
    1724:	1c8040ef          	jal	58ec <printf>
      exit(1);
    1728:	4505                	li	a0,1
    172a:	593030ef          	jal	54bc <exit>
      name[0] = 'p' + pi;
    172e:	0709091b          	addiw	s2,s2,112
    1732:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1736:	f8040123          	sb	zero,-126(s0)
      for (i = 0; i < N; i++) {
    173a:	4951                	li	s2,20
    173c:	a831                	j	1758 <createdelete+0x9e>
          printf("%s: create failed\n", s);
    173e:	85e6                	mv	a1,s9
    1740:	00005517          	auipc	a0,0x5
    1744:	d9850513          	addi	a0,a0,-616 # 64d8 <malloc+0xb38>
    1748:	1a4040ef          	jal	58ec <printf>
          exit(1);
    174c:	4505                	li	a0,1
    174e:	56f030ef          	jal	54bc <exit>
      for (i = 0; i < N; i++) {
    1752:	2485                	addiw	s1,s1,1
    1754:	05248e63          	beq	s1,s2,17b0 <createdelete+0xf6>
        name[1] = '0' + i;
    1758:	0304879b          	addiw	a5,s1,48
    175c:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1760:	20200593          	li	a1,514
    1764:	f8040513          	addi	a0,s0,-128
    1768:	595030ef          	jal	54fc <open>
        if (fd < 0) {
    176c:	fc0549e3          	bltz	a0,173e <createdelete+0x84>
        close(fd);
    1770:	575030ef          	jal	54e4 <close>
        if (i > 0 && (i % 2) == 0) {
    1774:	10905063          	blez	s1,1874 <createdelete+0x1ba>
    1778:	0014f793          	andi	a5,s1,1
    177c:	fbf9                	bnez	a5,1752 <createdelete+0x98>
          name[1] = '0' + (i / 2);
    177e:	01f4d79b          	srliw	a5,s1,0x1f
    1782:	9fa5                	addw	a5,a5,s1
    1784:	4017d79b          	sraiw	a5,a5,0x1
    1788:	0307879b          	addiw	a5,a5,48
    178c:	f8f400a3          	sb	a5,-127(s0)
          if (unlink(name) < 0) {
    1790:	f8040513          	addi	a0,s0,-128
    1794:	579030ef          	jal	550c <unlink>
    1798:	fa055de3          	bgez	a0,1752 <createdelete+0x98>
            printf("%s: unlink failed\n", s);
    179c:	85e6                	mv	a1,s9
    179e:	00005517          	auipc	a0,0x5
    17a2:	d5250513          	addi	a0,a0,-686 # 64f0 <malloc+0xb50>
    17a6:	146040ef          	jal	58ec <printf>
            exit(1);
    17aa:	4505                	li	a0,1
    17ac:	511030ef          	jal	54bc <exit>
      exit(0);
    17b0:	4501                	li	a0,0
    17b2:	50b030ef          	jal	54bc <exit>
      exit(1);
    17b6:	4505                	li	a0,1
    17b8:	505030ef          	jal	54bc <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    17bc:	f8040613          	addi	a2,s0,-128
    17c0:	85e6                	mv	a1,s9
    17c2:	00005517          	auipc	a0,0x5
    17c6:	d4650513          	addi	a0,a0,-698 # 6508 <malloc+0xb68>
    17ca:	122040ef          	jal	58ec <printf>
        exit(1);
    17ce:	4505                	li	a0,1
    17d0:	4ed030ef          	jal	54bc <exit>
      } else if ((i >= 1 && i < N / 2) && fd >= 0) {
    17d4:	034bfb63          	bgeu	s7,s4,180a <createdelete+0x150>
      if (fd >= 0)
    17d8:	02055663          	bgez	a0,1804 <createdelete+0x14a>
    for (pi = 0; pi < NCHILD; pi++) {
    17dc:	2485                	addiw	s1,s1,1
    17de:	0ff4f493          	zext.b	s1,s1
    17e2:	05548263          	beq	s1,s5,1826 <createdelete+0x16c>
      name[0] = 'p' + pi;
    17e6:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    17ea:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    17ee:	4581                	li	a1,0
    17f0:	f8040513          	addi	a0,s0,-128
    17f4:	509030ef          	jal	54fc <open>
      if ((i == 0 || i >= N / 2) && fd < 0) {
    17f8:	00090463          	beqz	s2,1800 <createdelete+0x146>
    17fc:	fd2b5ce3          	bge	s6,s2,17d4 <createdelete+0x11a>
    1800:	fa054ee3          	bltz	a0,17bc <createdelete+0x102>
        close(fd);
    1804:	4e1030ef          	jal	54e4 <close>
    1808:	bfd1                	j	17dc <createdelete+0x122>
      } else if ((i >= 1 && i < N / 2) && fd >= 0) {
    180a:	fc0549e3          	bltz	a0,17dc <createdelete+0x122>
        printf("%s: oops createdelete %s did exist\n", s, name);
    180e:	f8040613          	addi	a2,s0,-128
    1812:	85e6                	mv	a1,s9
    1814:	00005517          	auipc	a0,0x5
    1818:	d1c50513          	addi	a0,a0,-740 # 6530 <malloc+0xb90>
    181c:	0d0040ef          	jal	58ec <printf>
        exit(1);
    1820:	4505                	li	a0,1
    1822:	49b030ef          	jal	54bc <exit>
  for (i = 0; i < N; i++) {
    1826:	2905                	addiw	s2,s2,1
    1828:	2a05                	addiw	s4,s4,1
    182a:	2985                	addiw	s3,s3,1
    182c:	0ff9f993          	zext.b	s3,s3
    1830:	47d1                	li	a5,20
    1832:	02f90863          	beq	s2,a5,1862 <createdelete+0x1a8>
    for (pi = 0; pi < NCHILD; pi++) {
    1836:	84e2                	mv	s1,s8
    1838:	b77d                	j	17e6 <createdelete+0x12c>
  for (i = 0; i < N; i++) {
    183a:	2905                	addiw	s2,s2,1
    183c:	0ff97913          	zext.b	s2,s2
    1840:	03490c63          	beq	s2,s4,1878 <createdelete+0x1be>
  name[0] = name[1] = name[2] = 0;
    1844:	84d6                	mv	s1,s5
      name[0] = 'p' + pi;
    1846:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    184a:	f92400a3          	sb	s2,-127(s0)
      unlink(name);
    184e:	f8040513          	addi	a0,s0,-128
    1852:	4bb030ef          	jal	550c <unlink>
    for (pi = 0; pi < NCHILD; pi++) {
    1856:	2485                	addiw	s1,s1,1
    1858:	0ff4f493          	zext.b	s1,s1
    185c:	ff3495e3          	bne	s1,s3,1846 <createdelete+0x18c>
    1860:	bfe9                	j	183a <createdelete+0x180>
    1862:	03000913          	li	s2,48
  name[0] = name[1] = name[2] = 0;
    1866:	07000a93          	li	s5,112
    for (pi = 0; pi < NCHILD; pi++) {
    186a:	07400993          	li	s3,116
  for (i = 0; i < N; i++) {
    186e:	04400a13          	li	s4,68
    1872:	bfc9                	j	1844 <createdelete+0x18a>
      for (i = 0; i < N; i++) {
    1874:	2485                	addiw	s1,s1,1
    1876:	b5cd                	j	1758 <createdelete+0x9e>
}
    1878:	60aa                	ld	ra,136(sp)
    187a:	640a                	ld	s0,128(sp)
    187c:	74e6                	ld	s1,120(sp)
    187e:	7946                	ld	s2,112(sp)
    1880:	79a6                	ld	s3,104(sp)
    1882:	7a06                	ld	s4,96(sp)
    1884:	6ae6                	ld	s5,88(sp)
    1886:	6b46                	ld	s6,80(sp)
    1888:	6ba6                	ld	s7,72(sp)
    188a:	6c06                	ld	s8,64(sp)
    188c:	7ce2                	ld	s9,56(sp)
    188e:	6149                	addi	sp,sp,144
    1890:	8082                	ret

0000000000001892 <linkunlink>:
{
    1892:	711d                	addi	sp,sp,-96
    1894:	ec86                	sd	ra,88(sp)
    1896:	e8a2                	sd	s0,80(sp)
    1898:	e4a6                	sd	s1,72(sp)
    189a:	e0ca                	sd	s2,64(sp)
    189c:	fc4e                	sd	s3,56(sp)
    189e:	f852                	sd	s4,48(sp)
    18a0:	f456                	sd	s5,40(sp)
    18a2:	f05a                	sd	s6,32(sp)
    18a4:	ec5e                	sd	s7,24(sp)
    18a6:	e862                	sd	s8,16(sp)
    18a8:	e466                	sd	s9,8(sp)
    18aa:	1080                	addi	s0,sp,96
    18ac:	84aa                	mv	s1,a0
  unlink("x");
    18ae:	00004517          	auipc	a0,0x4
    18b2:	29a50513          	addi	a0,a0,666 # 5b48 <malloc+0x1a8>
    18b6:	457030ef          	jal	550c <unlink>
  pid = fork();
    18ba:	3fb030ef          	jal	54b4 <fork>
  if (pid < 0) {
    18be:	02054b63          	bltz	a0,18f4 <linkunlink+0x62>
    18c2:	8caa                	mv	s9,a0
  unsigned int x = (pid ? 1 : 97);
    18c4:	06100913          	li	s2,97
    18c8:	c111                	beqz	a0,18cc <linkunlink+0x3a>
    18ca:	4905                	li	s2,1
    18cc:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    18d0:	41c65a37          	lui	s4,0x41c65
    18d4:	e6da0a1b          	addiw	s4,s4,-403 # 41c64e6d <base+0x41c55175>
    18d8:	698d                	lui	s3,0x3
    18da:	0399899b          	addiw	s3,s3,57 # 3039 <subdir+0x5ed>
    if ((x % 3) == 0) {
    18de:	4a8d                	li	s5,3
    } else if ((x % 3) == 1) {
    18e0:	4b85                	li	s7,1
      unlink("x");
    18e2:	00004b17          	auipc	s6,0x4
    18e6:	266b0b13          	addi	s6,s6,614 # 5b48 <malloc+0x1a8>
      link("cat", "x");
    18ea:	00005c17          	auipc	s8,0x5
    18ee:	c6ec0c13          	addi	s8,s8,-914 # 6558 <malloc+0xbb8>
    18f2:	a025                	j	191a <linkunlink+0x88>
    printf("%s: fork failed\n", s);
    18f4:	85a6                	mv	a1,s1
    18f6:	00005517          	auipc	a0,0x5
    18fa:	a7250513          	addi	a0,a0,-1422 # 6368 <malloc+0x9c8>
    18fe:	7ef030ef          	jal	58ec <printf>
    exit(1);
    1902:	4505                	li	a0,1
    1904:	3b9030ef          	jal	54bc <exit>
      close(open("x", O_RDWR | O_CREATE));
    1908:	20200593          	li	a1,514
    190c:	855a                	mv	a0,s6
    190e:	3ef030ef          	jal	54fc <open>
    1912:	3d3030ef          	jal	54e4 <close>
  for (i = 0; i < 100; i++) {
    1916:	34fd                	addiw	s1,s1,-1
    1918:	c495                	beqz	s1,1944 <linkunlink+0xb2>
    x = x * 1103515245 + 12345;
    191a:	034907bb          	mulw	a5,s2,s4
    191e:	013787bb          	addw	a5,a5,s3
    1922:	0007891b          	sext.w	s2,a5
    if ((x % 3) == 0) {
    1926:	0357f7bb          	remuw	a5,a5,s5
    192a:	2781                	sext.w	a5,a5
    192c:	dff1                	beqz	a5,1908 <linkunlink+0x76>
    } else if ((x % 3) == 1) {
    192e:	01778663          	beq	a5,s7,193a <linkunlink+0xa8>
      unlink("x");
    1932:	855a                	mv	a0,s6
    1934:	3d9030ef          	jal	550c <unlink>
    1938:	bff9                	j	1916 <linkunlink+0x84>
      link("cat", "x");
    193a:	85da                	mv	a1,s6
    193c:	8562                	mv	a0,s8
    193e:	3df030ef          	jal	551c <link>
    1942:	bfd1                	j	1916 <linkunlink+0x84>
  if (pid)
    1944:	020c8263          	beqz	s9,1968 <linkunlink+0xd6>
    wait(0);
    1948:	4501                	li	a0,0
    194a:	37b030ef          	jal	54c4 <wait>
}
    194e:	60e6                	ld	ra,88(sp)
    1950:	6446                	ld	s0,80(sp)
    1952:	64a6                	ld	s1,72(sp)
    1954:	6906                	ld	s2,64(sp)
    1956:	79e2                	ld	s3,56(sp)
    1958:	7a42                	ld	s4,48(sp)
    195a:	7aa2                	ld	s5,40(sp)
    195c:	7b02                	ld	s6,32(sp)
    195e:	6be2                	ld	s7,24(sp)
    1960:	6c42                	ld	s8,16(sp)
    1962:	6ca2                	ld	s9,8(sp)
    1964:	6125                	addi	sp,sp,96
    1966:	8082                	ret
    exit(0);
    1968:	4501                	li	a0,0
    196a:	353030ef          	jal	54bc <exit>

000000000000196e <forktest>:
{
    196e:	7179                	addi	sp,sp,-48
    1970:	f406                	sd	ra,40(sp)
    1972:	f022                	sd	s0,32(sp)
    1974:	ec26                	sd	s1,24(sp)
    1976:	e84a                	sd	s2,16(sp)
    1978:	e44e                	sd	s3,8(sp)
    197a:	1800                	addi	s0,sp,48
    197c:	89aa                	mv	s3,a0
  for (n = 0; n < N; n++) {
    197e:	4481                	li	s1,0
    1980:	3e800913          	li	s2,1000
    pid = fork();
    1984:	331030ef          	jal	54b4 <fork>
    if (pid < 0)
    1988:	06054063          	bltz	a0,19e8 <forktest+0x7a>
    if (pid == 0)
    198c:	cd11                	beqz	a0,19a8 <forktest+0x3a>
  for (n = 0; n < N; n++) {
    198e:	2485                	addiw	s1,s1,1
    1990:	ff249ae3          	bne	s1,s2,1984 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1994:	85ce                	mv	a1,s3
    1996:	00005517          	auipc	a0,0x5
    199a:	c1250513          	addi	a0,a0,-1006 # 65a8 <malloc+0xc08>
    199e:	74f030ef          	jal	58ec <printf>
    exit(1);
    19a2:	4505                	li	a0,1
    19a4:	319030ef          	jal	54bc <exit>
      exit(0);
    19a8:	315030ef          	jal	54bc <exit>
    printf("%s: no fork at all!\n", s);
    19ac:	85ce                	mv	a1,s3
    19ae:	00005517          	auipc	a0,0x5
    19b2:	bb250513          	addi	a0,a0,-1102 # 6560 <malloc+0xbc0>
    19b6:	737030ef          	jal	58ec <printf>
    exit(1);
    19ba:	4505                	li	a0,1
    19bc:	301030ef          	jal	54bc <exit>
      printf("%s: wait stopped early\n", s);
    19c0:	85ce                	mv	a1,s3
    19c2:	00005517          	auipc	a0,0x5
    19c6:	bb650513          	addi	a0,a0,-1098 # 6578 <malloc+0xbd8>
    19ca:	723030ef          	jal	58ec <printf>
      exit(1);
    19ce:	4505                	li	a0,1
    19d0:	2ed030ef          	jal	54bc <exit>
    printf("%s: wait got too many\n", s);
    19d4:	85ce                	mv	a1,s3
    19d6:	00005517          	auipc	a0,0x5
    19da:	bba50513          	addi	a0,a0,-1094 # 6590 <malloc+0xbf0>
    19de:	70f030ef          	jal	58ec <printf>
    exit(1);
    19e2:	4505                	li	a0,1
    19e4:	2d9030ef          	jal	54bc <exit>
  if (n == 0) {
    19e8:	d0f1                	beqz	s1,19ac <forktest+0x3e>
  for (; n > 0; n--) {
    19ea:	00905963          	blez	s1,19fc <forktest+0x8e>
    if (wait(0) < 0) {
    19ee:	4501                	li	a0,0
    19f0:	2d5030ef          	jal	54c4 <wait>
    19f4:	fc0546e3          	bltz	a0,19c0 <forktest+0x52>
  for (; n > 0; n--) {
    19f8:	34fd                	addiw	s1,s1,-1
    19fa:	f8f5                	bnez	s1,19ee <forktest+0x80>
  if (wait(0) != -1) {
    19fc:	4501                	li	a0,0
    19fe:	2c7030ef          	jal	54c4 <wait>
    1a02:	57fd                	li	a5,-1
    1a04:	fcf518e3          	bne	a0,a5,19d4 <forktest+0x66>
}
    1a08:	70a2                	ld	ra,40(sp)
    1a0a:	7402                	ld	s0,32(sp)
    1a0c:	64e2                	ld	s1,24(sp)
    1a0e:	6942                	ld	s2,16(sp)
    1a10:	69a2                	ld	s3,8(sp)
    1a12:	6145                	addi	sp,sp,48
    1a14:	8082                	ret

0000000000001a16 <kernmem>:
{
    1a16:	715d                	addi	sp,sp,-80
    1a18:	e486                	sd	ra,72(sp)
    1a1a:	e0a2                	sd	s0,64(sp)
    1a1c:	fc26                	sd	s1,56(sp)
    1a1e:	f84a                	sd	s2,48(sp)
    1a20:	f44e                	sd	s3,40(sp)
    1a22:	f052                	sd	s4,32(sp)
    1a24:	ec56                	sd	s5,24(sp)
    1a26:	0880                	addi	s0,sp,80
    1a28:	8aaa                	mv	s5,a0
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000) {
    1a2a:	4485                	li	s1,1
    1a2c:	04fe                	slli	s1,s1,0x1f
    if (xstatus != -1) // did kernel kill child?
    1a2e:	5a7d                	li	s4,-1
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000) {
    1a30:	69b1                	lui	s3,0xc
    1a32:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1d68>
    1a36:	1003d937          	lui	s2,0x1003d
    1a3a:	090e                	slli	s2,s2,0x3
    1a3c:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d788>
    pid = fork();
    1a40:	275030ef          	jal	54b4 <fork>
    if (pid < 0) {
    1a44:	02054763          	bltz	a0,1a72 <kernmem+0x5c>
    if (pid == 0) {
    1a48:	cd1d                	beqz	a0,1a86 <kernmem+0x70>
    wait(&xstatus);
    1a4a:	fbc40513          	addi	a0,s0,-68
    1a4e:	277030ef          	jal	54c4 <wait>
    if (xstatus != -1) // did kernel kill child?
    1a52:	fbc42783          	lw	a5,-68(s0)
    1a56:	05479563          	bne	a5,s4,1aa0 <kernmem+0x8a>
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000) {
    1a5a:	94ce                	add	s1,s1,s3
    1a5c:	ff2492e3          	bne	s1,s2,1a40 <kernmem+0x2a>
}
    1a60:	60a6                	ld	ra,72(sp)
    1a62:	6406                	ld	s0,64(sp)
    1a64:	74e2                	ld	s1,56(sp)
    1a66:	7942                	ld	s2,48(sp)
    1a68:	79a2                	ld	s3,40(sp)
    1a6a:	7a02                	ld	s4,32(sp)
    1a6c:	6ae2                	ld	s5,24(sp)
    1a6e:	6161                	addi	sp,sp,80
    1a70:	8082                	ret
      printf("%s: fork failed\n", s);
    1a72:	85d6                	mv	a1,s5
    1a74:	00005517          	auipc	a0,0x5
    1a78:	8f450513          	addi	a0,a0,-1804 # 6368 <malloc+0x9c8>
    1a7c:	671030ef          	jal	58ec <printf>
      exit(1);
    1a80:	4505                	li	a0,1
    1a82:	23b030ef          	jal	54bc <exit>
      printf("%s: oops could read %p = %x\n", s, a, *a);
    1a86:	0004c683          	lbu	a3,0(s1)
    1a8a:	8626                	mv	a2,s1
    1a8c:	85d6                	mv	a1,s5
    1a8e:	00005517          	auipc	a0,0x5
    1a92:	b4250513          	addi	a0,a0,-1214 # 65d0 <malloc+0xc30>
    1a96:	657030ef          	jal	58ec <printf>
      exit(1);
    1a9a:	4505                	li	a0,1
    1a9c:	221030ef          	jal	54bc <exit>
      exit(1);
    1aa0:	4505                	li	a0,1
    1aa2:	21b030ef          	jal	54bc <exit>

0000000000001aa6 <MAXVAplus>:
{
    1aa6:	7179                	addi	sp,sp,-48
    1aa8:	f406                	sd	ra,40(sp)
    1aaa:	f022                	sd	s0,32(sp)
    1aac:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    1aae:	4785                	li	a5,1
    1ab0:	179a                	slli	a5,a5,0x26
    1ab2:	fcf43c23          	sd	a5,-40(s0)
  for (; a != 0; a <<= 1) {
    1ab6:	fd843783          	ld	a5,-40(s0)
    1aba:	cf85                	beqz	a5,1af2 <MAXVAplus+0x4c>
    1abc:	ec26                	sd	s1,24(sp)
    1abe:	e84a                	sd	s2,16(sp)
    1ac0:	892a                	mv	s2,a0
    if (xstatus != -1) // did kernel kill child?
    1ac2:	54fd                	li	s1,-1
    pid = fork();
    1ac4:	1f1030ef          	jal	54b4 <fork>
    if (pid < 0) {
    1ac8:	02054963          	bltz	a0,1afa <MAXVAplus+0x54>
    if (pid == 0) {
    1acc:	c129                	beqz	a0,1b0e <MAXVAplus+0x68>
    wait(&xstatus);
    1ace:	fd440513          	addi	a0,s0,-44
    1ad2:	1f3030ef          	jal	54c4 <wait>
    if (xstatus != -1) // did kernel kill child?
    1ad6:	fd442783          	lw	a5,-44(s0)
    1ada:	04979c63          	bne	a5,s1,1b32 <MAXVAplus+0x8c>
  for (; a != 0; a <<= 1) {
    1ade:	fd843783          	ld	a5,-40(s0)
    1ae2:	0786                	slli	a5,a5,0x1
    1ae4:	fcf43c23          	sd	a5,-40(s0)
    1ae8:	fd843783          	ld	a5,-40(s0)
    1aec:	ffe1                	bnez	a5,1ac4 <MAXVAplus+0x1e>
    1aee:	64e2                	ld	s1,24(sp)
    1af0:	6942                	ld	s2,16(sp)
}
    1af2:	70a2                	ld	ra,40(sp)
    1af4:	7402                	ld	s0,32(sp)
    1af6:	6145                	addi	sp,sp,48
    1af8:	8082                	ret
      printf("%s: fork failed\n", s);
    1afa:	85ca                	mv	a1,s2
    1afc:	00005517          	auipc	a0,0x5
    1b00:	86c50513          	addi	a0,a0,-1940 # 6368 <malloc+0x9c8>
    1b04:	5e9030ef          	jal	58ec <printf>
      exit(1);
    1b08:	4505                	li	a0,1
    1b0a:	1b3030ef          	jal	54bc <exit>
      *(char *)a = 99;
    1b0e:	fd843783          	ld	a5,-40(s0)
    1b12:	06300713          	li	a4,99
    1b16:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %p\n", s, (void *)a);
    1b1a:	fd843603          	ld	a2,-40(s0)
    1b1e:	85ca                	mv	a1,s2
    1b20:	00005517          	auipc	a0,0x5
    1b24:	ad050513          	addi	a0,a0,-1328 # 65f0 <malloc+0xc50>
    1b28:	5c5030ef          	jal	58ec <printf>
      exit(1);
    1b2c:	4505                	li	a0,1
    1b2e:	18f030ef          	jal	54bc <exit>
      exit(1);
    1b32:	4505                	li	a0,1
    1b34:	189030ef          	jal	54bc <exit>

0000000000001b38 <stacktest>:
{
    1b38:	7179                	addi	sp,sp,-48
    1b3a:	f406                	sd	ra,40(sp)
    1b3c:	f022                	sd	s0,32(sp)
    1b3e:	ec26                	sd	s1,24(sp)
    1b40:	1800                	addi	s0,sp,48
    1b42:	84aa                	mv	s1,a0
  pid = fork();
    1b44:	171030ef          	jal	54b4 <fork>
  if (pid == 0) {
    1b48:	cd11                	beqz	a0,1b64 <stacktest+0x2c>
  } else if (pid < 0) {
    1b4a:	02054c63          	bltz	a0,1b82 <stacktest+0x4a>
  wait(&xstatus);
    1b4e:	fdc40513          	addi	a0,s0,-36
    1b52:	173030ef          	jal	54c4 <wait>
  if (xstatus == -1) // kernel killed child?
    1b56:	fdc42503          	lw	a0,-36(s0)
    1b5a:	57fd                	li	a5,-1
    1b5c:	02f50d63          	beq	a0,a5,1b96 <stacktest+0x5e>
    exit(xstatus);
    1b60:	15d030ef          	jal	54bc <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r"(x));
    1b64:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %d\n", s, *sp);
    1b66:	77fd                	lui	a5,0xfffff
    1b68:	97ba                	add	a5,a5,a4
    1b6a:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef308>
    1b6e:	85a6                	mv	a1,s1
    1b70:	00005517          	auipc	a0,0x5
    1b74:	a9850513          	addi	a0,a0,-1384 # 6608 <malloc+0xc68>
    1b78:	575030ef          	jal	58ec <printf>
    exit(1);
    1b7c:	4505                	li	a0,1
    1b7e:	13f030ef          	jal	54bc <exit>
    printf("%s: fork failed\n", s);
    1b82:	85a6                	mv	a1,s1
    1b84:	00004517          	auipc	a0,0x4
    1b88:	7e450513          	addi	a0,a0,2020 # 6368 <malloc+0x9c8>
    1b8c:	561030ef          	jal	58ec <printf>
    exit(1);
    1b90:	4505                	li	a0,1
    1b92:	12b030ef          	jal	54bc <exit>
    exit(0);
    1b96:	4501                	li	a0,0
    1b98:	125030ef          	jal	54bc <exit>

0000000000001b9c <nowrite>:
{
    1b9c:	7159                	addi	sp,sp,-112
    1b9e:	f486                	sd	ra,104(sp)
    1ba0:	f0a2                	sd	s0,96(sp)
    1ba2:	eca6                	sd	s1,88(sp)
    1ba4:	e8ca                	sd	s2,80(sp)
    1ba6:	e4ce                	sd	s3,72(sp)
    1ba8:	1880                	addi	s0,sp,112
    1baa:	89aa                	mv	s3,a0
  uint64 addrs[] = {0,
    1bac:	00007797          	auipc	a5,0x7
    1bb0:	82478793          	addi	a5,a5,-2012 # 83d0 <malloc+0x2a30>
    1bb4:	7788                	ld	a0,40(a5)
    1bb6:	7b8c                	ld	a1,48(a5)
    1bb8:	7f90                	ld	a2,56(a5)
    1bba:	63b4                	ld	a3,64(a5)
    1bbc:	67b8                	ld	a4,72(a5)
    1bbe:	6bbc                	ld	a5,80(a5)
    1bc0:	f8a43c23          	sd	a0,-104(s0)
    1bc4:	fab43023          	sd	a1,-96(s0)
    1bc8:	fac43423          	sd	a2,-88(s0)
    1bcc:	fad43823          	sd	a3,-80(s0)
    1bd0:	fae43c23          	sd	a4,-72(s0)
    1bd4:	fcf43023          	sd	a5,-64(s0)
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
    1bd8:	4481                	li	s1,0
    1bda:	4919                	li	s2,6
    pid = fork();
    1bdc:	0d9030ef          	jal	54b4 <fork>
    if (pid == 0) {
    1be0:	c105                	beqz	a0,1c00 <nowrite+0x64>
    } else if (pid < 0) {
    1be2:	04054263          	bltz	a0,1c26 <nowrite+0x8a>
    wait(&xstatus);
    1be6:	fcc40513          	addi	a0,s0,-52
    1bea:	0db030ef          	jal	54c4 <wait>
    if (xstatus == 0) {
    1bee:	fcc42783          	lw	a5,-52(s0)
    1bf2:	c7a1                	beqz	a5,1c3a <nowrite+0x9e>
  for (int ai = 0; ai < sizeof(addrs) / sizeof(addrs[0]); ai++) {
    1bf4:	2485                	addiw	s1,s1,1
    1bf6:	ff2493e3          	bne	s1,s2,1bdc <nowrite+0x40>
  exit(0);
    1bfa:	4501                	li	a0,0
    1bfc:	0c1030ef          	jal	54bc <exit>
      volatile int *addr = (int *)addrs[ai];
    1c00:	048e                	slli	s1,s1,0x3
    1c02:	fd048793          	addi	a5,s1,-48
    1c06:	008784b3          	add	s1,a5,s0
    1c0a:	fc84b603          	ld	a2,-56(s1)
      *addr = 10;
    1c0e:	47a9                	li	a5,10
    1c10:	c21c                	sw	a5,0(a2)
      printf("%s: write to %p did not fail!\n", s, addr);
    1c12:	85ce                	mv	a1,s3
    1c14:	00005517          	auipc	a0,0x5
    1c18:	a1c50513          	addi	a0,a0,-1508 # 6630 <malloc+0xc90>
    1c1c:	4d1030ef          	jal	58ec <printf>
      exit(0);
    1c20:	4501                	li	a0,0
    1c22:	09b030ef          	jal	54bc <exit>
      printf("%s: fork failed\n", s);
    1c26:	85ce                	mv	a1,s3
    1c28:	00004517          	auipc	a0,0x4
    1c2c:	74050513          	addi	a0,a0,1856 # 6368 <malloc+0x9c8>
    1c30:	4bd030ef          	jal	58ec <printf>
      exit(1);
    1c34:	4505                	li	a0,1
    1c36:	087030ef          	jal	54bc <exit>
      exit(1);
    1c3a:	4505                	li	a0,1
    1c3c:	081030ef          	jal	54bc <exit>

0000000000001c40 <manywrites>:
{
    1c40:	711d                	addi	sp,sp,-96
    1c42:	ec86                	sd	ra,88(sp)
    1c44:	e8a2                	sd	s0,80(sp)
    1c46:	e4a6                	sd	s1,72(sp)
    1c48:	e0ca                	sd	s2,64(sp)
    1c4a:	fc4e                	sd	s3,56(sp)
    1c4c:	f456                	sd	s5,40(sp)
    1c4e:	1080                	addi	s0,sp,96
    1c50:	8aaa                	mv	s5,a0
  for (int ci = 0; ci < nchildren; ci++) {
    1c52:	4981                	li	s3,0
    1c54:	4911                	li	s2,4
    int pid = fork();
    1c56:	05f030ef          	jal	54b4 <fork>
    1c5a:	84aa                	mv	s1,a0
    if (pid < 0) {
    1c5c:	02054963          	bltz	a0,1c8e <manywrites+0x4e>
    if (pid == 0) {
    1c60:	c139                	beqz	a0,1ca6 <manywrites+0x66>
  for (int ci = 0; ci < nchildren; ci++) {
    1c62:	2985                	addiw	s3,s3,1
    1c64:	ff2999e3          	bne	s3,s2,1c56 <manywrites+0x16>
    1c68:	f852                	sd	s4,48(sp)
    1c6a:	f05a                	sd	s6,32(sp)
    1c6c:	ec5e                	sd	s7,24(sp)
    1c6e:	4491                	li	s1,4
    int st = 0;
    1c70:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1c74:	fa840513          	addi	a0,s0,-88
    1c78:	04d030ef          	jal	54c4 <wait>
    if (st != 0)
    1c7c:	fa842503          	lw	a0,-88(s0)
    1c80:	0c051863          	bnez	a0,1d50 <manywrites+0x110>
  for (int ci = 0; ci < nchildren; ci++) {
    1c84:	34fd                	addiw	s1,s1,-1
    1c86:	f4ed                	bnez	s1,1c70 <manywrites+0x30>
  exit(0);
    1c88:	4501                	li	a0,0
    1c8a:	033030ef          	jal	54bc <exit>
    1c8e:	f852                	sd	s4,48(sp)
    1c90:	f05a                	sd	s6,32(sp)
    1c92:	ec5e                	sd	s7,24(sp)
      printf("fork failed\n");
    1c94:	00006517          	auipc	a0,0x6
    1c98:	dc450513          	addi	a0,a0,-572 # 7a58 <malloc+0x20b8>
    1c9c:	451030ef          	jal	58ec <printf>
      exit(1);
    1ca0:	4505                	li	a0,1
    1ca2:	01b030ef          	jal	54bc <exit>
    1ca6:	f852                	sd	s4,48(sp)
    1ca8:	f05a                	sd	s6,32(sp)
    1caa:	ec5e                	sd	s7,24(sp)
      name[0] = 'b';
    1cac:	06200793          	li	a5,98
    1cb0:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1cb4:	0619879b          	addiw	a5,s3,97
    1cb8:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1cbc:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1cc0:	fa840513          	addi	a0,s0,-88
    1cc4:	049030ef          	jal	550c <unlink>
    1cc8:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1cca:	0000bb17          	auipc	s6,0xb
    1cce:	02eb0b13          	addi	s6,s6,46 # ccf8 <buf>
        for (int i = 0; i < ci + 1; i++) {
    1cd2:	8a26                	mv	s4,s1
    1cd4:	0209c863          	bltz	s3,1d04 <manywrites+0xc4>
          int fd = open(name, O_CREATE | O_RDWR);
    1cd8:	20200593          	li	a1,514
    1cdc:	fa840513          	addi	a0,s0,-88
    1ce0:	01d030ef          	jal	54fc <open>
    1ce4:	892a                	mv	s2,a0
          if (fd < 0) {
    1ce6:	02054d63          	bltz	a0,1d20 <manywrites+0xe0>
          int cc = write(fd, buf, sz);
    1cea:	660d                	lui	a2,0x3
    1cec:	85da                	mv	a1,s6
    1cee:	7ee030ef          	jal	54dc <write>
          if (cc != sz) {
    1cf2:	678d                	lui	a5,0x3
    1cf4:	04f51263          	bne	a0,a5,1d38 <manywrites+0xf8>
          close(fd);
    1cf8:	854a                	mv	a0,s2
    1cfa:	7ea030ef          	jal	54e4 <close>
        for (int i = 0; i < ci + 1; i++) {
    1cfe:	2a05                	addiw	s4,s4,1
    1d00:	fd49dce3          	bge	s3,s4,1cd8 <manywrites+0x98>
        unlink(name);
    1d04:	fa840513          	addi	a0,s0,-88
    1d08:	005030ef          	jal	550c <unlink>
      for (int iters = 0; iters < howmany; iters++) {
    1d0c:	3bfd                	addiw	s7,s7,-1
    1d0e:	fc0b92e3          	bnez	s7,1cd2 <manywrites+0x92>
      unlink(name);
    1d12:	fa840513          	addi	a0,s0,-88
    1d16:	7f6030ef          	jal	550c <unlink>
      exit(0);
    1d1a:	4501                	li	a0,0
    1d1c:	7a0030ef          	jal	54bc <exit>
            printf("%s: cannot create %s\n", s, name);
    1d20:	fa840613          	addi	a2,s0,-88
    1d24:	85d6                	mv	a1,s5
    1d26:	00005517          	auipc	a0,0x5
    1d2a:	92a50513          	addi	a0,a0,-1750 # 6650 <malloc+0xcb0>
    1d2e:	3bf030ef          	jal	58ec <printf>
            exit(1);
    1d32:	4505                	li	a0,1
    1d34:	788030ef          	jal	54bc <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1d38:	86aa                	mv	a3,a0
    1d3a:	660d                	lui	a2,0x3
    1d3c:	85d6                	mv	a1,s5
    1d3e:	00004517          	auipc	a0,0x4
    1d42:	e6a50513          	addi	a0,a0,-406 # 5ba8 <malloc+0x208>
    1d46:	3a7030ef          	jal	58ec <printf>
            exit(1);
    1d4a:	4505                	li	a0,1
    1d4c:	770030ef          	jal	54bc <exit>
      exit(st);
    1d50:	76c030ef          	jal	54bc <exit>

0000000000001d54 <copyinstr3>:
{
    1d54:	7179                	addi	sp,sp,-48
    1d56:	f406                	sd	ra,40(sp)
    1d58:	f022                	sd	s0,32(sp)
    1d5a:	ec26                	sd	s1,24(sp)
    1d5c:	1800                	addi	s0,sp,48
  sbrk(8192);
    1d5e:	6509                	lui	a0,0x2
    1d60:	728030ef          	jal	5488 <sbrk>
  uint64 top = (uint64)sbrk(0);
    1d64:	4501                	li	a0,0
    1d66:	722030ef          	jal	5488 <sbrk>
  if ((top % PGSIZE) != 0) {
    1d6a:	03451793          	slli	a5,a0,0x34
    1d6e:	e7bd                	bnez	a5,1ddc <copyinstr3+0x88>
  top = (uint64)sbrk(0);
    1d70:	4501                	li	a0,0
    1d72:	716030ef          	jal	5488 <sbrk>
  if (top % PGSIZE) {
    1d76:	03451793          	slli	a5,a0,0x34
    1d7a:	ebad                	bnez	a5,1dec <copyinstr3+0x98>
  char *b = (char *)(top - 1);
    1d7c:	fff50493          	addi	s1,a0,-1 # 1fff <sbrkbasic+0xa1>
  *b = 'x';
    1d80:	07800793          	li	a5,120
    1d84:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1d88:	8526                	mv	a0,s1
    1d8a:	782030ef          	jal	550c <unlink>
  if (ret != -1) {
    1d8e:	57fd                	li	a5,-1
    1d90:	06f51763          	bne	a0,a5,1dfe <copyinstr3+0xaa>
  int fd = open(b, O_CREATE | O_WRONLY);
    1d94:	20100593          	li	a1,513
    1d98:	8526                	mv	a0,s1
    1d9a:	762030ef          	jal	54fc <open>
  if (fd != -1) {
    1d9e:	57fd                	li	a5,-1
    1da0:	06f51a63          	bne	a0,a5,1e14 <copyinstr3+0xc0>
  ret = link(b, b);
    1da4:	85a6                	mv	a1,s1
    1da6:	8526                	mv	a0,s1
    1da8:	774030ef          	jal	551c <link>
  if (ret != -1) {
    1dac:	57fd                	li	a5,-1
    1dae:	06f51e63          	bne	a0,a5,1e2a <copyinstr3+0xd6>
  char *args[] = {"xx", 0};
    1db2:	00005797          	auipc	a5,0x5
    1db6:	59e78793          	addi	a5,a5,1438 # 7350 <malloc+0x19b0>
    1dba:	fcf43823          	sd	a5,-48(s0)
    1dbe:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1dc2:	fd040593          	addi	a1,s0,-48
    1dc6:	8526                	mv	a0,s1
    1dc8:	72c030ef          	jal	54f4 <exec>
  if (ret != -1) {
    1dcc:	57fd                	li	a5,-1
    1dce:	06f51a63          	bne	a0,a5,1e42 <copyinstr3+0xee>
}
    1dd2:	70a2                	ld	ra,40(sp)
    1dd4:	7402                	ld	s0,32(sp)
    1dd6:	64e2                	ld	s1,24(sp)
    1dd8:	6145                	addi	sp,sp,48
    1dda:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1ddc:	0347d513          	srli	a0,a5,0x34
    1de0:	6785                	lui	a5,0x1
    1de2:	40a7853b          	subw	a0,a5,a0
    1de6:	6a2030ef          	jal	5488 <sbrk>
    1dea:	b759                	j	1d70 <copyinstr3+0x1c>
    printf("oops\n");
    1dec:	00005517          	auipc	a0,0x5
    1df0:	87c50513          	addi	a0,a0,-1924 # 6668 <malloc+0xcc8>
    1df4:	2f9030ef          	jal	58ec <printf>
    exit(1);
    1df8:	4505                	li	a0,1
    1dfa:	6c2030ef          	jal	54bc <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1dfe:	862a                	mv	a2,a0
    1e00:	85a6                	mv	a1,s1
    1e02:	00004517          	auipc	a0,0x4
    1e06:	48650513          	addi	a0,a0,1158 # 6288 <malloc+0x8e8>
    1e0a:	2e3030ef          	jal	58ec <printf>
    exit(1);
    1e0e:	4505                	li	a0,1
    1e10:	6ac030ef          	jal	54bc <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1e14:	862a                	mv	a2,a0
    1e16:	85a6                	mv	a1,s1
    1e18:	00004517          	auipc	a0,0x4
    1e1c:	49050513          	addi	a0,a0,1168 # 62a8 <malloc+0x908>
    1e20:	2cd030ef          	jal	58ec <printf>
    exit(1);
    1e24:	4505                	li	a0,1
    1e26:	696030ef          	jal	54bc <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1e2a:	86aa                	mv	a3,a0
    1e2c:	8626                	mv	a2,s1
    1e2e:	85a6                	mv	a1,s1
    1e30:	00004517          	auipc	a0,0x4
    1e34:	49850513          	addi	a0,a0,1176 # 62c8 <malloc+0x928>
    1e38:	2b5030ef          	jal	58ec <printf>
    exit(1);
    1e3c:	4505                	li	a0,1
    1e3e:	67e030ef          	jal	54bc <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1e42:	567d                	li	a2,-1
    1e44:	85a6                	mv	a1,s1
    1e46:	00004517          	auipc	a0,0x4
    1e4a:	4aa50513          	addi	a0,a0,1194 # 62f0 <malloc+0x950>
    1e4e:	29f030ef          	jal	58ec <printf>
    exit(1);
    1e52:	4505                	li	a0,1
    1e54:	668030ef          	jal	54bc <exit>

0000000000001e58 <rwsbrk>:
{
    1e58:	1101                	addi	sp,sp,-32
    1e5a:	ec06                	sd	ra,24(sp)
    1e5c:	e822                	sd	s0,16(sp)
    1e5e:	1000                	addi	s0,sp,32
  uint64 a = (uint64)sbrk(8192);
    1e60:	6509                	lui	a0,0x2
    1e62:	626030ef          	jal	5488 <sbrk>
  if (a == (uint64)SBRK_ERROR) {
    1e66:	57fd                	li	a5,-1
    1e68:	04f50a63          	beq	a0,a5,1ebc <rwsbrk+0x64>
    1e6c:	e426                	sd	s1,8(sp)
    1e6e:	84aa                	mv	s1,a0
  if (sbrk(-8192) == SBRK_ERROR) {
    1e70:	7579                	lui	a0,0xffffe
    1e72:	616030ef          	jal	5488 <sbrk>
    1e76:	57fd                	li	a5,-1
    1e78:	04f50d63          	beq	a0,a5,1ed2 <rwsbrk+0x7a>
    1e7c:	e04a                	sd	s2,0(sp)
  fd = open("rwsbrk", O_CREATE | O_WRONLY);
    1e7e:	20100593          	li	a1,513
    1e82:	00005517          	auipc	a0,0x5
    1e86:	82650513          	addi	a0,a0,-2010 # 66a8 <malloc+0xd08>
    1e8a:	672030ef          	jal	54fc <open>
    1e8e:	892a                	mv	s2,a0
  if (fd < 0) {
    1e90:	04054b63          	bltz	a0,1ee6 <rwsbrk+0x8e>
  n = write(fd, (void *)(a + PGSIZE), 1024);
    1e94:	6785                	lui	a5,0x1
    1e96:	94be                	add	s1,s1,a5
    1e98:	40000613          	li	a2,1024
    1e9c:	85a6                	mv	a1,s1
    1e9e:	63e030ef          	jal	54dc <write>
    1ea2:	862a                	mv	a2,a0
  if (n >= 0) {
    1ea4:	04054a63          	bltz	a0,1ef8 <rwsbrk+0xa0>
    printf("write(fd, %p, 1024) returned %d, not -1\n", (void *)a + PGSIZE, n);
    1ea8:	85a6                	mv	a1,s1
    1eaa:	00005517          	auipc	a0,0x5
    1eae:	81e50513          	addi	a0,a0,-2018 # 66c8 <malloc+0xd28>
    1eb2:	23b030ef          	jal	58ec <printf>
    exit(1);
    1eb6:	4505                	li	a0,1
    1eb8:	604030ef          	jal	54bc <exit>
    1ebc:	e426                	sd	s1,8(sp)
    1ebe:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) failed\n");
    1ec0:	00004517          	auipc	a0,0x4
    1ec4:	7b050513          	addi	a0,a0,1968 # 6670 <malloc+0xcd0>
    1ec8:	225030ef          	jal	58ec <printf>
    exit(1);
    1ecc:	4505                	li	a0,1
    1ece:	5ee030ef          	jal	54bc <exit>
    1ed2:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) shrink failed\n");
    1ed4:	00004517          	auipc	a0,0x4
    1ed8:	7b450513          	addi	a0,a0,1972 # 6688 <malloc+0xce8>
    1edc:	211030ef          	jal	58ec <printf>
    exit(1);
    1ee0:	4505                	li	a0,1
    1ee2:	5da030ef          	jal	54bc <exit>
    printf("open(rwsbrk) failed\n");
    1ee6:	00004517          	auipc	a0,0x4
    1eea:	7ca50513          	addi	a0,a0,1994 # 66b0 <malloc+0xd10>
    1eee:	1ff030ef          	jal	58ec <printf>
    exit(1);
    1ef2:	4505                	li	a0,1
    1ef4:	5c8030ef          	jal	54bc <exit>
  close(fd);
    1ef8:	854a                	mv	a0,s2
    1efa:	5ea030ef          	jal	54e4 <close>
  unlink("rwsbrk");
    1efe:	00004517          	auipc	a0,0x4
    1f02:	7aa50513          	addi	a0,a0,1962 # 66a8 <malloc+0xd08>
    1f06:	606030ef          	jal	550c <unlink>
  fd = open("README", O_RDONLY);
    1f0a:	4581                	li	a1,0
    1f0c:	00004517          	auipc	a0,0x4
    1f10:	da450513          	addi	a0,a0,-604 # 5cb0 <malloc+0x310>
    1f14:	5e8030ef          	jal	54fc <open>
    1f18:	892a                	mv	s2,a0
  if (fd < 0) {
    1f1a:	02054363          	bltz	a0,1f40 <rwsbrk+0xe8>
  n = read(fd, (void *)(a + PGSIZE), 10);
    1f1e:	4629                	li	a2,10
    1f20:	85a6                	mv	a1,s1
    1f22:	5b2030ef          	jal	54d4 <read>
    1f26:	862a                	mv	a2,a0
  if (n >= 0) {
    1f28:	02054563          	bltz	a0,1f52 <rwsbrk+0xfa>
    printf("read(fd, %p, 10) returned %d, not -1\n", (void *)a + PGSIZE, n);
    1f2c:	85a6                	mv	a1,s1
    1f2e:	00004517          	auipc	a0,0x4
    1f32:	7ca50513          	addi	a0,a0,1994 # 66f8 <malloc+0xd58>
    1f36:	1b7030ef          	jal	58ec <printf>
    exit(1);
    1f3a:	4505                	li	a0,1
    1f3c:	580030ef          	jal	54bc <exit>
    printf("open(README) failed\n");
    1f40:	00004517          	auipc	a0,0x4
    1f44:	d7850513          	addi	a0,a0,-648 # 5cb8 <malloc+0x318>
    1f48:	1a5030ef          	jal	58ec <printf>
    exit(1);
    1f4c:	4505                	li	a0,1
    1f4e:	56e030ef          	jal	54bc <exit>
  close(fd);
    1f52:	854a                	mv	a0,s2
    1f54:	590030ef          	jal	54e4 <close>
  exit(0);
    1f58:	4501                	li	a0,0
    1f5a:	562030ef          	jal	54bc <exit>

0000000000001f5e <sbrkbasic>:
{
    1f5e:	7139                	addi	sp,sp,-64
    1f60:	fc06                	sd	ra,56(sp)
    1f62:	f822                	sd	s0,48(sp)
    1f64:	ec4e                	sd	s3,24(sp)
    1f66:	0080                	addi	s0,sp,64
    1f68:	89aa                	mv	s3,a0
  pid = fork();
    1f6a:	54a030ef          	jal	54b4 <fork>
  if (pid < 0) {
    1f6e:	02054b63          	bltz	a0,1fa4 <sbrkbasic+0x46>
  if (pid == 0) {
    1f72:	e939                	bnez	a0,1fc8 <sbrkbasic+0x6a>
    a = sbrk(TOOMUCH);
    1f74:	40000537          	lui	a0,0x40000
    1f78:	510030ef          	jal	5488 <sbrk>
    if (a == (char *)SBRK_ERROR) {
    1f7c:	57fd                	li	a5,-1
    1f7e:	02f50f63          	beq	a0,a5,1fbc <sbrkbasic+0x5e>
    1f82:	f426                	sd	s1,40(sp)
    1f84:	f04a                	sd	s2,32(sp)
    1f86:	e852                	sd	s4,16(sp)
    for (b = a; b < a + TOOMUCH; b += PGSIZE) {
    1f88:	400007b7          	lui	a5,0x40000
    1f8c:	97aa                	add	a5,a5,a0
      *b = 99;
    1f8e:	06300693          	li	a3,99
    for (b = a; b < a + TOOMUCH; b += PGSIZE) {
    1f92:	6705                	lui	a4,0x1
      *b = 99;
    1f94:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0308>
    for (b = a; b < a + TOOMUCH; b += PGSIZE) {
    1f98:	953a                	add	a0,a0,a4
    1f9a:	fef51de3          	bne	a0,a5,1f94 <sbrkbasic+0x36>
    exit(1);
    1f9e:	4505                	li	a0,1
    1fa0:	51c030ef          	jal	54bc <exit>
    1fa4:	f426                	sd	s1,40(sp)
    1fa6:	f04a                	sd	s2,32(sp)
    1fa8:	e852                	sd	s4,16(sp)
    printf("fork failed in sbrkbasic\n");
    1faa:	00004517          	auipc	a0,0x4
    1fae:	77650513          	addi	a0,a0,1910 # 6720 <malloc+0xd80>
    1fb2:	13b030ef          	jal	58ec <printf>
    exit(1);
    1fb6:	4505                	li	a0,1
    1fb8:	504030ef          	jal	54bc <exit>
    1fbc:	f426                	sd	s1,40(sp)
    1fbe:	f04a                	sd	s2,32(sp)
    1fc0:	e852                	sd	s4,16(sp)
      exit(0);
    1fc2:	4501                	li	a0,0
    1fc4:	4f8030ef          	jal	54bc <exit>
  wait(&xstatus);
    1fc8:	fcc40513          	addi	a0,s0,-52
    1fcc:	4f8030ef          	jal	54c4 <wait>
  if (xstatus == 1) {
    1fd0:	fcc42703          	lw	a4,-52(s0)
    1fd4:	4785                	li	a5,1
    1fd6:	00f70e63          	beq	a4,a5,1ff2 <sbrkbasic+0x94>
    1fda:	f426                	sd	s1,40(sp)
    1fdc:	f04a                	sd	s2,32(sp)
    1fde:	e852                	sd	s4,16(sp)
  a = sbrk(0);
    1fe0:	4501                	li	a0,0
    1fe2:	4a6030ef          	jal	5488 <sbrk>
    1fe6:	84aa                	mv	s1,a0
  for (i = 0; i < 5000; i++) {
    1fe8:	4901                	li	s2,0
    1fea:	6a05                	lui	s4,0x1
    1fec:	388a0a13          	addi	s4,s4,904 # 1388 <pipe1+0x4a>
    1ff0:	a839                	j	200e <sbrkbasic+0xb0>
    1ff2:	f426                	sd	s1,40(sp)
    1ff4:	f04a                	sd	s2,32(sp)
    1ff6:	e852                	sd	s4,16(sp)
    printf("%s: too much memory allocated!\n", s);
    1ff8:	85ce                	mv	a1,s3
    1ffa:	00004517          	auipc	a0,0x4
    1ffe:	74650513          	addi	a0,a0,1862 # 6740 <malloc+0xda0>
    2002:	0eb030ef          	jal	58ec <printf>
    exit(1);
    2006:	4505                	li	a0,1
    2008:	4b4030ef          	jal	54bc <exit>
    200c:	84be                	mv	s1,a5
    b = sbrk(1);
    200e:	4505                	li	a0,1
    2010:	478030ef          	jal	5488 <sbrk>
    if (b != a) {
    2014:	04951263          	bne	a0,s1,2058 <sbrkbasic+0xfa>
    *b = 1;
    2018:	4785                	li	a5,1
    201a:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    201e:	00148793          	addi	a5,s1,1
  for (i = 0; i < 5000; i++) {
    2022:	2905                	addiw	s2,s2,1
    2024:	ff4914e3          	bne	s2,s4,200c <sbrkbasic+0xae>
  pid = fork();
    2028:	48c030ef          	jal	54b4 <fork>
    202c:	892a                	mv	s2,a0
  if (pid < 0) {
    202e:	04054263          	bltz	a0,2072 <sbrkbasic+0x114>
  c = sbrk(1);
    2032:	4505                	li	a0,1
    2034:	454030ef          	jal	5488 <sbrk>
  c = sbrk(1);
    2038:	4505                	li	a0,1
    203a:	44e030ef          	jal	5488 <sbrk>
  if (c != a + 1) {
    203e:	0489                	addi	s1,s1,2
    2040:	04a48363          	beq	s1,a0,2086 <sbrkbasic+0x128>
    printf("%s: sbrk test failed post-fork\n", s);
    2044:	85ce                	mv	a1,s3
    2046:	00004517          	auipc	a0,0x4
    204a:	75a50513          	addi	a0,a0,1882 # 67a0 <malloc+0xe00>
    204e:	09f030ef          	jal	58ec <printf>
    exit(1);
    2052:	4505                	li	a0,1
    2054:	468030ef          	jal	54bc <exit>
      printf("%s: sbrk test failed %d %p %p\n", s, i, a, b);
    2058:	872a                	mv	a4,a0
    205a:	86a6                	mv	a3,s1
    205c:	864a                	mv	a2,s2
    205e:	85ce                	mv	a1,s3
    2060:	00004517          	auipc	a0,0x4
    2064:	70050513          	addi	a0,a0,1792 # 6760 <malloc+0xdc0>
    2068:	085030ef          	jal	58ec <printf>
      exit(1);
    206c:	4505                	li	a0,1
    206e:	44e030ef          	jal	54bc <exit>
    printf("%s: sbrk test fork failed\n", s);
    2072:	85ce                	mv	a1,s3
    2074:	00004517          	auipc	a0,0x4
    2078:	70c50513          	addi	a0,a0,1804 # 6780 <malloc+0xde0>
    207c:	071030ef          	jal	58ec <printf>
    exit(1);
    2080:	4505                	li	a0,1
    2082:	43a030ef          	jal	54bc <exit>
  if (pid == 0)
    2086:	00091563          	bnez	s2,2090 <sbrkbasic+0x132>
    exit(0);
    208a:	4501                	li	a0,0
    208c:	430030ef          	jal	54bc <exit>
  wait(&xstatus);
    2090:	fcc40513          	addi	a0,s0,-52
    2094:	430030ef          	jal	54c4 <wait>
  exit(xstatus);
    2098:	fcc42503          	lw	a0,-52(s0)
    209c:	420030ef          	jal	54bc <exit>

00000000000020a0 <sbrkmuch>:
{
    20a0:	7179                	addi	sp,sp,-48
    20a2:	f406                	sd	ra,40(sp)
    20a4:	f022                	sd	s0,32(sp)
    20a6:	ec26                	sd	s1,24(sp)
    20a8:	e84a                	sd	s2,16(sp)
    20aa:	e44e                	sd	s3,8(sp)
    20ac:	e052                	sd	s4,0(sp)
    20ae:	1800                	addi	s0,sp,48
    20b0:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    20b2:	4501                	li	a0,0
    20b4:	3d4030ef          	jal	5488 <sbrk>
    20b8:	892a                	mv	s2,a0
  a = sbrk(0);
    20ba:	4501                	li	a0,0
    20bc:	3cc030ef          	jal	5488 <sbrk>
    20c0:	84aa                	mv	s1,a0
  p = sbrk(amt);
    20c2:	06400537          	lui	a0,0x6400
    20c6:	9d05                	subw	a0,a0,s1
    20c8:	3c0030ef          	jal	5488 <sbrk>
  if (p != a) {
    20cc:	08a49763          	bne	s1,a0,215a <sbrkmuch+0xba>
  *lastaddr = 99;
    20d0:	064007b7          	lui	a5,0x6400
    20d4:	06300713          	li	a4,99
    20d8:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0307>
  a = sbrk(0);
    20dc:	4501                	li	a0,0
    20de:	3aa030ef          	jal	5488 <sbrk>
    20e2:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    20e4:	757d                	lui	a0,0xfffff
    20e6:	3a2030ef          	jal	5488 <sbrk>
  if (c == (char *)SBRK_ERROR) {
    20ea:	57fd                	li	a5,-1
    20ec:	08f50163          	beq	a0,a5,216e <sbrkmuch+0xce>
  c = sbrk(0);
    20f0:	4501                	li	a0,0
    20f2:	396030ef          	jal	5488 <sbrk>
  if (c != a - PGSIZE) {
    20f6:	77fd                	lui	a5,0xfffff
    20f8:	97a6                	add	a5,a5,s1
    20fa:	08f51463          	bne	a0,a5,2182 <sbrkmuch+0xe2>
  a = sbrk(0);
    20fe:	4501                	li	a0,0
    2100:	388030ef          	jal	5488 <sbrk>
    2104:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2106:	6505                	lui	a0,0x1
    2108:	380030ef          	jal	5488 <sbrk>
    210c:	8a2a                	mv	s4,a0
  if (c != a || sbrk(0) != a + PGSIZE) {
    210e:	08a49663          	bne	s1,a0,219a <sbrkmuch+0xfa>
    2112:	4501                	li	a0,0
    2114:	374030ef          	jal	5488 <sbrk>
    2118:	6785                	lui	a5,0x1
    211a:	97a6                	add	a5,a5,s1
    211c:	06f51f63          	bne	a0,a5,219a <sbrkmuch+0xfa>
  if (*lastaddr == 99) {
    2120:	064007b7          	lui	a5,0x6400
    2124:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0307>
    2128:	06300793          	li	a5,99
    212c:	08f70363          	beq	a4,a5,21b2 <sbrkmuch+0x112>
  a = sbrk(0);
    2130:	4501                	li	a0,0
    2132:	356030ef          	jal	5488 <sbrk>
    2136:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2138:	4501                	li	a0,0
    213a:	34e030ef          	jal	5488 <sbrk>
    213e:	40a9053b          	subw	a0,s2,a0
    2142:	346030ef          	jal	5488 <sbrk>
  if (c != a) {
    2146:	08a49063          	bne	s1,a0,21c6 <sbrkmuch+0x126>
}
    214a:	70a2                	ld	ra,40(sp)
    214c:	7402                	ld	s0,32(sp)
    214e:	64e2                	ld	s1,24(sp)
    2150:	6942                	ld	s2,16(sp)
    2152:	69a2                	ld	s3,8(sp)
    2154:	6a02                	ld	s4,0(sp)
    2156:	6145                	addi	sp,sp,48
    2158:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n",
    215a:	85ce                	mv	a1,s3
    215c:	00004517          	auipc	a0,0x4
    2160:	66450513          	addi	a0,a0,1636 # 67c0 <malloc+0xe20>
    2164:	788030ef          	jal	58ec <printf>
    exit(1);
    2168:	4505                	li	a0,1
    216a:	352030ef          	jal	54bc <exit>
    printf("%s: sbrk could not deallocate\n", s);
    216e:	85ce                	mv	a1,s3
    2170:	00004517          	auipc	a0,0x4
    2174:	69850513          	addi	a0,a0,1688 # 6808 <malloc+0xe68>
    2178:	774030ef          	jal	58ec <printf>
    exit(1);
    217c:	4505                	li	a0,1
    217e:	33e030ef          	jal	54bc <exit>
    printf("%s: sbrk deallocation produced wrong address, a %p c %p\n", s, a,
    2182:	86aa                	mv	a3,a0
    2184:	8626                	mv	a2,s1
    2186:	85ce                	mv	a1,s3
    2188:	00004517          	auipc	a0,0x4
    218c:	6a050513          	addi	a0,a0,1696 # 6828 <malloc+0xe88>
    2190:	75c030ef          	jal	58ec <printf>
    exit(1);
    2194:	4505                	li	a0,1
    2196:	326030ef          	jal	54bc <exit>
    printf("%s: sbrk re-allocation failed, a %p c %p\n", s, a, c);
    219a:	86d2                	mv	a3,s4
    219c:	8626                	mv	a2,s1
    219e:	85ce                	mv	a1,s3
    21a0:	00004517          	auipc	a0,0x4
    21a4:	6c850513          	addi	a0,a0,1736 # 6868 <malloc+0xec8>
    21a8:	744030ef          	jal	58ec <printf>
    exit(1);
    21ac:	4505                	li	a0,1
    21ae:	30e030ef          	jal	54bc <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    21b2:	85ce                	mv	a1,s3
    21b4:	00004517          	auipc	a0,0x4
    21b8:	6e450513          	addi	a0,a0,1764 # 6898 <malloc+0xef8>
    21bc:	730030ef          	jal	58ec <printf>
    exit(1);
    21c0:	4505                	li	a0,1
    21c2:	2fa030ef          	jal	54bc <exit>
    printf("%s: sbrk downsize failed, a %p c %p\n", s, a, c);
    21c6:	86aa                	mv	a3,a0
    21c8:	8626                	mv	a2,s1
    21ca:	85ce                	mv	a1,s3
    21cc:	00004517          	auipc	a0,0x4
    21d0:	70450513          	addi	a0,a0,1796 # 68d0 <malloc+0xf30>
    21d4:	718030ef          	jal	58ec <printf>
    exit(1);
    21d8:	4505                	li	a0,1
    21da:	2e2030ef          	jal	54bc <exit>

00000000000021de <sbrkarg>:
{
    21de:	7179                	addi	sp,sp,-48
    21e0:	f406                	sd	ra,40(sp)
    21e2:	f022                	sd	s0,32(sp)
    21e4:	ec26                	sd	s1,24(sp)
    21e6:	e84a                	sd	s2,16(sp)
    21e8:	e44e                	sd	s3,8(sp)
    21ea:	1800                	addi	s0,sp,48
    21ec:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    21ee:	6505                	lui	a0,0x1
    21f0:	298030ef          	jal	5488 <sbrk>
    21f4:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE | O_WRONLY);
    21f6:	20100593          	li	a1,513
    21fa:	00004517          	auipc	a0,0x4
    21fe:	6fe50513          	addi	a0,a0,1790 # 68f8 <malloc+0xf58>
    2202:	2fa030ef          	jal	54fc <open>
    2206:	84aa                	mv	s1,a0
  unlink("sbrk");
    2208:	00004517          	auipc	a0,0x4
    220c:	6f050513          	addi	a0,a0,1776 # 68f8 <malloc+0xf58>
    2210:	2fc030ef          	jal	550c <unlink>
  if (fd < 0) {
    2214:	0204c963          	bltz	s1,2246 <sbrkarg+0x68>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2218:	6605                	lui	a2,0x1
    221a:	85ca                	mv	a1,s2
    221c:	8526                	mv	a0,s1
    221e:	2be030ef          	jal	54dc <write>
    2222:	02054c63          	bltz	a0,225a <sbrkarg+0x7c>
  close(fd);
    2226:	8526                	mv	a0,s1
    2228:	2bc030ef          	jal	54e4 <close>
  a = sbrk(PGSIZE);
    222c:	6505                	lui	a0,0x1
    222e:	25a030ef          	jal	5488 <sbrk>
  if (pipe((int *)a) != 0) {
    2232:	29a030ef          	jal	54cc <pipe>
    2236:	ed05                	bnez	a0,226e <sbrkarg+0x90>
}
    2238:	70a2                	ld	ra,40(sp)
    223a:	7402                	ld	s0,32(sp)
    223c:	64e2                	ld	s1,24(sp)
    223e:	6942                	ld	s2,16(sp)
    2240:	69a2                	ld	s3,8(sp)
    2242:	6145                	addi	sp,sp,48
    2244:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2246:	85ce                	mv	a1,s3
    2248:	00004517          	auipc	a0,0x4
    224c:	6b850513          	addi	a0,a0,1720 # 6900 <malloc+0xf60>
    2250:	69c030ef          	jal	58ec <printf>
    exit(1);
    2254:	4505                	li	a0,1
    2256:	266030ef          	jal	54bc <exit>
    printf("%s: write sbrk failed\n", s);
    225a:	85ce                	mv	a1,s3
    225c:	00004517          	auipc	a0,0x4
    2260:	6bc50513          	addi	a0,a0,1724 # 6918 <malloc+0xf78>
    2264:	688030ef          	jal	58ec <printf>
    exit(1);
    2268:	4505                	li	a0,1
    226a:	252030ef          	jal	54bc <exit>
    printf("%s: pipe() failed\n", s);
    226e:	85ce                	mv	a1,s3
    2270:	00004517          	auipc	a0,0x4
    2274:	18050513          	addi	a0,a0,384 # 63f0 <malloc+0xa50>
    2278:	674030ef          	jal	58ec <printf>
    exit(1);
    227c:	4505                	li	a0,1
    227e:	23e030ef          	jal	54bc <exit>

0000000000002282 <argptest>:
{
    2282:	1101                	addi	sp,sp,-32
    2284:	ec06                	sd	ra,24(sp)
    2286:	e822                	sd	s0,16(sp)
    2288:	e426                	sd	s1,8(sp)
    228a:	e04a                	sd	s2,0(sp)
    228c:	1000                	addi	s0,sp,32
    228e:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2290:	4581                	li	a1,0
    2292:	00004517          	auipc	a0,0x4
    2296:	69e50513          	addi	a0,a0,1694 # 6930 <malloc+0xf90>
    229a:	262030ef          	jal	54fc <open>
  if (fd < 0) {
    229e:	02054563          	bltz	a0,22c8 <argptest+0x46>
    22a2:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    22a4:	4501                	li	a0,0
    22a6:	1e2030ef          	jal	5488 <sbrk>
    22aa:	567d                	li	a2,-1
    22ac:	fff50593          	addi	a1,a0,-1
    22b0:	8526                	mv	a0,s1
    22b2:	222030ef          	jal	54d4 <read>
  close(fd);
    22b6:	8526                	mv	a0,s1
    22b8:	22c030ef          	jal	54e4 <close>
}
    22bc:	60e2                	ld	ra,24(sp)
    22be:	6442                	ld	s0,16(sp)
    22c0:	64a2                	ld	s1,8(sp)
    22c2:	6902                	ld	s2,0(sp)
    22c4:	6105                	addi	sp,sp,32
    22c6:	8082                	ret
    printf("%s: open failed\n", s);
    22c8:	85ca                	mv	a1,s2
    22ca:	00004517          	auipc	a0,0x4
    22ce:	0b650513          	addi	a0,a0,182 # 6380 <malloc+0x9e0>
    22d2:	61a030ef          	jal	58ec <printf>
    exit(1);
    22d6:	4505                	li	a0,1
    22d8:	1e4030ef          	jal	54bc <exit>

00000000000022dc <sbrkbugs>:
{
    22dc:	1141                	addi	sp,sp,-16
    22de:	e406                	sd	ra,8(sp)
    22e0:	e022                	sd	s0,0(sp)
    22e2:	0800                	addi	s0,sp,16
  int pid = fork();
    22e4:	1d0030ef          	jal	54b4 <fork>
  if (pid < 0) {
    22e8:	00054c63          	bltz	a0,2300 <sbrkbugs+0x24>
  if (pid == 0) {
    22ec:	e11d                	bnez	a0,2312 <sbrkbugs+0x36>
    int sz = (uint64)sbrk(0);
    22ee:	19a030ef          	jal	5488 <sbrk>
    sbrk(-sz);
    22f2:	40a0053b          	negw	a0,a0
    22f6:	192030ef          	jal	5488 <sbrk>
    exit(0);
    22fa:	4501                	li	a0,0
    22fc:	1c0030ef          	jal	54bc <exit>
    printf("fork failed\n");
    2300:	00005517          	auipc	a0,0x5
    2304:	75850513          	addi	a0,a0,1880 # 7a58 <malloc+0x20b8>
    2308:	5e4030ef          	jal	58ec <printf>
    exit(1);
    230c:	4505                	li	a0,1
    230e:	1ae030ef          	jal	54bc <exit>
  wait(0);
    2312:	4501                	li	a0,0
    2314:	1b0030ef          	jal	54c4 <wait>
  pid = fork();
    2318:	19c030ef          	jal	54b4 <fork>
  if (pid < 0) {
    231c:	00054f63          	bltz	a0,233a <sbrkbugs+0x5e>
  if (pid == 0) {
    2320:	e515                	bnez	a0,234c <sbrkbugs+0x70>
    int sz = (uint64)sbrk(0);
    2322:	166030ef          	jal	5488 <sbrk>
    sbrk(-(sz - 3500));
    2326:	6785                	lui	a5,0x1
    2328:	dac7879b          	addiw	a5,a5,-596 # dac <linktest+0x138>
    232c:	40a7853b          	subw	a0,a5,a0
    2330:	158030ef          	jal	5488 <sbrk>
    exit(0);
    2334:	4501                	li	a0,0
    2336:	186030ef          	jal	54bc <exit>
    printf("fork failed\n");
    233a:	00005517          	auipc	a0,0x5
    233e:	71e50513          	addi	a0,a0,1822 # 7a58 <malloc+0x20b8>
    2342:	5aa030ef          	jal	58ec <printf>
    exit(1);
    2346:	4505                	li	a0,1
    2348:	174030ef          	jal	54bc <exit>
  wait(0);
    234c:	4501                	li	a0,0
    234e:	176030ef          	jal	54c4 <wait>
  pid = fork();
    2352:	162030ef          	jal	54b4 <fork>
  if (pid < 0) {
    2356:	02054263          	bltz	a0,237a <sbrkbugs+0x9e>
  if (pid == 0) {
    235a:	e90d                	bnez	a0,238c <sbrkbugs+0xb0>
    sbrk((10 * PGSIZE + 2048) - (uint64)sbrk(0));
    235c:	12c030ef          	jal	5488 <sbrk>
    2360:	67ad                	lui	a5,0xb
    2362:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x218>
    2366:	40a7853b          	subw	a0,a5,a0
    236a:	11e030ef          	jal	5488 <sbrk>
    sbrk(-10);
    236e:	5559                	li	a0,-10
    2370:	118030ef          	jal	5488 <sbrk>
    exit(0);
    2374:	4501                	li	a0,0
    2376:	146030ef          	jal	54bc <exit>
    printf("fork failed\n");
    237a:	00005517          	auipc	a0,0x5
    237e:	6de50513          	addi	a0,a0,1758 # 7a58 <malloc+0x20b8>
    2382:	56a030ef          	jal	58ec <printf>
    exit(1);
    2386:	4505                	li	a0,1
    2388:	134030ef          	jal	54bc <exit>
  wait(0);
    238c:	4501                	li	a0,0
    238e:	136030ef          	jal	54c4 <wait>
  exit(0);
    2392:	4501                	li	a0,0
    2394:	128030ef          	jal	54bc <exit>

0000000000002398 <sbrklast>:
{
    2398:	7179                	addi	sp,sp,-48
    239a:	f406                	sd	ra,40(sp)
    239c:	f022                	sd	s0,32(sp)
    239e:	ec26                	sd	s1,24(sp)
    23a0:	e84a                	sd	s2,16(sp)
    23a2:	e44e                	sd	s3,8(sp)
    23a4:	e052                	sd	s4,0(sp)
    23a6:	1800                	addi	s0,sp,48
  uint64 top = (uint64)sbrk(0);
    23a8:	4501                	li	a0,0
    23aa:	0de030ef          	jal	5488 <sbrk>
  if ((top % PGSIZE) != 0)
    23ae:	03451793          	slli	a5,a0,0x34
    23b2:	ebad                	bnez	a5,2424 <sbrklast+0x8c>
  sbrk(PGSIZE);
    23b4:	6505                	lui	a0,0x1
    23b6:	0d2030ef          	jal	5488 <sbrk>
  sbrk(10);
    23ba:	4529                	li	a0,10
    23bc:	0cc030ef          	jal	5488 <sbrk>
  sbrk(-20);
    23c0:	5531                	li	a0,-20
    23c2:	0c6030ef          	jal	5488 <sbrk>
  top = (uint64)sbrk(0);
    23c6:	4501                	li	a0,0
    23c8:	0c0030ef          	jal	5488 <sbrk>
    23cc:	84aa                	mv	s1,a0
  char *p = (char *)(top - 64);
    23ce:	fc050913          	addi	s2,a0,-64 # fc0 <bigdir+0x122>
  p[0] = 'x';
    23d2:	07800a13          	li	s4,120
    23d6:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    23da:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR | O_CREATE);
    23de:	20200593          	li	a1,514
    23e2:	854a                	mv	a0,s2
    23e4:	118030ef          	jal	54fc <open>
    23e8:	89aa                	mv	s3,a0
  write(fd, p, 1);
    23ea:	4605                	li	a2,1
    23ec:	85ca                	mv	a1,s2
    23ee:	0ee030ef          	jal	54dc <write>
  close(fd);
    23f2:	854e                	mv	a0,s3
    23f4:	0f0030ef          	jal	54e4 <close>
  fd = open(p, O_RDWR);
    23f8:	4589                	li	a1,2
    23fa:	854a                	mv	a0,s2
    23fc:	100030ef          	jal	54fc <open>
  p[0] = '\0';
    2400:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2404:	4605                	li	a2,1
    2406:	85ca                	mv	a1,s2
    2408:	0cc030ef          	jal	54d4 <read>
  if (p[0] != 'x')
    240c:	fc04c783          	lbu	a5,-64(s1)
    2410:	03479263          	bne	a5,s4,2434 <sbrklast+0x9c>
}
    2414:	70a2                	ld	ra,40(sp)
    2416:	7402                	ld	s0,32(sp)
    2418:	64e2                	ld	s1,24(sp)
    241a:	6942                	ld	s2,16(sp)
    241c:	69a2                	ld	s3,8(sp)
    241e:	6a02                	ld	s4,0(sp)
    2420:	6145                	addi	sp,sp,48
    2422:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2424:	0347d513          	srli	a0,a5,0x34
    2428:	6785                	lui	a5,0x1
    242a:	40a7853b          	subw	a0,a5,a0
    242e:	05a030ef          	jal	5488 <sbrk>
    2432:	b749                	j	23b4 <sbrklast+0x1c>
    exit(1);
    2434:	4505                	li	a0,1
    2436:	086030ef          	jal	54bc <exit>

000000000000243a <sbrk8000>:
{
    243a:	1141                	addi	sp,sp,-16
    243c:	e406                	sd	ra,8(sp)
    243e:	e022                	sd	s0,0(sp)
    2440:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2442:	80000537          	lui	a0,0x80000
    2446:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff030c>
    2448:	040030ef          	jal	5488 <sbrk>
  volatile char *top = sbrk(0);
    244c:	4501                	li	a0,0
    244e:	03a030ef          	jal	5488 <sbrk>
  *(top - 1) = *(top - 1) + 1;
    2452:	fff54783          	lbu	a5,-1(a0)
    2456:	2785                	addiw	a5,a5,1 # 1001 <badarg+0x1>
    2458:	0ff7f793          	zext.b	a5,a5
    245c:	fef50fa3          	sb	a5,-1(a0)
}
    2460:	60a2                	ld	ra,8(sp)
    2462:	6402                	ld	s0,0(sp)
    2464:	0141                	addi	sp,sp,16
    2466:	8082                	ret

0000000000002468 <execout>:
{
    2468:	715d                	addi	sp,sp,-80
    246a:	e486                	sd	ra,72(sp)
    246c:	e0a2                	sd	s0,64(sp)
    246e:	fc26                	sd	s1,56(sp)
    2470:	f84a                	sd	s2,48(sp)
    2472:	f44e                	sd	s3,40(sp)
    2474:	f052                	sd	s4,32(sp)
    2476:	0880                	addi	s0,sp,80
  for (int avail = 0; avail < 15; avail++) {
    2478:	4901                	li	s2,0
    247a:	49bd                	li	s3,15
    int pid = fork();
    247c:	038030ef          	jal	54b4 <fork>
    2480:	84aa                	mv	s1,a0
    if (pid < 0) {
    2482:	00054c63          	bltz	a0,249a <execout+0x32>
    } else if (pid == 0) {
    2486:	c11d                	beqz	a0,24ac <execout+0x44>
      wait((int *)0);
    2488:	4501                	li	a0,0
    248a:	03a030ef          	jal	54c4 <wait>
  for (int avail = 0; avail < 15; avail++) {
    248e:	2905                	addiw	s2,s2,1
    2490:	ff3916e3          	bne	s2,s3,247c <execout+0x14>
  exit(0);
    2494:	4501                	li	a0,0
    2496:	026030ef          	jal	54bc <exit>
      printf("fork failed\n");
    249a:	00005517          	auipc	a0,0x5
    249e:	5be50513          	addi	a0,a0,1470 # 7a58 <malloc+0x20b8>
    24a2:	44a030ef          	jal	58ec <printf>
      exit(1);
    24a6:	4505                	li	a0,1
    24a8:	014030ef          	jal	54bc <exit>
        if (a == SBRK_ERROR)
    24ac:	59fd                	li	s3,-1
        *(a + PGSIZE - 1) = 1;
    24ae:	4a05                	li	s4,1
        char *a = sbrk(PGSIZE);
    24b0:	6505                	lui	a0,0x1
    24b2:	7d7020ef          	jal	5488 <sbrk>
        if (a == SBRK_ERROR)
    24b6:	01350763          	beq	a0,s3,24c4 <execout+0x5c>
        *(a + PGSIZE - 1) = 1;
    24ba:	6785                	lui	a5,0x1
    24bc:	953e                	add	a0,a0,a5
    24be:	ff450fa3          	sb	s4,-1(a0) # fff <pgbug+0x2b>
      while (1) {
    24c2:	b7fd                	j	24b0 <execout+0x48>
      for (int i = 0; i < avail; i++)
    24c4:	01205863          	blez	s2,24d4 <execout+0x6c>
        sbrk(-PGSIZE);
    24c8:	757d                	lui	a0,0xfffff
    24ca:	7bf020ef          	jal	5488 <sbrk>
      for (int i = 0; i < avail; i++)
    24ce:	2485                	addiw	s1,s1,1
    24d0:	ff249ce3          	bne	s1,s2,24c8 <execout+0x60>
      close(1);
    24d4:	4505                	li	a0,1
    24d6:	00e030ef          	jal	54e4 <close>
      char *args[] = {"echo", "x", 0};
    24da:	00003517          	auipc	a0,0x3
    24de:	5fe50513          	addi	a0,a0,1534 # 5ad8 <malloc+0x138>
    24e2:	faa43c23          	sd	a0,-72(s0)
    24e6:	00003797          	auipc	a5,0x3
    24ea:	66278793          	addi	a5,a5,1634 # 5b48 <malloc+0x1a8>
    24ee:	fcf43023          	sd	a5,-64(s0)
    24f2:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    24f6:	fb840593          	addi	a1,s0,-72
    24fa:	7fb020ef          	jal	54f4 <exec>
      exit(0);
    24fe:	4501                	li	a0,0
    2500:	7bd020ef          	jal	54bc <exit>

0000000000002504 <fourteen>:
{
    2504:	1101                	addi	sp,sp,-32
    2506:	ec06                	sd	ra,24(sp)
    2508:	e822                	sd	s0,16(sp)
    250a:	e426                	sd	s1,8(sp)
    250c:	1000                	addi	s0,sp,32
    250e:	84aa                	mv	s1,a0
  if (mkdir("12345678901234") != 0) {
    2510:	00004517          	auipc	a0,0x4
    2514:	5f850513          	addi	a0,a0,1528 # 6b08 <malloc+0x1168>
    2518:	00c030ef          	jal	5524 <mkdir>
    251c:	e555                	bnez	a0,25c8 <fourteen+0xc4>
  if (mkdir("12345678901234/123456789012345") != 0) {
    251e:	00004517          	auipc	a0,0x4
    2522:	44250513          	addi	a0,a0,1090 # 6960 <malloc+0xfc0>
    2526:	7ff020ef          	jal	5524 <mkdir>
    252a:	e94d                	bnez	a0,25dc <fourteen+0xd8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    252c:	20000593          	li	a1,512
    2530:	00004517          	auipc	a0,0x4
    2534:	48850513          	addi	a0,a0,1160 # 69b8 <malloc+0x1018>
    2538:	7c5020ef          	jal	54fc <open>
  if (fd < 0) {
    253c:	0a054a63          	bltz	a0,25f0 <fourteen+0xec>
  close(fd);
    2540:	7a5020ef          	jal	54e4 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2544:	4581                	li	a1,0
    2546:	00004517          	auipc	a0,0x4
    254a:	4ea50513          	addi	a0,a0,1258 # 6a30 <malloc+0x1090>
    254e:	7af020ef          	jal	54fc <open>
  if (fd < 0) {
    2552:	0a054963          	bltz	a0,2604 <fourteen+0x100>
  close(fd);
    2556:	78f020ef          	jal	54e4 <close>
  if (mkdir("12345678901234/12345678901234") == 0) {
    255a:	00004517          	auipc	a0,0x4
    255e:	54650513          	addi	a0,a0,1350 # 6aa0 <malloc+0x1100>
    2562:	7c3020ef          	jal	5524 <mkdir>
    2566:	c94d                	beqz	a0,2618 <fourteen+0x114>
  if (mkdir("123456789012345/12345678901234") == 0) {
    2568:	00004517          	auipc	a0,0x4
    256c:	59050513          	addi	a0,a0,1424 # 6af8 <malloc+0x1158>
    2570:	7b5020ef          	jal	5524 <mkdir>
    2574:	cd45                	beqz	a0,262c <fourteen+0x128>
  unlink("123456789012345/12345678901234");
    2576:	00004517          	auipc	a0,0x4
    257a:	58250513          	addi	a0,a0,1410 # 6af8 <malloc+0x1158>
    257e:	78f020ef          	jal	550c <unlink>
  unlink("12345678901234/12345678901234");
    2582:	00004517          	auipc	a0,0x4
    2586:	51e50513          	addi	a0,a0,1310 # 6aa0 <malloc+0x1100>
    258a:	783020ef          	jal	550c <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    258e:	00004517          	auipc	a0,0x4
    2592:	4a250513          	addi	a0,a0,1186 # 6a30 <malloc+0x1090>
    2596:	777020ef          	jal	550c <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    259a:	00004517          	auipc	a0,0x4
    259e:	41e50513          	addi	a0,a0,1054 # 69b8 <malloc+0x1018>
    25a2:	76b020ef          	jal	550c <unlink>
  unlink("12345678901234/123456789012345");
    25a6:	00004517          	auipc	a0,0x4
    25aa:	3ba50513          	addi	a0,a0,954 # 6960 <malloc+0xfc0>
    25ae:	75f020ef          	jal	550c <unlink>
  unlink("12345678901234");
    25b2:	00004517          	auipc	a0,0x4
    25b6:	55650513          	addi	a0,a0,1366 # 6b08 <malloc+0x1168>
    25ba:	753020ef          	jal	550c <unlink>
}
    25be:	60e2                	ld	ra,24(sp)
    25c0:	6442                	ld	s0,16(sp)
    25c2:	64a2                	ld	s1,8(sp)
    25c4:	6105                	addi	sp,sp,32
    25c6:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    25c8:	85a6                	mv	a1,s1
    25ca:	00004517          	auipc	a0,0x4
    25ce:	36e50513          	addi	a0,a0,878 # 6938 <malloc+0xf98>
    25d2:	31a030ef          	jal	58ec <printf>
    exit(1);
    25d6:	4505                	li	a0,1
    25d8:	6e5020ef          	jal	54bc <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    25dc:	85a6                	mv	a1,s1
    25de:	00004517          	auipc	a0,0x4
    25e2:	3a250513          	addi	a0,a0,930 # 6980 <malloc+0xfe0>
    25e6:	306030ef          	jal	58ec <printf>
    exit(1);
    25ea:	4505                	li	a0,1
    25ec:	6d1020ef          	jal	54bc <exit>
    printf(
    25f0:	85a6                	mv	a1,s1
    25f2:	00004517          	auipc	a0,0x4
    25f6:	3f650513          	addi	a0,a0,1014 # 69e8 <malloc+0x1048>
    25fa:	2f2030ef          	jal	58ec <printf>
    exit(1);
    25fe:	4505                	li	a0,1
    2600:	6bd020ef          	jal	54bc <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2604:	85a6                	mv	a1,s1
    2606:	00004517          	auipc	a0,0x4
    260a:	45a50513          	addi	a0,a0,1114 # 6a60 <malloc+0x10c0>
    260e:	2de030ef          	jal	58ec <printf>
    exit(1);
    2612:	4505                	li	a0,1
    2614:	6a9020ef          	jal	54bc <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2618:	85a6                	mv	a1,s1
    261a:	00004517          	auipc	a0,0x4
    261e:	4a650513          	addi	a0,a0,1190 # 6ac0 <malloc+0x1120>
    2622:	2ca030ef          	jal	58ec <printf>
    exit(1);
    2626:	4505                	li	a0,1
    2628:	695020ef          	jal	54bc <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    262c:	85a6                	mv	a1,s1
    262e:	00004517          	auipc	a0,0x4
    2632:	4ea50513          	addi	a0,a0,1258 # 6b18 <malloc+0x1178>
    2636:	2b6030ef          	jal	58ec <printf>
    exit(1);
    263a:	4505                	li	a0,1
    263c:	681020ef          	jal	54bc <exit>

0000000000002640 <diskfull>:
{
    2640:	b8010113          	addi	sp,sp,-1152
    2644:	46113c23          	sd	ra,1144(sp)
    2648:	46813823          	sd	s0,1136(sp)
    264c:	46913423          	sd	s1,1128(sp)
    2650:	47213023          	sd	s2,1120(sp)
    2654:	45313c23          	sd	s3,1112(sp)
    2658:	45413823          	sd	s4,1104(sp)
    265c:	45513423          	sd	s5,1096(sp)
    2660:	45613023          	sd	s6,1088(sp)
    2664:	43713c23          	sd	s7,1080(sp)
    2668:	43813823          	sd	s8,1072(sp)
    266c:	43913423          	sd	s9,1064(sp)
    2670:	48010413          	addi	s0,sp,1152
    2674:	8caa                	mv	s9,a0
  unlink("diskfulldir");
    2676:	00004517          	auipc	a0,0x4
    267a:	4da50513          	addi	a0,a0,1242 # 6b50 <malloc+0x11b0>
    267e:	68f020ef          	jal	550c <unlink>
    2682:	03000993          	li	s3,48
    name[0] = 'b';
    2686:	06200b13          	li	s6,98
    name[1] = 'i';
    268a:	06900a93          	li	s5,105
    name[2] = 'g';
    268e:	06700a13          	li	s4,103
    2692:	10c00b93          	li	s7,268
  for (fi = 0; done == 0 && '0' + fi < 0177; fi++) {
    2696:	07f00c13          	li	s8,127
    269a:	aab9                	j	27f8 <diskfull+0x1b8>
      printf("%s: could not create file %s\n", s, name);
    269c:	b8040613          	addi	a2,s0,-1152
    26a0:	85e6                	mv	a1,s9
    26a2:	00004517          	auipc	a0,0x4
    26a6:	4be50513          	addi	a0,a0,1214 # 6b60 <malloc+0x11c0>
    26aa:	242030ef          	jal	58ec <printf>
      break;
    26ae:	a039                	j	26bc <diskfull+0x7c>
        close(fd);
    26b0:	854a                	mv	a0,s2
    26b2:	633020ef          	jal	54e4 <close>
    close(fd);
    26b6:	854a                	mv	a0,s2
    26b8:	62d020ef          	jal	54e4 <close>
  for (int i = 0; i < nzz; i++) {
    26bc:	4481                	li	s1,0
    name[0] = 'z';
    26be:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++) {
    26c2:	08000993          	li	s3,128
    name[0] = 'z';
    26c6:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    26ca:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    26ce:	41f4d71b          	sraiw	a4,s1,0x1f
    26d2:	01b7571b          	srliw	a4,a4,0x1b
    26d6:	009707bb          	addw	a5,a4,s1
    26da:	4057d69b          	sraiw	a3,a5,0x5
    26de:	0306869b          	addiw	a3,a3,48
    26e2:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    26e6:	8bfd                	andi	a5,a5,31
    26e8:	9f99                	subw	a5,a5,a4
    26ea:	0307879b          	addiw	a5,a5,48
    26ee:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    26f2:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    26f6:	ba040513          	addi	a0,s0,-1120
    26fa:	613020ef          	jal	550c <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    26fe:	60200593          	li	a1,1538
    2702:	ba040513          	addi	a0,s0,-1120
    2706:	5f7020ef          	jal	54fc <open>
    if (fd < 0)
    270a:	00054763          	bltz	a0,2718 <diskfull+0xd8>
    close(fd);
    270e:	5d7020ef          	jal	54e4 <close>
  for (int i = 0; i < nzz; i++) {
    2712:	2485                	addiw	s1,s1,1
    2714:	fb3499e3          	bne	s1,s3,26c6 <diskfull+0x86>
  if (mkdir("diskfulldir") == 0)
    2718:	00004517          	auipc	a0,0x4
    271c:	43850513          	addi	a0,a0,1080 # 6b50 <malloc+0x11b0>
    2720:	605020ef          	jal	5524 <mkdir>
    2724:	12050063          	beqz	a0,2844 <diskfull+0x204>
  unlink("diskfulldir");
    2728:	00004517          	auipc	a0,0x4
    272c:	42850513          	addi	a0,a0,1064 # 6b50 <malloc+0x11b0>
    2730:	5dd020ef          	jal	550c <unlink>
  for (int i = 0; i < nzz; i++) {
    2734:	4481                	li	s1,0
    name[0] = 'z';
    2736:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++) {
    273a:	08000993          	li	s3,128
    name[0] = 'z';
    273e:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    2742:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    2746:	41f4d71b          	sraiw	a4,s1,0x1f
    274a:	01b7571b          	srliw	a4,a4,0x1b
    274e:	009707bb          	addw	a5,a4,s1
    2752:	4057d69b          	sraiw	a3,a5,0x5
    2756:	0306869b          	addiw	a3,a3,48
    275a:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    275e:	8bfd                	andi	a5,a5,31
    2760:	9f99                	subw	a5,a5,a4
    2762:	0307879b          	addiw	a5,a5,48
    2766:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    276a:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    276e:	ba040513          	addi	a0,s0,-1120
    2772:	59b020ef          	jal	550c <unlink>
  for (int i = 0; i < nzz; i++) {
    2776:	2485                	addiw	s1,s1,1
    2778:	fd3493e3          	bne	s1,s3,273e <diskfull+0xfe>
    277c:	03000493          	li	s1,48
    name[0] = 'b';
    2780:	06200a93          	li	s5,98
    name[1] = 'i';
    2784:	06900a13          	li	s4,105
    name[2] = 'g';
    2788:	06700993          	li	s3,103
  for (int i = 0; '0' + i < 0177; i++) {
    278c:	07f00913          	li	s2,127
    name[0] = 'b';
    2790:	bb540023          	sb	s5,-1120(s0)
    name[1] = 'i';
    2794:	bb4400a3          	sb	s4,-1119(s0)
    name[2] = 'g';
    2798:	bb340123          	sb	s3,-1118(s0)
    name[3] = '0' + i;
    279c:	ba9401a3          	sb	s1,-1117(s0)
    name[4] = '\0';
    27a0:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    27a4:	ba040513          	addi	a0,s0,-1120
    27a8:	565020ef          	jal	550c <unlink>
  for (int i = 0; '0' + i < 0177; i++) {
    27ac:	2485                	addiw	s1,s1,1
    27ae:	0ff4f493          	zext.b	s1,s1
    27b2:	fd249fe3          	bne	s1,s2,2790 <diskfull+0x150>
}
    27b6:	47813083          	ld	ra,1144(sp)
    27ba:	47013403          	ld	s0,1136(sp)
    27be:	46813483          	ld	s1,1128(sp)
    27c2:	46013903          	ld	s2,1120(sp)
    27c6:	45813983          	ld	s3,1112(sp)
    27ca:	45013a03          	ld	s4,1104(sp)
    27ce:	44813a83          	ld	s5,1096(sp)
    27d2:	44013b03          	ld	s6,1088(sp)
    27d6:	43813b83          	ld	s7,1080(sp)
    27da:	43013c03          	ld	s8,1072(sp)
    27de:	42813c83          	ld	s9,1064(sp)
    27e2:	48010113          	addi	sp,sp,1152
    27e6:	8082                	ret
    close(fd);
    27e8:	854a                	mv	a0,s2
    27ea:	4fb020ef          	jal	54e4 <close>
  for (fi = 0; done == 0 && '0' + fi < 0177; fi++) {
    27ee:	2985                	addiw	s3,s3,1
    27f0:	0ff9f993          	zext.b	s3,s3
    27f4:	ed8984e3          	beq	s3,s8,26bc <diskfull+0x7c>
    name[0] = 'b';
    27f8:	b9640023          	sb	s6,-1152(s0)
    name[1] = 'i';
    27fc:	b95400a3          	sb	s5,-1151(s0)
    name[2] = 'g';
    2800:	b9440123          	sb	s4,-1150(s0)
    name[3] = '0' + fi;
    2804:	b93401a3          	sb	s3,-1149(s0)
    name[4] = '\0';
    2808:	b8040223          	sb	zero,-1148(s0)
    unlink(name);
    280c:	b8040513          	addi	a0,s0,-1152
    2810:	4fd020ef          	jal	550c <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    2814:	60200593          	li	a1,1538
    2818:	b8040513          	addi	a0,s0,-1152
    281c:	4e1020ef          	jal	54fc <open>
    2820:	892a                	mv	s2,a0
    if (fd < 0) {
    2822:	e6054de3          	bltz	a0,269c <diskfull+0x5c>
    2826:	84de                	mv	s1,s7
      if (write(fd, buf, BSIZE) != BSIZE) {
    2828:	40000613          	li	a2,1024
    282c:	ba040593          	addi	a1,s0,-1120
    2830:	854a                	mv	a0,s2
    2832:	4ab020ef          	jal	54dc <write>
    2836:	40000793          	li	a5,1024
    283a:	e6f51be3          	bne	a0,a5,26b0 <diskfull+0x70>
    for (int i = 0; i < MAXFILE; i++) {
    283e:	34fd                	addiw	s1,s1,-1
    2840:	f4e5                	bnez	s1,2828 <diskfull+0x1e8>
    2842:	b75d                	j	27e8 <diskfull+0x1a8>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n", s);
    2844:	85e6                	mv	a1,s9
    2846:	00004517          	auipc	a0,0x4
    284a:	33a50513          	addi	a0,a0,826 # 6b80 <malloc+0x11e0>
    284e:	09e030ef          	jal	58ec <printf>
    2852:	bdd9                	j	2728 <diskfull+0xe8>

0000000000002854 <iputtest>:
{
    2854:	1101                	addi	sp,sp,-32
    2856:	ec06                	sd	ra,24(sp)
    2858:	e822                	sd	s0,16(sp)
    285a:	e426                	sd	s1,8(sp)
    285c:	1000                	addi	s0,sp,32
    285e:	84aa                	mv	s1,a0
  if (mkdir("iputdir") < 0) {
    2860:	00004517          	auipc	a0,0x4
    2864:	35050513          	addi	a0,a0,848 # 6bb0 <malloc+0x1210>
    2868:	4bd020ef          	jal	5524 <mkdir>
    286c:	02054f63          	bltz	a0,28aa <iputtest+0x56>
  if (chdir("iputdir") < 0) {
    2870:	00004517          	auipc	a0,0x4
    2874:	34050513          	addi	a0,a0,832 # 6bb0 <malloc+0x1210>
    2878:	4b5020ef          	jal	552c <chdir>
    287c:	04054163          	bltz	a0,28be <iputtest+0x6a>
  if (unlink("../iputdir") < 0) {
    2880:	00004517          	auipc	a0,0x4
    2884:	37050513          	addi	a0,a0,880 # 6bf0 <malloc+0x1250>
    2888:	485020ef          	jal	550c <unlink>
    288c:	04054363          	bltz	a0,28d2 <iputtest+0x7e>
  if (chdir("/") < 0) {
    2890:	00004517          	auipc	a0,0x4
    2894:	39050513          	addi	a0,a0,912 # 6c20 <malloc+0x1280>
    2898:	495020ef          	jal	552c <chdir>
    289c:	04054563          	bltz	a0,28e6 <iputtest+0x92>
}
    28a0:	60e2                	ld	ra,24(sp)
    28a2:	6442                	ld	s0,16(sp)
    28a4:	64a2                	ld	s1,8(sp)
    28a6:	6105                	addi	sp,sp,32
    28a8:	8082                	ret
    printf("%s: mkdir failed\n", s);
    28aa:	85a6                	mv	a1,s1
    28ac:	00004517          	auipc	a0,0x4
    28b0:	30c50513          	addi	a0,a0,780 # 6bb8 <malloc+0x1218>
    28b4:	038030ef          	jal	58ec <printf>
    exit(1);
    28b8:	4505                	li	a0,1
    28ba:	403020ef          	jal	54bc <exit>
    printf("%s: chdir iputdir failed\n", s);
    28be:	85a6                	mv	a1,s1
    28c0:	00004517          	auipc	a0,0x4
    28c4:	31050513          	addi	a0,a0,784 # 6bd0 <malloc+0x1230>
    28c8:	024030ef          	jal	58ec <printf>
    exit(1);
    28cc:	4505                	li	a0,1
    28ce:	3ef020ef          	jal	54bc <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    28d2:	85a6                	mv	a1,s1
    28d4:	00004517          	auipc	a0,0x4
    28d8:	32c50513          	addi	a0,a0,812 # 6c00 <malloc+0x1260>
    28dc:	010030ef          	jal	58ec <printf>
    exit(1);
    28e0:	4505                	li	a0,1
    28e2:	3db020ef          	jal	54bc <exit>
    printf("%s: chdir / failed\n", s);
    28e6:	85a6                	mv	a1,s1
    28e8:	00004517          	auipc	a0,0x4
    28ec:	34050513          	addi	a0,a0,832 # 6c28 <malloc+0x1288>
    28f0:	7fd020ef          	jal	58ec <printf>
    exit(1);
    28f4:	4505                	li	a0,1
    28f6:	3c7020ef          	jal	54bc <exit>

00000000000028fa <exitiputtest>:
{
    28fa:	7179                	addi	sp,sp,-48
    28fc:	f406                	sd	ra,40(sp)
    28fe:	f022                	sd	s0,32(sp)
    2900:	ec26                	sd	s1,24(sp)
    2902:	1800                	addi	s0,sp,48
    2904:	84aa                	mv	s1,a0
  pid = fork();
    2906:	3af020ef          	jal	54b4 <fork>
  if (pid < 0) {
    290a:	02054e63          	bltz	a0,2946 <exitiputtest+0x4c>
  if (pid == 0) {
    290e:	e541                	bnez	a0,2996 <exitiputtest+0x9c>
    if (mkdir("iputdir") < 0) {
    2910:	00004517          	auipc	a0,0x4
    2914:	2a050513          	addi	a0,a0,672 # 6bb0 <malloc+0x1210>
    2918:	40d020ef          	jal	5524 <mkdir>
    291c:	02054f63          	bltz	a0,295a <exitiputtest+0x60>
    if (chdir("iputdir") < 0) {
    2920:	00004517          	auipc	a0,0x4
    2924:	29050513          	addi	a0,a0,656 # 6bb0 <malloc+0x1210>
    2928:	405020ef          	jal	552c <chdir>
    292c:	04054163          	bltz	a0,296e <exitiputtest+0x74>
    if (unlink("../iputdir") < 0) {
    2930:	00004517          	auipc	a0,0x4
    2934:	2c050513          	addi	a0,a0,704 # 6bf0 <malloc+0x1250>
    2938:	3d5020ef          	jal	550c <unlink>
    293c:	04054363          	bltz	a0,2982 <exitiputtest+0x88>
    exit(0);
    2940:	4501                	li	a0,0
    2942:	37b020ef          	jal	54bc <exit>
    printf("%s: fork failed\n", s);
    2946:	85a6                	mv	a1,s1
    2948:	00004517          	auipc	a0,0x4
    294c:	a2050513          	addi	a0,a0,-1504 # 6368 <malloc+0x9c8>
    2950:	79d020ef          	jal	58ec <printf>
    exit(1);
    2954:	4505                	li	a0,1
    2956:	367020ef          	jal	54bc <exit>
      printf("%s: mkdir failed\n", s);
    295a:	85a6                	mv	a1,s1
    295c:	00004517          	auipc	a0,0x4
    2960:	25c50513          	addi	a0,a0,604 # 6bb8 <malloc+0x1218>
    2964:	789020ef          	jal	58ec <printf>
      exit(1);
    2968:	4505                	li	a0,1
    296a:	353020ef          	jal	54bc <exit>
      printf("%s: child chdir failed\n", s);
    296e:	85a6                	mv	a1,s1
    2970:	00004517          	auipc	a0,0x4
    2974:	2d050513          	addi	a0,a0,720 # 6c40 <malloc+0x12a0>
    2978:	775020ef          	jal	58ec <printf>
      exit(1);
    297c:	4505                	li	a0,1
    297e:	33f020ef          	jal	54bc <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2982:	85a6                	mv	a1,s1
    2984:	00004517          	auipc	a0,0x4
    2988:	27c50513          	addi	a0,a0,636 # 6c00 <malloc+0x1260>
    298c:	761020ef          	jal	58ec <printf>
      exit(1);
    2990:	4505                	li	a0,1
    2992:	32b020ef          	jal	54bc <exit>
  wait(&xstatus);
    2996:	fdc40513          	addi	a0,s0,-36
    299a:	32b020ef          	jal	54c4 <wait>
  exit(xstatus);
    299e:	fdc42503          	lw	a0,-36(s0)
    29a2:	31b020ef          	jal	54bc <exit>

00000000000029a6 <dirtest>:
{
    29a6:	1101                	addi	sp,sp,-32
    29a8:	ec06                	sd	ra,24(sp)
    29aa:	e822                	sd	s0,16(sp)
    29ac:	e426                	sd	s1,8(sp)
    29ae:	1000                	addi	s0,sp,32
    29b0:	84aa                	mv	s1,a0
  if (mkdir("dir0") < 0) {
    29b2:	00004517          	auipc	a0,0x4
    29b6:	2a650513          	addi	a0,a0,678 # 6c58 <malloc+0x12b8>
    29ba:	36b020ef          	jal	5524 <mkdir>
    29be:	02054f63          	bltz	a0,29fc <dirtest+0x56>
  if (chdir("dir0") < 0) {
    29c2:	00004517          	auipc	a0,0x4
    29c6:	29650513          	addi	a0,a0,662 # 6c58 <malloc+0x12b8>
    29ca:	363020ef          	jal	552c <chdir>
    29ce:	04054163          	bltz	a0,2a10 <dirtest+0x6a>
  if (chdir("..") < 0) {
    29d2:	00004517          	auipc	a0,0x4
    29d6:	2a650513          	addi	a0,a0,678 # 6c78 <malloc+0x12d8>
    29da:	353020ef          	jal	552c <chdir>
    29de:	04054363          	bltz	a0,2a24 <dirtest+0x7e>
  if (unlink("dir0") < 0) {
    29e2:	00004517          	auipc	a0,0x4
    29e6:	27650513          	addi	a0,a0,630 # 6c58 <malloc+0x12b8>
    29ea:	323020ef          	jal	550c <unlink>
    29ee:	04054563          	bltz	a0,2a38 <dirtest+0x92>
}
    29f2:	60e2                	ld	ra,24(sp)
    29f4:	6442                	ld	s0,16(sp)
    29f6:	64a2                	ld	s1,8(sp)
    29f8:	6105                	addi	sp,sp,32
    29fa:	8082                	ret
    printf("%s: mkdir failed\n", s);
    29fc:	85a6                	mv	a1,s1
    29fe:	00004517          	auipc	a0,0x4
    2a02:	1ba50513          	addi	a0,a0,442 # 6bb8 <malloc+0x1218>
    2a06:	6e7020ef          	jal	58ec <printf>
    exit(1);
    2a0a:	4505                	li	a0,1
    2a0c:	2b1020ef          	jal	54bc <exit>
    printf("%s: chdir dir0 failed\n", s);
    2a10:	85a6                	mv	a1,s1
    2a12:	00004517          	auipc	a0,0x4
    2a16:	24e50513          	addi	a0,a0,590 # 6c60 <malloc+0x12c0>
    2a1a:	6d3020ef          	jal	58ec <printf>
    exit(1);
    2a1e:	4505                	li	a0,1
    2a20:	29d020ef          	jal	54bc <exit>
    printf("%s: chdir .. failed\n", s);
    2a24:	85a6                	mv	a1,s1
    2a26:	00004517          	auipc	a0,0x4
    2a2a:	25a50513          	addi	a0,a0,602 # 6c80 <malloc+0x12e0>
    2a2e:	6bf020ef          	jal	58ec <printf>
    exit(1);
    2a32:	4505                	li	a0,1
    2a34:	289020ef          	jal	54bc <exit>
    printf("%s: unlink dir0 failed\n", s);
    2a38:	85a6                	mv	a1,s1
    2a3a:	00004517          	auipc	a0,0x4
    2a3e:	25e50513          	addi	a0,a0,606 # 6c98 <malloc+0x12f8>
    2a42:	6ab020ef          	jal	58ec <printf>
    exit(1);
    2a46:	4505                	li	a0,1
    2a48:	275020ef          	jal	54bc <exit>

0000000000002a4c <subdir>:
{
    2a4c:	1101                	addi	sp,sp,-32
    2a4e:	ec06                	sd	ra,24(sp)
    2a50:	e822                	sd	s0,16(sp)
    2a52:	e426                	sd	s1,8(sp)
    2a54:	e04a                	sd	s2,0(sp)
    2a56:	1000                	addi	s0,sp,32
    2a58:	892a                	mv	s2,a0
  unlink("ff");
    2a5a:	00004517          	auipc	a0,0x4
    2a5e:	38650513          	addi	a0,a0,902 # 6de0 <malloc+0x1440>
    2a62:	2ab020ef          	jal	550c <unlink>
  if (mkdir("dd") != 0) {
    2a66:	00004517          	auipc	a0,0x4
    2a6a:	24a50513          	addi	a0,a0,586 # 6cb0 <malloc+0x1310>
    2a6e:	2b7020ef          	jal	5524 <mkdir>
    2a72:	2e051263          	bnez	a0,2d56 <subdir+0x30a>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2a76:	20200593          	li	a1,514
    2a7a:	00004517          	auipc	a0,0x4
    2a7e:	25650513          	addi	a0,a0,598 # 6cd0 <malloc+0x1330>
    2a82:	27b020ef          	jal	54fc <open>
    2a86:	84aa                	mv	s1,a0
  if (fd < 0) {
    2a88:	2e054163          	bltz	a0,2d6a <subdir+0x31e>
  write(fd, "ff", 2);
    2a8c:	4609                	li	a2,2
    2a8e:	00004597          	auipc	a1,0x4
    2a92:	35258593          	addi	a1,a1,850 # 6de0 <malloc+0x1440>
    2a96:	247020ef          	jal	54dc <write>
  close(fd);
    2a9a:	8526                	mv	a0,s1
    2a9c:	249020ef          	jal	54e4 <close>
  if (unlink("dd") >= 0) {
    2aa0:	00004517          	auipc	a0,0x4
    2aa4:	21050513          	addi	a0,a0,528 # 6cb0 <malloc+0x1310>
    2aa8:	265020ef          	jal	550c <unlink>
    2aac:	2c055963          	bgez	a0,2d7e <subdir+0x332>
  if (mkdir("/dd/dd") != 0) {
    2ab0:	00004517          	auipc	a0,0x4
    2ab4:	27850513          	addi	a0,a0,632 # 6d28 <malloc+0x1388>
    2ab8:	26d020ef          	jal	5524 <mkdir>
    2abc:	2c051b63          	bnez	a0,2d92 <subdir+0x346>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2ac0:	20200593          	li	a1,514
    2ac4:	00004517          	auipc	a0,0x4
    2ac8:	28c50513          	addi	a0,a0,652 # 6d50 <malloc+0x13b0>
    2acc:	231020ef          	jal	54fc <open>
    2ad0:	84aa                	mv	s1,a0
  if (fd < 0) {
    2ad2:	2c054a63          	bltz	a0,2da6 <subdir+0x35a>
  write(fd, "FF", 2);
    2ad6:	4609                	li	a2,2
    2ad8:	00004597          	auipc	a1,0x4
    2adc:	2a858593          	addi	a1,a1,680 # 6d80 <malloc+0x13e0>
    2ae0:	1fd020ef          	jal	54dc <write>
  close(fd);
    2ae4:	8526                	mv	a0,s1
    2ae6:	1ff020ef          	jal	54e4 <close>
  fd = open("dd/dd/../ff", 0);
    2aea:	4581                	li	a1,0
    2aec:	00004517          	auipc	a0,0x4
    2af0:	29c50513          	addi	a0,a0,668 # 6d88 <malloc+0x13e8>
    2af4:	209020ef          	jal	54fc <open>
    2af8:	84aa                	mv	s1,a0
  if (fd < 0) {
    2afa:	2c054063          	bltz	a0,2dba <subdir+0x36e>
  cc = read(fd, buf, sizeof(buf));
    2afe:	660d                	lui	a2,0x3
    2b00:	0000a597          	auipc	a1,0xa
    2b04:	1f858593          	addi	a1,a1,504 # ccf8 <buf>
    2b08:	1cd020ef          	jal	54d4 <read>
  if (cc != 2 || buf[0] != 'f') {
    2b0c:	4789                	li	a5,2
    2b0e:	2cf51063          	bne	a0,a5,2dce <subdir+0x382>
    2b12:	0000a717          	auipc	a4,0xa
    2b16:	1e674703          	lbu	a4,486(a4) # ccf8 <buf>
    2b1a:	06600793          	li	a5,102
    2b1e:	2af71863          	bne	a4,a5,2dce <subdir+0x382>
  close(fd);
    2b22:	8526                	mv	a0,s1
    2b24:	1c1020ef          	jal	54e4 <close>
  if (link("dd/dd/ff", "dd/dd/ffff") != 0) {
    2b28:	00004597          	auipc	a1,0x4
    2b2c:	2b058593          	addi	a1,a1,688 # 6dd8 <malloc+0x1438>
    2b30:	00004517          	auipc	a0,0x4
    2b34:	22050513          	addi	a0,a0,544 # 6d50 <malloc+0x13b0>
    2b38:	1e5020ef          	jal	551c <link>
    2b3c:	2a051363          	bnez	a0,2de2 <subdir+0x396>
  if (unlink("dd/dd/ff") != 0) {
    2b40:	00004517          	auipc	a0,0x4
    2b44:	21050513          	addi	a0,a0,528 # 6d50 <malloc+0x13b0>
    2b48:	1c5020ef          	jal	550c <unlink>
    2b4c:	2a051563          	bnez	a0,2df6 <subdir+0x3aa>
  if (open("dd/dd/ff", O_RDONLY) >= 0) {
    2b50:	4581                	li	a1,0
    2b52:	00004517          	auipc	a0,0x4
    2b56:	1fe50513          	addi	a0,a0,510 # 6d50 <malloc+0x13b0>
    2b5a:	1a3020ef          	jal	54fc <open>
    2b5e:	2a055663          	bgez	a0,2e0a <subdir+0x3be>
  if (chdir("dd") != 0) {
    2b62:	00004517          	auipc	a0,0x4
    2b66:	14e50513          	addi	a0,a0,334 # 6cb0 <malloc+0x1310>
    2b6a:	1c3020ef          	jal	552c <chdir>
    2b6e:	2a051863          	bnez	a0,2e1e <subdir+0x3d2>
  if (chdir("dd/../../dd") != 0) {
    2b72:	00004517          	auipc	a0,0x4
    2b76:	2fe50513          	addi	a0,a0,766 # 6e70 <malloc+0x14d0>
    2b7a:	1b3020ef          	jal	552c <chdir>
    2b7e:	2a051a63          	bnez	a0,2e32 <subdir+0x3e6>
  if (chdir("dd/../../../dd") != 0) {
    2b82:	00004517          	auipc	a0,0x4
    2b86:	31e50513          	addi	a0,a0,798 # 6ea0 <malloc+0x1500>
    2b8a:	1a3020ef          	jal	552c <chdir>
    2b8e:	2a051c63          	bnez	a0,2e46 <subdir+0x3fa>
  if (chdir("./..") != 0) {
    2b92:	00004517          	auipc	a0,0x4
    2b96:	34650513          	addi	a0,a0,838 # 6ed8 <malloc+0x1538>
    2b9a:	193020ef          	jal	552c <chdir>
    2b9e:	2a051e63          	bnez	a0,2e5a <subdir+0x40e>
  fd = open("dd/dd/ffff", 0);
    2ba2:	4581                	li	a1,0
    2ba4:	00004517          	auipc	a0,0x4
    2ba8:	23450513          	addi	a0,a0,564 # 6dd8 <malloc+0x1438>
    2bac:	151020ef          	jal	54fc <open>
    2bb0:	84aa                	mv	s1,a0
  if (fd < 0) {
    2bb2:	2a054e63          	bltz	a0,2e6e <subdir+0x422>
  if (read(fd, buf, sizeof(buf)) != 2) {
    2bb6:	660d                	lui	a2,0x3
    2bb8:	0000a597          	auipc	a1,0xa
    2bbc:	14058593          	addi	a1,a1,320 # ccf8 <buf>
    2bc0:	115020ef          	jal	54d4 <read>
    2bc4:	4789                	li	a5,2
    2bc6:	2af51e63          	bne	a0,a5,2e82 <subdir+0x436>
  close(fd);
    2bca:	8526                	mv	a0,s1
    2bcc:	119020ef          	jal	54e4 <close>
  if (open("dd/dd/ff", O_RDONLY) >= 0) {
    2bd0:	4581                	li	a1,0
    2bd2:	00004517          	auipc	a0,0x4
    2bd6:	17e50513          	addi	a0,a0,382 # 6d50 <malloc+0x13b0>
    2bda:	123020ef          	jal	54fc <open>
    2bde:	2a055c63          	bgez	a0,2e96 <subdir+0x44a>
  if (open("dd/ff/ff", O_CREATE | O_RDWR) >= 0) {
    2be2:	20200593          	li	a1,514
    2be6:	00004517          	auipc	a0,0x4
    2bea:	38250513          	addi	a0,a0,898 # 6f68 <malloc+0x15c8>
    2bee:	10f020ef          	jal	54fc <open>
    2bf2:	2a055c63          	bgez	a0,2eaa <subdir+0x45e>
  if (open("dd/xx/ff", O_CREATE | O_RDWR) >= 0) {
    2bf6:	20200593          	li	a1,514
    2bfa:	00004517          	auipc	a0,0x4
    2bfe:	39e50513          	addi	a0,a0,926 # 6f98 <malloc+0x15f8>
    2c02:	0fb020ef          	jal	54fc <open>
    2c06:	2a055c63          	bgez	a0,2ebe <subdir+0x472>
  if (open("dd", O_CREATE) >= 0) {
    2c0a:	20000593          	li	a1,512
    2c0e:	00004517          	auipc	a0,0x4
    2c12:	0a250513          	addi	a0,a0,162 # 6cb0 <malloc+0x1310>
    2c16:	0e7020ef          	jal	54fc <open>
    2c1a:	2a055c63          	bgez	a0,2ed2 <subdir+0x486>
  if (open("dd", O_RDWR) >= 0) {
    2c1e:	4589                	li	a1,2
    2c20:	00004517          	auipc	a0,0x4
    2c24:	09050513          	addi	a0,a0,144 # 6cb0 <malloc+0x1310>
    2c28:	0d5020ef          	jal	54fc <open>
    2c2c:	2a055d63          	bgez	a0,2ee6 <subdir+0x49a>
  if (open("dd", O_WRONLY) >= 0) {
    2c30:	4585                	li	a1,1
    2c32:	00004517          	auipc	a0,0x4
    2c36:	07e50513          	addi	a0,a0,126 # 6cb0 <malloc+0x1310>
    2c3a:	0c3020ef          	jal	54fc <open>
    2c3e:	2a055e63          	bgez	a0,2efa <subdir+0x4ae>
  if (link("dd/ff/ff", "dd/dd/xx") == 0) {
    2c42:	00004597          	auipc	a1,0x4
    2c46:	3e658593          	addi	a1,a1,998 # 7028 <malloc+0x1688>
    2c4a:	00004517          	auipc	a0,0x4
    2c4e:	31e50513          	addi	a0,a0,798 # 6f68 <malloc+0x15c8>
    2c52:	0cb020ef          	jal	551c <link>
    2c56:	2a050c63          	beqz	a0,2f0e <subdir+0x4c2>
  if (link("dd/xx/ff", "dd/dd/xx") == 0) {
    2c5a:	00004597          	auipc	a1,0x4
    2c5e:	3ce58593          	addi	a1,a1,974 # 7028 <malloc+0x1688>
    2c62:	00004517          	auipc	a0,0x4
    2c66:	33650513          	addi	a0,a0,822 # 6f98 <malloc+0x15f8>
    2c6a:	0b3020ef          	jal	551c <link>
    2c6e:	2a050a63          	beqz	a0,2f22 <subdir+0x4d6>
  if (link("dd/ff", "dd/dd/ffff") == 0) {
    2c72:	00004597          	auipc	a1,0x4
    2c76:	16658593          	addi	a1,a1,358 # 6dd8 <malloc+0x1438>
    2c7a:	00004517          	auipc	a0,0x4
    2c7e:	05650513          	addi	a0,a0,86 # 6cd0 <malloc+0x1330>
    2c82:	09b020ef          	jal	551c <link>
    2c86:	2a050863          	beqz	a0,2f36 <subdir+0x4ea>
  if (mkdir("dd/ff/ff") == 0) {
    2c8a:	00004517          	auipc	a0,0x4
    2c8e:	2de50513          	addi	a0,a0,734 # 6f68 <malloc+0x15c8>
    2c92:	093020ef          	jal	5524 <mkdir>
    2c96:	2a050a63          	beqz	a0,2f4a <subdir+0x4fe>
  if (mkdir("dd/xx/ff") == 0) {
    2c9a:	00004517          	auipc	a0,0x4
    2c9e:	2fe50513          	addi	a0,a0,766 # 6f98 <malloc+0x15f8>
    2ca2:	083020ef          	jal	5524 <mkdir>
    2ca6:	2a050c63          	beqz	a0,2f5e <subdir+0x512>
  if (mkdir("dd/dd/ffff") == 0) {
    2caa:	00004517          	auipc	a0,0x4
    2cae:	12e50513          	addi	a0,a0,302 # 6dd8 <malloc+0x1438>
    2cb2:	073020ef          	jal	5524 <mkdir>
    2cb6:	2a050e63          	beqz	a0,2f72 <subdir+0x526>
  if (unlink("dd/xx/ff") == 0) {
    2cba:	00004517          	auipc	a0,0x4
    2cbe:	2de50513          	addi	a0,a0,734 # 6f98 <malloc+0x15f8>
    2cc2:	04b020ef          	jal	550c <unlink>
    2cc6:	2c050063          	beqz	a0,2f86 <subdir+0x53a>
  if (unlink("dd/ff/ff") == 0) {
    2cca:	00004517          	auipc	a0,0x4
    2cce:	29e50513          	addi	a0,a0,670 # 6f68 <malloc+0x15c8>
    2cd2:	03b020ef          	jal	550c <unlink>
    2cd6:	2c050263          	beqz	a0,2f9a <subdir+0x54e>
  if (chdir("dd/ff") == 0) {
    2cda:	00004517          	auipc	a0,0x4
    2cde:	ff650513          	addi	a0,a0,-10 # 6cd0 <malloc+0x1330>
    2ce2:	04b020ef          	jal	552c <chdir>
    2ce6:	2c050463          	beqz	a0,2fae <subdir+0x562>
  if (chdir("dd/xx") == 0) {
    2cea:	00004517          	auipc	a0,0x4
    2cee:	48e50513          	addi	a0,a0,1166 # 7178 <malloc+0x17d8>
    2cf2:	03b020ef          	jal	552c <chdir>
    2cf6:	2c050663          	beqz	a0,2fc2 <subdir+0x576>
  if (unlink("dd/dd/ffff") != 0) {
    2cfa:	00004517          	auipc	a0,0x4
    2cfe:	0de50513          	addi	a0,a0,222 # 6dd8 <malloc+0x1438>
    2d02:	00b020ef          	jal	550c <unlink>
    2d06:	2c051863          	bnez	a0,2fd6 <subdir+0x58a>
  if (unlink("dd/ff") != 0) {
    2d0a:	00004517          	auipc	a0,0x4
    2d0e:	fc650513          	addi	a0,a0,-58 # 6cd0 <malloc+0x1330>
    2d12:	7fa020ef          	jal	550c <unlink>
    2d16:	2c051a63          	bnez	a0,2fea <subdir+0x59e>
  if (unlink("dd") == 0) {
    2d1a:	00004517          	auipc	a0,0x4
    2d1e:	f9650513          	addi	a0,a0,-106 # 6cb0 <malloc+0x1310>
    2d22:	7ea020ef          	jal	550c <unlink>
    2d26:	2c050c63          	beqz	a0,2ffe <subdir+0x5b2>
  if (unlink("dd/dd") < 0) {
    2d2a:	00004517          	auipc	a0,0x4
    2d2e:	4be50513          	addi	a0,a0,1214 # 71e8 <malloc+0x1848>
    2d32:	7da020ef          	jal	550c <unlink>
    2d36:	2c054e63          	bltz	a0,3012 <subdir+0x5c6>
  if (unlink("dd") < 0) {
    2d3a:	00004517          	auipc	a0,0x4
    2d3e:	f7650513          	addi	a0,a0,-138 # 6cb0 <malloc+0x1310>
    2d42:	7ca020ef          	jal	550c <unlink>
    2d46:	2e054063          	bltz	a0,3026 <subdir+0x5da>
}
    2d4a:	60e2                	ld	ra,24(sp)
    2d4c:	6442                	ld	s0,16(sp)
    2d4e:	64a2                	ld	s1,8(sp)
    2d50:	6902                	ld	s2,0(sp)
    2d52:	6105                	addi	sp,sp,32
    2d54:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    2d56:	85ca                	mv	a1,s2
    2d58:	00004517          	auipc	a0,0x4
    2d5c:	f6050513          	addi	a0,a0,-160 # 6cb8 <malloc+0x1318>
    2d60:	38d020ef          	jal	58ec <printf>
    exit(1);
    2d64:	4505                	li	a0,1
    2d66:	756020ef          	jal	54bc <exit>
    printf("%s: create dd/ff failed\n", s);
    2d6a:	85ca                	mv	a1,s2
    2d6c:	00004517          	auipc	a0,0x4
    2d70:	f6c50513          	addi	a0,a0,-148 # 6cd8 <malloc+0x1338>
    2d74:	379020ef          	jal	58ec <printf>
    exit(1);
    2d78:	4505                	li	a0,1
    2d7a:	742020ef          	jal	54bc <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2d7e:	85ca                	mv	a1,s2
    2d80:	00004517          	auipc	a0,0x4
    2d84:	f7850513          	addi	a0,a0,-136 # 6cf8 <malloc+0x1358>
    2d88:	365020ef          	jal	58ec <printf>
    exit(1);
    2d8c:	4505                	li	a0,1
    2d8e:	72e020ef          	jal	54bc <exit>
    printf("%s: subdir mkdir dd/dd failed\n", s);
    2d92:	85ca                	mv	a1,s2
    2d94:	00004517          	auipc	a0,0x4
    2d98:	f9c50513          	addi	a0,a0,-100 # 6d30 <malloc+0x1390>
    2d9c:	351020ef          	jal	58ec <printf>
    exit(1);
    2da0:	4505                	li	a0,1
    2da2:	71a020ef          	jal	54bc <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2da6:	85ca                	mv	a1,s2
    2da8:	00004517          	auipc	a0,0x4
    2dac:	fb850513          	addi	a0,a0,-72 # 6d60 <malloc+0x13c0>
    2db0:	33d020ef          	jal	58ec <printf>
    exit(1);
    2db4:	4505                	li	a0,1
    2db6:	706020ef          	jal	54bc <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2dba:	85ca                	mv	a1,s2
    2dbc:	00004517          	auipc	a0,0x4
    2dc0:	fdc50513          	addi	a0,a0,-36 # 6d98 <malloc+0x13f8>
    2dc4:	329020ef          	jal	58ec <printf>
    exit(1);
    2dc8:	4505                	li	a0,1
    2dca:	6f2020ef          	jal	54bc <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2dce:	85ca                	mv	a1,s2
    2dd0:	00004517          	auipc	a0,0x4
    2dd4:	fe850513          	addi	a0,a0,-24 # 6db8 <malloc+0x1418>
    2dd8:	315020ef          	jal	58ec <printf>
    exit(1);
    2ddc:	4505                	li	a0,1
    2dde:	6de020ef          	jal	54bc <exit>
    printf("%s: link dd/dd/ff dd/dd/ffff failed\n", s);
    2de2:	85ca                	mv	a1,s2
    2de4:	00004517          	auipc	a0,0x4
    2de8:	00450513          	addi	a0,a0,4 # 6de8 <malloc+0x1448>
    2dec:	301020ef          	jal	58ec <printf>
    exit(1);
    2df0:	4505                	li	a0,1
    2df2:	6ca020ef          	jal	54bc <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2df6:	85ca                	mv	a1,s2
    2df8:	00004517          	auipc	a0,0x4
    2dfc:	01850513          	addi	a0,a0,24 # 6e10 <malloc+0x1470>
    2e00:	2ed020ef          	jal	58ec <printf>
    exit(1);
    2e04:	4505                	li	a0,1
    2e06:	6b6020ef          	jal	54bc <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2e0a:	85ca                	mv	a1,s2
    2e0c:	00004517          	auipc	a0,0x4
    2e10:	02450513          	addi	a0,a0,36 # 6e30 <malloc+0x1490>
    2e14:	2d9020ef          	jal	58ec <printf>
    exit(1);
    2e18:	4505                	li	a0,1
    2e1a:	6a2020ef          	jal	54bc <exit>
    printf("%s: chdir dd failed\n", s);
    2e1e:	85ca                	mv	a1,s2
    2e20:	00004517          	auipc	a0,0x4
    2e24:	03850513          	addi	a0,a0,56 # 6e58 <malloc+0x14b8>
    2e28:	2c5020ef          	jal	58ec <printf>
    exit(1);
    2e2c:	4505                	li	a0,1
    2e2e:	68e020ef          	jal	54bc <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2e32:	85ca                	mv	a1,s2
    2e34:	00004517          	auipc	a0,0x4
    2e38:	04c50513          	addi	a0,a0,76 # 6e80 <malloc+0x14e0>
    2e3c:	2b1020ef          	jal	58ec <printf>
    exit(1);
    2e40:	4505                	li	a0,1
    2e42:	67a020ef          	jal	54bc <exit>
    printf("%s: chdir dd/../../../dd failed\n", s);
    2e46:	85ca                	mv	a1,s2
    2e48:	00004517          	auipc	a0,0x4
    2e4c:	06850513          	addi	a0,a0,104 # 6eb0 <malloc+0x1510>
    2e50:	29d020ef          	jal	58ec <printf>
    exit(1);
    2e54:	4505                	li	a0,1
    2e56:	666020ef          	jal	54bc <exit>
    printf("%s: chdir ./.. failed\n", s);
    2e5a:	85ca                	mv	a1,s2
    2e5c:	00004517          	auipc	a0,0x4
    2e60:	08450513          	addi	a0,a0,132 # 6ee0 <malloc+0x1540>
    2e64:	289020ef          	jal	58ec <printf>
    exit(1);
    2e68:	4505                	li	a0,1
    2e6a:	652020ef          	jal	54bc <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2e6e:	85ca                	mv	a1,s2
    2e70:	00004517          	auipc	a0,0x4
    2e74:	08850513          	addi	a0,a0,136 # 6ef8 <malloc+0x1558>
    2e78:	275020ef          	jal	58ec <printf>
    exit(1);
    2e7c:	4505                	li	a0,1
    2e7e:	63e020ef          	jal	54bc <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2e82:	85ca                	mv	a1,s2
    2e84:	00004517          	auipc	a0,0x4
    2e88:	09450513          	addi	a0,a0,148 # 6f18 <malloc+0x1578>
    2e8c:	261020ef          	jal	58ec <printf>
    exit(1);
    2e90:	4505                	li	a0,1
    2e92:	62a020ef          	jal	54bc <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    2e96:	85ca                	mv	a1,s2
    2e98:	00004517          	auipc	a0,0x4
    2e9c:	0a050513          	addi	a0,a0,160 # 6f38 <malloc+0x1598>
    2ea0:	24d020ef          	jal	58ec <printf>
    exit(1);
    2ea4:	4505                	li	a0,1
    2ea6:	616020ef          	jal	54bc <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    2eaa:	85ca                	mv	a1,s2
    2eac:	00004517          	auipc	a0,0x4
    2eb0:	0cc50513          	addi	a0,a0,204 # 6f78 <malloc+0x15d8>
    2eb4:	239020ef          	jal	58ec <printf>
    exit(1);
    2eb8:	4505                	li	a0,1
    2eba:	602020ef          	jal	54bc <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    2ebe:	85ca                	mv	a1,s2
    2ec0:	00004517          	auipc	a0,0x4
    2ec4:	0e850513          	addi	a0,a0,232 # 6fa8 <malloc+0x1608>
    2ec8:	225020ef          	jal	58ec <printf>
    exit(1);
    2ecc:	4505                	li	a0,1
    2ece:	5ee020ef          	jal	54bc <exit>
    printf("%s: create dd succeeded!\n", s);
    2ed2:	85ca                	mv	a1,s2
    2ed4:	00004517          	auipc	a0,0x4
    2ed8:	0f450513          	addi	a0,a0,244 # 6fc8 <malloc+0x1628>
    2edc:	211020ef          	jal	58ec <printf>
    exit(1);
    2ee0:	4505                	li	a0,1
    2ee2:	5da020ef          	jal	54bc <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    2ee6:	85ca                	mv	a1,s2
    2ee8:	00004517          	auipc	a0,0x4
    2eec:	10050513          	addi	a0,a0,256 # 6fe8 <malloc+0x1648>
    2ef0:	1fd020ef          	jal	58ec <printf>
    exit(1);
    2ef4:	4505                	li	a0,1
    2ef6:	5c6020ef          	jal	54bc <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    2efa:	85ca                	mv	a1,s2
    2efc:	00004517          	auipc	a0,0x4
    2f00:	10c50513          	addi	a0,a0,268 # 7008 <malloc+0x1668>
    2f04:	1e9020ef          	jal	58ec <printf>
    exit(1);
    2f08:	4505                	li	a0,1
    2f0a:	5b2020ef          	jal	54bc <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    2f0e:	85ca                	mv	a1,s2
    2f10:	00004517          	auipc	a0,0x4
    2f14:	12850513          	addi	a0,a0,296 # 7038 <malloc+0x1698>
    2f18:	1d5020ef          	jal	58ec <printf>
    exit(1);
    2f1c:	4505                	li	a0,1
    2f1e:	59e020ef          	jal	54bc <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    2f22:	85ca                	mv	a1,s2
    2f24:	00004517          	auipc	a0,0x4
    2f28:	13c50513          	addi	a0,a0,316 # 7060 <malloc+0x16c0>
    2f2c:	1c1020ef          	jal	58ec <printf>
    exit(1);
    2f30:	4505                	li	a0,1
    2f32:	58a020ef          	jal	54bc <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    2f36:	85ca                	mv	a1,s2
    2f38:	00004517          	auipc	a0,0x4
    2f3c:	15050513          	addi	a0,a0,336 # 7088 <malloc+0x16e8>
    2f40:	1ad020ef          	jal	58ec <printf>
    exit(1);
    2f44:	4505                	li	a0,1
    2f46:	576020ef          	jal	54bc <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    2f4a:	85ca                	mv	a1,s2
    2f4c:	00004517          	auipc	a0,0x4
    2f50:	16450513          	addi	a0,a0,356 # 70b0 <malloc+0x1710>
    2f54:	199020ef          	jal	58ec <printf>
    exit(1);
    2f58:	4505                	li	a0,1
    2f5a:	562020ef          	jal	54bc <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    2f5e:	85ca                	mv	a1,s2
    2f60:	00004517          	auipc	a0,0x4
    2f64:	17050513          	addi	a0,a0,368 # 70d0 <malloc+0x1730>
    2f68:	185020ef          	jal	58ec <printf>
    exit(1);
    2f6c:	4505                	li	a0,1
    2f6e:	54e020ef          	jal	54bc <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    2f72:	85ca                	mv	a1,s2
    2f74:	00004517          	auipc	a0,0x4
    2f78:	17c50513          	addi	a0,a0,380 # 70f0 <malloc+0x1750>
    2f7c:	171020ef          	jal	58ec <printf>
    exit(1);
    2f80:	4505                	li	a0,1
    2f82:	53a020ef          	jal	54bc <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    2f86:	85ca                	mv	a1,s2
    2f88:	00004517          	auipc	a0,0x4
    2f8c:	19050513          	addi	a0,a0,400 # 7118 <malloc+0x1778>
    2f90:	15d020ef          	jal	58ec <printf>
    exit(1);
    2f94:	4505                	li	a0,1
    2f96:	526020ef          	jal	54bc <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    2f9a:	85ca                	mv	a1,s2
    2f9c:	00004517          	auipc	a0,0x4
    2fa0:	19c50513          	addi	a0,a0,412 # 7138 <malloc+0x1798>
    2fa4:	149020ef          	jal	58ec <printf>
    exit(1);
    2fa8:	4505                	li	a0,1
    2faa:	512020ef          	jal	54bc <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    2fae:	85ca                	mv	a1,s2
    2fb0:	00004517          	auipc	a0,0x4
    2fb4:	1a850513          	addi	a0,a0,424 # 7158 <malloc+0x17b8>
    2fb8:	135020ef          	jal	58ec <printf>
    exit(1);
    2fbc:	4505                	li	a0,1
    2fbe:	4fe020ef          	jal	54bc <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    2fc2:	85ca                	mv	a1,s2
    2fc4:	00004517          	auipc	a0,0x4
    2fc8:	1bc50513          	addi	a0,a0,444 # 7180 <malloc+0x17e0>
    2fcc:	121020ef          	jal	58ec <printf>
    exit(1);
    2fd0:	4505                	li	a0,1
    2fd2:	4ea020ef          	jal	54bc <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2fd6:	85ca                	mv	a1,s2
    2fd8:	00004517          	auipc	a0,0x4
    2fdc:	e3850513          	addi	a0,a0,-456 # 6e10 <malloc+0x1470>
    2fe0:	10d020ef          	jal	58ec <printf>
    exit(1);
    2fe4:	4505                	li	a0,1
    2fe6:	4d6020ef          	jal	54bc <exit>
    printf("%s: unlink dd/ff failed\n", s);
    2fea:	85ca                	mv	a1,s2
    2fec:	00004517          	auipc	a0,0x4
    2ff0:	1b450513          	addi	a0,a0,436 # 71a0 <malloc+0x1800>
    2ff4:	0f9020ef          	jal	58ec <printf>
    exit(1);
    2ff8:	4505                	li	a0,1
    2ffa:	4c2020ef          	jal	54bc <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    2ffe:	85ca                	mv	a1,s2
    3000:	00004517          	auipc	a0,0x4
    3004:	1c050513          	addi	a0,a0,448 # 71c0 <malloc+0x1820>
    3008:	0e5020ef          	jal	58ec <printf>
    exit(1);
    300c:	4505                	li	a0,1
    300e:	4ae020ef          	jal	54bc <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3012:	85ca                	mv	a1,s2
    3014:	00004517          	auipc	a0,0x4
    3018:	1dc50513          	addi	a0,a0,476 # 71f0 <malloc+0x1850>
    301c:	0d1020ef          	jal	58ec <printf>
    exit(1);
    3020:	4505                	li	a0,1
    3022:	49a020ef          	jal	54bc <exit>
    printf("%s: unlink dd failed\n", s);
    3026:	85ca                	mv	a1,s2
    3028:	00004517          	auipc	a0,0x4
    302c:	1e850513          	addi	a0,a0,488 # 7210 <malloc+0x1870>
    3030:	0bd020ef          	jal	58ec <printf>
    exit(1);
    3034:	4505                	li	a0,1
    3036:	486020ef          	jal	54bc <exit>

000000000000303a <rmdot>:
{
    303a:	1101                	addi	sp,sp,-32
    303c:	ec06                	sd	ra,24(sp)
    303e:	e822                	sd	s0,16(sp)
    3040:	e426                	sd	s1,8(sp)
    3042:	1000                	addi	s0,sp,32
    3044:	84aa                	mv	s1,a0
  if (mkdir("dots") != 0) {
    3046:	00004517          	auipc	a0,0x4
    304a:	1e250513          	addi	a0,a0,482 # 7228 <malloc+0x1888>
    304e:	4d6020ef          	jal	5524 <mkdir>
    3052:	e53d                	bnez	a0,30c0 <rmdot+0x86>
  if (chdir("dots") != 0) {
    3054:	00004517          	auipc	a0,0x4
    3058:	1d450513          	addi	a0,a0,468 # 7228 <malloc+0x1888>
    305c:	4d0020ef          	jal	552c <chdir>
    3060:	e935                	bnez	a0,30d4 <rmdot+0x9a>
  if (unlink(".") == 0) {
    3062:	00003517          	auipc	a0,0x3
    3066:	15e50513          	addi	a0,a0,350 # 61c0 <malloc+0x820>
    306a:	4a2020ef          	jal	550c <unlink>
    306e:	cd2d                	beqz	a0,30e8 <rmdot+0xae>
  if (unlink("..") == 0) {
    3070:	00004517          	auipc	a0,0x4
    3074:	c0850513          	addi	a0,a0,-1016 # 6c78 <malloc+0x12d8>
    3078:	494020ef          	jal	550c <unlink>
    307c:	c141                	beqz	a0,30fc <rmdot+0xc2>
  if (chdir("/") != 0) {
    307e:	00004517          	auipc	a0,0x4
    3082:	ba250513          	addi	a0,a0,-1118 # 6c20 <malloc+0x1280>
    3086:	4a6020ef          	jal	552c <chdir>
    308a:	e159                	bnez	a0,3110 <rmdot+0xd6>
  if (unlink("dots/.") == 0) {
    308c:	00004517          	auipc	a0,0x4
    3090:	20450513          	addi	a0,a0,516 # 7290 <malloc+0x18f0>
    3094:	478020ef          	jal	550c <unlink>
    3098:	c551                	beqz	a0,3124 <rmdot+0xea>
  if (unlink("dots/..") == 0) {
    309a:	00004517          	auipc	a0,0x4
    309e:	21e50513          	addi	a0,a0,542 # 72b8 <malloc+0x1918>
    30a2:	46a020ef          	jal	550c <unlink>
    30a6:	c949                	beqz	a0,3138 <rmdot+0xfe>
  if (unlink("dots") != 0) {
    30a8:	00004517          	auipc	a0,0x4
    30ac:	18050513          	addi	a0,a0,384 # 7228 <malloc+0x1888>
    30b0:	45c020ef          	jal	550c <unlink>
    30b4:	ed41                	bnez	a0,314c <rmdot+0x112>
}
    30b6:	60e2                	ld	ra,24(sp)
    30b8:	6442                	ld	s0,16(sp)
    30ba:	64a2                	ld	s1,8(sp)
    30bc:	6105                	addi	sp,sp,32
    30be:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    30c0:	85a6                	mv	a1,s1
    30c2:	00004517          	auipc	a0,0x4
    30c6:	16e50513          	addi	a0,a0,366 # 7230 <malloc+0x1890>
    30ca:	023020ef          	jal	58ec <printf>
    exit(1);
    30ce:	4505                	li	a0,1
    30d0:	3ec020ef          	jal	54bc <exit>
    printf("%s: chdir dots failed\n", s);
    30d4:	85a6                	mv	a1,s1
    30d6:	00004517          	auipc	a0,0x4
    30da:	17250513          	addi	a0,a0,370 # 7248 <malloc+0x18a8>
    30de:	00f020ef          	jal	58ec <printf>
    exit(1);
    30e2:	4505                	li	a0,1
    30e4:	3d8020ef          	jal	54bc <exit>
    printf("%s: rm . worked!\n", s);
    30e8:	85a6                	mv	a1,s1
    30ea:	00004517          	auipc	a0,0x4
    30ee:	17650513          	addi	a0,a0,374 # 7260 <malloc+0x18c0>
    30f2:	7fa020ef          	jal	58ec <printf>
    exit(1);
    30f6:	4505                	li	a0,1
    30f8:	3c4020ef          	jal	54bc <exit>
    printf("%s: rm .. worked!\n", s);
    30fc:	85a6                	mv	a1,s1
    30fe:	00004517          	auipc	a0,0x4
    3102:	17a50513          	addi	a0,a0,378 # 7278 <malloc+0x18d8>
    3106:	7e6020ef          	jal	58ec <printf>
    exit(1);
    310a:	4505                	li	a0,1
    310c:	3b0020ef          	jal	54bc <exit>
    printf("%s: chdir / failed\n", s);
    3110:	85a6                	mv	a1,s1
    3112:	00004517          	auipc	a0,0x4
    3116:	b1650513          	addi	a0,a0,-1258 # 6c28 <malloc+0x1288>
    311a:	7d2020ef          	jal	58ec <printf>
    exit(1);
    311e:	4505                	li	a0,1
    3120:	39c020ef          	jal	54bc <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3124:	85a6                	mv	a1,s1
    3126:	00004517          	auipc	a0,0x4
    312a:	17250513          	addi	a0,a0,370 # 7298 <malloc+0x18f8>
    312e:	7be020ef          	jal	58ec <printf>
    exit(1);
    3132:	4505                	li	a0,1
    3134:	388020ef          	jal	54bc <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3138:	85a6                	mv	a1,s1
    313a:	00004517          	auipc	a0,0x4
    313e:	18650513          	addi	a0,a0,390 # 72c0 <malloc+0x1920>
    3142:	7aa020ef          	jal	58ec <printf>
    exit(1);
    3146:	4505                	li	a0,1
    3148:	374020ef          	jal	54bc <exit>
    printf("%s: unlink dots failed!\n", s);
    314c:	85a6                	mv	a1,s1
    314e:	00004517          	auipc	a0,0x4
    3152:	19250513          	addi	a0,a0,402 # 72e0 <malloc+0x1940>
    3156:	796020ef          	jal	58ec <printf>
    exit(1);
    315a:	4505                	li	a0,1
    315c:	360020ef          	jal	54bc <exit>

0000000000003160 <dirfile>:
{
    3160:	1101                	addi	sp,sp,-32
    3162:	ec06                	sd	ra,24(sp)
    3164:	e822                	sd	s0,16(sp)
    3166:	e426                	sd	s1,8(sp)
    3168:	e04a                	sd	s2,0(sp)
    316a:	1000                	addi	s0,sp,32
    316c:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    316e:	20000593          	li	a1,512
    3172:	00004517          	auipc	a0,0x4
    3176:	18e50513          	addi	a0,a0,398 # 7300 <malloc+0x1960>
    317a:	382020ef          	jal	54fc <open>
  if (fd < 0) {
    317e:	0c054563          	bltz	a0,3248 <dirfile+0xe8>
  close(fd);
    3182:	362020ef          	jal	54e4 <close>
  if (chdir("dirfile") == 0) {
    3186:	00004517          	auipc	a0,0x4
    318a:	17a50513          	addi	a0,a0,378 # 7300 <malloc+0x1960>
    318e:	39e020ef          	jal	552c <chdir>
    3192:	c569                	beqz	a0,325c <dirfile+0xfc>
  fd = open("dirfile/xx", 0);
    3194:	4581                	li	a1,0
    3196:	00004517          	auipc	a0,0x4
    319a:	1b250513          	addi	a0,a0,434 # 7348 <malloc+0x19a8>
    319e:	35e020ef          	jal	54fc <open>
  if (fd >= 0) {
    31a2:	0c055763          	bgez	a0,3270 <dirfile+0x110>
  fd = open("dirfile/xx", O_CREATE);
    31a6:	20000593          	li	a1,512
    31aa:	00004517          	auipc	a0,0x4
    31ae:	19e50513          	addi	a0,a0,414 # 7348 <malloc+0x19a8>
    31b2:	34a020ef          	jal	54fc <open>
  if (fd >= 0) {
    31b6:	0c055763          	bgez	a0,3284 <dirfile+0x124>
  if (mkdir("dirfile/xx") == 0) {
    31ba:	00004517          	auipc	a0,0x4
    31be:	18e50513          	addi	a0,a0,398 # 7348 <malloc+0x19a8>
    31c2:	362020ef          	jal	5524 <mkdir>
    31c6:	0c050963          	beqz	a0,3298 <dirfile+0x138>
  if (unlink("dirfile/xx") == 0) {
    31ca:	00004517          	auipc	a0,0x4
    31ce:	17e50513          	addi	a0,a0,382 # 7348 <malloc+0x19a8>
    31d2:	33a020ef          	jal	550c <unlink>
    31d6:	0c050b63          	beqz	a0,32ac <dirfile+0x14c>
  if (link("README", "dirfile/xx") == 0) {
    31da:	00004597          	auipc	a1,0x4
    31de:	16e58593          	addi	a1,a1,366 # 7348 <malloc+0x19a8>
    31e2:	00003517          	auipc	a0,0x3
    31e6:	ace50513          	addi	a0,a0,-1330 # 5cb0 <malloc+0x310>
    31ea:	332020ef          	jal	551c <link>
    31ee:	0c050963          	beqz	a0,32c0 <dirfile+0x160>
  if (unlink("dirfile") != 0) {
    31f2:	00004517          	auipc	a0,0x4
    31f6:	10e50513          	addi	a0,a0,270 # 7300 <malloc+0x1960>
    31fa:	312020ef          	jal	550c <unlink>
    31fe:	0c051b63          	bnez	a0,32d4 <dirfile+0x174>
  fd = open(".", O_RDWR);
    3202:	4589                	li	a1,2
    3204:	00003517          	auipc	a0,0x3
    3208:	fbc50513          	addi	a0,a0,-68 # 61c0 <malloc+0x820>
    320c:	2f0020ef          	jal	54fc <open>
  if (fd >= 0) {
    3210:	0c055c63          	bgez	a0,32e8 <dirfile+0x188>
  fd = open(".", 0);
    3214:	4581                	li	a1,0
    3216:	00003517          	auipc	a0,0x3
    321a:	faa50513          	addi	a0,a0,-86 # 61c0 <malloc+0x820>
    321e:	2de020ef          	jal	54fc <open>
    3222:	84aa                	mv	s1,a0
  if (write(fd, "x", 1) > 0) {
    3224:	4605                	li	a2,1
    3226:	00003597          	auipc	a1,0x3
    322a:	92258593          	addi	a1,a1,-1758 # 5b48 <malloc+0x1a8>
    322e:	2ae020ef          	jal	54dc <write>
    3232:	0ca04563          	bgtz	a0,32fc <dirfile+0x19c>
  close(fd);
    3236:	8526                	mv	a0,s1
    3238:	2ac020ef          	jal	54e4 <close>
}
    323c:	60e2                	ld	ra,24(sp)
    323e:	6442                	ld	s0,16(sp)
    3240:	64a2                	ld	s1,8(sp)
    3242:	6902                	ld	s2,0(sp)
    3244:	6105                	addi	sp,sp,32
    3246:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3248:	85ca                	mv	a1,s2
    324a:	00004517          	auipc	a0,0x4
    324e:	0be50513          	addi	a0,a0,190 # 7308 <malloc+0x1968>
    3252:	69a020ef          	jal	58ec <printf>
    exit(1);
    3256:	4505                	li	a0,1
    3258:	264020ef          	jal	54bc <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    325c:	85ca                	mv	a1,s2
    325e:	00004517          	auipc	a0,0x4
    3262:	0ca50513          	addi	a0,a0,202 # 7328 <malloc+0x1988>
    3266:	686020ef          	jal	58ec <printf>
    exit(1);
    326a:	4505                	li	a0,1
    326c:	250020ef          	jal	54bc <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3270:	85ca                	mv	a1,s2
    3272:	00004517          	auipc	a0,0x4
    3276:	0e650513          	addi	a0,a0,230 # 7358 <malloc+0x19b8>
    327a:	672020ef          	jal	58ec <printf>
    exit(1);
    327e:	4505                	li	a0,1
    3280:	23c020ef          	jal	54bc <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3284:	85ca                	mv	a1,s2
    3286:	00004517          	auipc	a0,0x4
    328a:	0d250513          	addi	a0,a0,210 # 7358 <malloc+0x19b8>
    328e:	65e020ef          	jal	58ec <printf>
    exit(1);
    3292:	4505                	li	a0,1
    3294:	228020ef          	jal	54bc <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3298:	85ca                	mv	a1,s2
    329a:	00004517          	auipc	a0,0x4
    329e:	0e650513          	addi	a0,a0,230 # 7380 <malloc+0x19e0>
    32a2:	64a020ef          	jal	58ec <printf>
    exit(1);
    32a6:	4505                	li	a0,1
    32a8:	214020ef          	jal	54bc <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    32ac:	85ca                	mv	a1,s2
    32ae:	00004517          	auipc	a0,0x4
    32b2:	0fa50513          	addi	a0,a0,250 # 73a8 <malloc+0x1a08>
    32b6:	636020ef          	jal	58ec <printf>
    exit(1);
    32ba:	4505                	li	a0,1
    32bc:	200020ef          	jal	54bc <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    32c0:	85ca                	mv	a1,s2
    32c2:	00004517          	auipc	a0,0x4
    32c6:	10e50513          	addi	a0,a0,270 # 73d0 <malloc+0x1a30>
    32ca:	622020ef          	jal	58ec <printf>
    exit(1);
    32ce:	4505                	li	a0,1
    32d0:	1ec020ef          	jal	54bc <exit>
    printf("%s: unlink dirfile failed!\n", s);
    32d4:	85ca                	mv	a1,s2
    32d6:	00004517          	auipc	a0,0x4
    32da:	12250513          	addi	a0,a0,290 # 73f8 <malloc+0x1a58>
    32de:	60e020ef          	jal	58ec <printf>
    exit(1);
    32e2:	4505                	li	a0,1
    32e4:	1d8020ef          	jal	54bc <exit>
    printf("%s: open . for writing succeeded!\n", s);
    32e8:	85ca                	mv	a1,s2
    32ea:	00004517          	auipc	a0,0x4
    32ee:	12e50513          	addi	a0,a0,302 # 7418 <malloc+0x1a78>
    32f2:	5fa020ef          	jal	58ec <printf>
    exit(1);
    32f6:	4505                	li	a0,1
    32f8:	1c4020ef          	jal	54bc <exit>
    printf("%s: write . succeeded!\n", s);
    32fc:	85ca                	mv	a1,s2
    32fe:	00004517          	auipc	a0,0x4
    3302:	14250513          	addi	a0,a0,322 # 7440 <malloc+0x1aa0>
    3306:	5e6020ef          	jal	58ec <printf>
    exit(1);
    330a:	4505                	li	a0,1
    330c:	1b0020ef          	jal	54bc <exit>

0000000000003310 <iref>:
{
    3310:	7139                	addi	sp,sp,-64
    3312:	fc06                	sd	ra,56(sp)
    3314:	f822                	sd	s0,48(sp)
    3316:	f426                	sd	s1,40(sp)
    3318:	f04a                	sd	s2,32(sp)
    331a:	ec4e                	sd	s3,24(sp)
    331c:	e852                	sd	s4,16(sp)
    331e:	e456                	sd	s5,8(sp)
    3320:	e05a                	sd	s6,0(sp)
    3322:	0080                	addi	s0,sp,64
    3324:	8b2a                	mv	s6,a0
    3326:	03300913          	li	s2,51
    if (mkdir("irefd") != 0) {
    332a:	00004a17          	auipc	s4,0x4
    332e:	12ea0a13          	addi	s4,s4,302 # 7458 <malloc+0x1ab8>
    mkdir("");
    3332:	00004497          	auipc	s1,0x4
    3336:	c2e48493          	addi	s1,s1,-978 # 6f60 <malloc+0x15c0>
    link("README", "");
    333a:	00003a97          	auipc	s5,0x3
    333e:	976a8a93          	addi	s5,s5,-1674 # 5cb0 <malloc+0x310>
    fd = open("xx", O_CREATE);
    3342:	00004997          	auipc	s3,0x4
    3346:	00e98993          	addi	s3,s3,14 # 7350 <malloc+0x19b0>
    334a:	a835                	j	3386 <iref+0x76>
      printf("%s: mkdir irefd failed\n", s);
    334c:	85da                	mv	a1,s6
    334e:	00004517          	auipc	a0,0x4
    3352:	11250513          	addi	a0,a0,274 # 7460 <malloc+0x1ac0>
    3356:	596020ef          	jal	58ec <printf>
      exit(1);
    335a:	4505                	li	a0,1
    335c:	160020ef          	jal	54bc <exit>
      printf("%s: chdir irefd failed\n", s);
    3360:	85da                	mv	a1,s6
    3362:	00004517          	auipc	a0,0x4
    3366:	11650513          	addi	a0,a0,278 # 7478 <malloc+0x1ad8>
    336a:	582020ef          	jal	58ec <printf>
      exit(1);
    336e:	4505                	li	a0,1
    3370:	14c020ef          	jal	54bc <exit>
      close(fd);
    3374:	170020ef          	jal	54e4 <close>
    3378:	a82d                	j	33b2 <iref+0xa2>
    unlink("xx");
    337a:	854e                	mv	a0,s3
    337c:	190020ef          	jal	550c <unlink>
  for (i = 0; i < NINODE + 1; i++) {
    3380:	397d                	addiw	s2,s2,-1
    3382:	04090263          	beqz	s2,33c6 <iref+0xb6>
    if (mkdir("irefd") != 0) {
    3386:	8552                	mv	a0,s4
    3388:	19c020ef          	jal	5524 <mkdir>
    338c:	f161                	bnez	a0,334c <iref+0x3c>
    if (chdir("irefd") != 0) {
    338e:	8552                	mv	a0,s4
    3390:	19c020ef          	jal	552c <chdir>
    3394:	f571                	bnez	a0,3360 <iref+0x50>
    mkdir("");
    3396:	8526                	mv	a0,s1
    3398:	18c020ef          	jal	5524 <mkdir>
    link("README", "");
    339c:	85a6                	mv	a1,s1
    339e:	8556                	mv	a0,s5
    33a0:	17c020ef          	jal	551c <link>
    fd = open("", O_CREATE);
    33a4:	20000593          	li	a1,512
    33a8:	8526                	mv	a0,s1
    33aa:	152020ef          	jal	54fc <open>
    if (fd >= 0)
    33ae:	fc0553e3          	bgez	a0,3374 <iref+0x64>
    fd = open("xx", O_CREATE);
    33b2:	20000593          	li	a1,512
    33b6:	854e                	mv	a0,s3
    33b8:	144020ef          	jal	54fc <open>
    if (fd >= 0)
    33bc:	fa054fe3          	bltz	a0,337a <iref+0x6a>
      close(fd);
    33c0:	124020ef          	jal	54e4 <close>
    33c4:	bf5d                	j	337a <iref+0x6a>
    33c6:	03300493          	li	s1,51
    chdir("..");
    33ca:	00004997          	auipc	s3,0x4
    33ce:	8ae98993          	addi	s3,s3,-1874 # 6c78 <malloc+0x12d8>
    unlink("irefd");
    33d2:	00004917          	auipc	s2,0x4
    33d6:	08690913          	addi	s2,s2,134 # 7458 <malloc+0x1ab8>
    chdir("..");
    33da:	854e                	mv	a0,s3
    33dc:	150020ef          	jal	552c <chdir>
    unlink("irefd");
    33e0:	854a                	mv	a0,s2
    33e2:	12a020ef          	jal	550c <unlink>
  for (i = 0; i < NINODE + 1; i++) {
    33e6:	34fd                	addiw	s1,s1,-1
    33e8:	f8ed                	bnez	s1,33da <iref+0xca>
  chdir("/");
    33ea:	00004517          	auipc	a0,0x4
    33ee:	83650513          	addi	a0,a0,-1994 # 6c20 <malloc+0x1280>
    33f2:	13a020ef          	jal	552c <chdir>
}
    33f6:	70e2                	ld	ra,56(sp)
    33f8:	7442                	ld	s0,48(sp)
    33fa:	74a2                	ld	s1,40(sp)
    33fc:	7902                	ld	s2,32(sp)
    33fe:	69e2                	ld	s3,24(sp)
    3400:	6a42                	ld	s4,16(sp)
    3402:	6aa2                	ld	s5,8(sp)
    3404:	6b02                	ld	s6,0(sp)
    3406:	6121                	addi	sp,sp,64
    3408:	8082                	ret

000000000000340a <unlinkcwd>:
{
    340a:	1101                	addi	sp,sp,-32
    340c:	ec06                	sd	ra,24(sp)
    340e:	e822                	sd	s0,16(sp)
    3410:	e426                	sd	s1,8(sp)
    3412:	1000                	addi	s0,sp,32
    3414:	84aa                	mv	s1,a0
  if (mkdir("/a") < 0) {
    3416:	00004517          	auipc	a0,0x4
    341a:	07a50513          	addi	a0,a0,122 # 7490 <malloc+0x1af0>
    341e:	106020ef          	jal	5524 <mkdir>
    3422:	06054a63          	bltz	a0,3496 <unlinkcwd+0x8c>
  if (mkdir("/a/b") < 0) {
    3426:	00004517          	auipc	a0,0x4
    342a:	08a50513          	addi	a0,a0,138 # 74b0 <malloc+0x1b10>
    342e:	0f6020ef          	jal	5524 <mkdir>
    3432:	06054c63          	bltz	a0,34aa <unlinkcwd+0xa0>
  if (chdir("/a/b") < 0) {
    3436:	00004517          	auipc	a0,0x4
    343a:	07a50513          	addi	a0,a0,122 # 74b0 <malloc+0x1b10>
    343e:	0ee020ef          	jal	552c <chdir>
    3442:	06054e63          	bltz	a0,34be <unlinkcwd+0xb4>
  if (unlink("/a/b") < 0) {
    3446:	00004517          	auipc	a0,0x4
    344a:	06a50513          	addi	a0,a0,106 # 74b0 <malloc+0x1b10>
    344e:	0be020ef          	jal	550c <unlink>
    3452:	08054063          	bltz	a0,34d2 <unlinkcwd+0xc8>
  if (unlink("/a") < 0) {
    3456:	00004517          	auipc	a0,0x4
    345a:	03a50513          	addi	a0,a0,58 # 7490 <malloc+0x1af0>
    345e:	0ae020ef          	jal	550c <unlink>
    3462:	08054263          	bltz	a0,34e6 <unlinkcwd+0xdc>
  if (open("../", O_RDONLY) > 0) {
    3466:	4581                	li	a1,0
    3468:	00004517          	auipc	a0,0x4
    346c:	0b050513          	addi	a0,a0,176 # 7518 <malloc+0x1b78>
    3470:	08c020ef          	jal	54fc <open>
    3474:	08a04363          	bgtz	a0,34fa <unlinkcwd+0xf0>
  if (open("../c", O_CREATE) > 0) {
    3478:	20000593          	li	a1,512
    347c:	00004517          	auipc	a0,0x4
    3480:	0cc50513          	addi	a0,a0,204 # 7548 <malloc+0x1ba8>
    3484:	078020ef          	jal	54fc <open>
    3488:	08a04163          	bgtz	a0,350a <unlinkcwd+0x100>
}
    348c:	60e2                	ld	ra,24(sp)
    348e:	6442                	ld	s0,16(sp)
    3490:	64a2                	ld	s1,8(sp)
    3492:	6105                	addi	sp,sp,32
    3494:	8082                	ret
    printf("%s: mkdir /a failed\n", s);
    3496:	85a6                	mv	a1,s1
    3498:	00004517          	auipc	a0,0x4
    349c:	00050513          	mv	a0,a0
    34a0:	44c020ef          	jal	58ec <printf>
    exit(1);
    34a4:	4505                	li	a0,1
    34a6:	016020ef          	jal	54bc <exit>
    printf("%s: mkdir /a/b failed\n", s);
    34aa:	85a6                	mv	a1,s1
    34ac:	00004517          	auipc	a0,0x4
    34b0:	00c50513          	addi	a0,a0,12 # 74b8 <malloc+0x1b18>
    34b4:	438020ef          	jal	58ec <printf>
    exit(1);
    34b8:	4505                	li	a0,1
    34ba:	002020ef          	jal	54bc <exit>
    printf("%s: chdir failed\n", s);
    34be:	85a6                	mv	a1,s1
    34c0:	00004517          	auipc	a0,0x4
    34c4:	01050513          	addi	a0,a0,16 # 74d0 <malloc+0x1b30>
    34c8:	424020ef          	jal	58ec <printf>
    exit(1);
    34cc:	4505                	li	a0,1
    34ce:	7ef010ef          	jal	54bc <exit>
    printf("%s: unlink /a/b failed\n", s);
    34d2:	85a6                	mv	a1,s1
    34d4:	00004517          	auipc	a0,0x4
    34d8:	01450513          	addi	a0,a0,20 # 74e8 <malloc+0x1b48>
    34dc:	410020ef          	jal	58ec <printf>
    exit(1);
    34e0:	4505                	li	a0,1
    34e2:	7db010ef          	jal	54bc <exit>
    printf("%s: unlink /a failed\n", s);
    34e6:	85a6                	mv	a1,s1
    34e8:	00004517          	auipc	a0,0x4
    34ec:	01850513          	addi	a0,a0,24 # 7500 <malloc+0x1b60>
    34f0:	3fc020ef          	jal	58ec <printf>
    exit(1);
    34f4:	4505                	li	a0,1
    34f6:	7c7010ef          	jal	54bc <exit>
    printf("%s: open ../ non-existing directory\n", s);
    34fa:	85a6                	mv	a1,s1
    34fc:	00004517          	auipc	a0,0x4
    3500:	02450513          	addi	a0,a0,36 # 7520 <malloc+0x1b80>
    3504:	3e8020ef          	jal	58ec <printf>
    3508:	bf85                	j	3478 <unlinkcwd+0x6e>
    printf("%s: create ../c non-existing file\n", s);
    350a:	85a6                	mv	a1,s1
    350c:	00004517          	auipc	a0,0x4
    3510:	04450513          	addi	a0,a0,68 # 7550 <malloc+0x1bb0>
    3514:	3d8020ef          	jal	58ec <printf>
}
    3518:	bf95                	j	348c <unlinkcwd+0x82>

000000000000351a <openiputtest>:
{
    351a:	7179                	addi	sp,sp,-48
    351c:	f406                	sd	ra,40(sp)
    351e:	f022                	sd	s0,32(sp)
    3520:	ec26                	sd	s1,24(sp)
    3522:	1800                	addi	s0,sp,48
    3524:	84aa                	mv	s1,a0
  if (mkdir("oidir") < 0) {
    3526:	00004517          	auipc	a0,0x4
    352a:	05250513          	addi	a0,a0,82 # 7578 <malloc+0x1bd8>
    352e:	7f7010ef          	jal	5524 <mkdir>
    3532:	02054a63          	bltz	a0,3566 <openiputtest+0x4c>
  pid = fork();
    3536:	77f010ef          	jal	54b4 <fork>
  if (pid < 0) {
    353a:	04054063          	bltz	a0,357a <openiputtest+0x60>
  if (pid == 0) {
    353e:	e939                	bnez	a0,3594 <openiputtest+0x7a>
    int fd = open("oidir", O_RDWR);
    3540:	4589                	li	a1,2
    3542:	00004517          	auipc	a0,0x4
    3546:	03650513          	addi	a0,a0,54 # 7578 <malloc+0x1bd8>
    354a:	7b3010ef          	jal	54fc <open>
    if (fd >= 0) {
    354e:	04054063          	bltz	a0,358e <openiputtest+0x74>
      printf("%s: open directory for write succeeded\n", s);
    3552:	85a6                	mv	a1,s1
    3554:	00004517          	auipc	a0,0x4
    3558:	04450513          	addi	a0,a0,68 # 7598 <malloc+0x1bf8>
    355c:	390020ef          	jal	58ec <printf>
      exit(1);
    3560:	4505                	li	a0,1
    3562:	75b010ef          	jal	54bc <exit>
    printf("%s: mkdir oidir failed\n", s);
    3566:	85a6                	mv	a1,s1
    3568:	00004517          	auipc	a0,0x4
    356c:	01850513          	addi	a0,a0,24 # 7580 <malloc+0x1be0>
    3570:	37c020ef          	jal	58ec <printf>
    exit(1);
    3574:	4505                	li	a0,1
    3576:	747010ef          	jal	54bc <exit>
    printf("%s: fork failed\n", s);
    357a:	85a6                	mv	a1,s1
    357c:	00003517          	auipc	a0,0x3
    3580:	dec50513          	addi	a0,a0,-532 # 6368 <malloc+0x9c8>
    3584:	368020ef          	jal	58ec <printf>
    exit(1);
    3588:	4505                	li	a0,1
    358a:	733010ef          	jal	54bc <exit>
    exit(0);
    358e:	4501                	li	a0,0
    3590:	72d010ef          	jal	54bc <exit>
  pause(1);
    3594:	4505                	li	a0,1
    3596:	7b7010ef          	jal	554c <pause>
  if (unlink("oidir") != 0) {
    359a:	00004517          	auipc	a0,0x4
    359e:	fde50513          	addi	a0,a0,-34 # 7578 <malloc+0x1bd8>
    35a2:	76b010ef          	jal	550c <unlink>
    35a6:	c919                	beqz	a0,35bc <openiputtest+0xa2>
    printf("%s: unlink failed\n", s);
    35a8:	85a6                	mv	a1,s1
    35aa:	00003517          	auipc	a0,0x3
    35ae:	f4650513          	addi	a0,a0,-186 # 64f0 <malloc+0xb50>
    35b2:	33a020ef          	jal	58ec <printf>
    exit(1);
    35b6:	4505                	li	a0,1
    35b8:	705010ef          	jal	54bc <exit>
  wait(&xstatus);
    35bc:	fdc40513          	addi	a0,s0,-36
    35c0:	705010ef          	jal	54c4 <wait>
  exit(xstatus);
    35c4:	fdc42503          	lw	a0,-36(s0)
    35c8:	6f5010ef          	jal	54bc <exit>

00000000000035cc <forkforkfork>:
{
    35cc:	1101                	addi	sp,sp,-32
    35ce:	ec06                	sd	ra,24(sp)
    35d0:	e822                	sd	s0,16(sp)
    35d2:	e426                	sd	s1,8(sp)
    35d4:	1000                	addi	s0,sp,32
    35d6:	84aa                	mv	s1,a0
  unlink("stopforking");
    35d8:	00004517          	auipc	a0,0x4
    35dc:	fe850513          	addi	a0,a0,-24 # 75c0 <malloc+0x1c20>
    35e0:	72d010ef          	jal	550c <unlink>
  int pid = fork();
    35e4:	6d1010ef          	jal	54b4 <fork>
  if (pid < 0) {
    35e8:	02054b63          	bltz	a0,361e <forkforkfork+0x52>
  if (pid == 0) {
    35ec:	c139                	beqz	a0,3632 <forkforkfork+0x66>
  pause(20); // two seconds
    35ee:	4551                	li	a0,20
    35f0:	75d010ef          	jal	554c <pause>
  close(open("stopforking", O_CREATE | O_RDWR));
    35f4:	20200593          	li	a1,514
    35f8:	00004517          	auipc	a0,0x4
    35fc:	fc850513          	addi	a0,a0,-56 # 75c0 <malloc+0x1c20>
    3600:	6fd010ef          	jal	54fc <open>
    3604:	6e1010ef          	jal	54e4 <close>
  wait(0);
    3608:	4501                	li	a0,0
    360a:	6bb010ef          	jal	54c4 <wait>
  pause(10); // one second
    360e:	4529                	li	a0,10
    3610:	73d010ef          	jal	554c <pause>
}
    3614:	60e2                	ld	ra,24(sp)
    3616:	6442                	ld	s0,16(sp)
    3618:	64a2                	ld	s1,8(sp)
    361a:	6105                	addi	sp,sp,32
    361c:	8082                	ret
    printf("%s: fork failed", s);
    361e:	85a6                	mv	a1,s1
    3620:	00003517          	auipc	a0,0x3
    3624:	e8850513          	addi	a0,a0,-376 # 64a8 <malloc+0xb08>
    3628:	2c4020ef          	jal	58ec <printf>
    exit(1);
    362c:	4505                	li	a0,1
    362e:	68f010ef          	jal	54bc <exit>
      int fd = open("stopforking", 0);
    3632:	00004497          	auipc	s1,0x4
    3636:	f8e48493          	addi	s1,s1,-114 # 75c0 <malloc+0x1c20>
    363a:	4581                	li	a1,0
    363c:	8526                	mv	a0,s1
    363e:	6bf010ef          	jal	54fc <open>
      if (fd >= 0) {
    3642:	02055163          	bgez	a0,3664 <forkforkfork+0x98>
      if (fork() < 0) {
    3646:	66f010ef          	jal	54b4 <fork>
    364a:	fe0558e3          	bgez	a0,363a <forkforkfork+0x6e>
        close(open("stopforking", O_CREATE | O_RDWR));
    364e:	20200593          	li	a1,514
    3652:	00004517          	auipc	a0,0x4
    3656:	f6e50513          	addi	a0,a0,-146 # 75c0 <malloc+0x1c20>
    365a:	6a3010ef          	jal	54fc <open>
    365e:	687010ef          	jal	54e4 <close>
    3662:	bfe1                	j	363a <forkforkfork+0x6e>
        exit(0);
    3664:	4501                	li	a0,0
    3666:	657010ef          	jal	54bc <exit>

000000000000366a <exectest>:
{
    366a:	711d                	addi	sp,sp,-96
    366c:	ec86                	sd	ra,88(sp)
    366e:	e8a2                	sd	s0,80(sp)
    3670:	e0ca                	sd	s2,64(sp)
    3672:	1080                	addi	s0,sp,96
    3674:	892a                	mv	s2,a0
  char *echoargv[] = {"echo", "OK", 0};
    3676:	00002797          	auipc	a5,0x2
    367a:	46278793          	addi	a5,a5,1122 # 5ad8 <malloc+0x138>
    367e:	faf43823          	sd	a5,-80(s0)
    3682:	00004797          	auipc	a5,0x4
    3686:	f4e78793          	addi	a5,a5,-178 # 75d0 <malloc+0x1c30>
    368a:	faf43c23          	sd	a5,-72(s0)
    368e:	fc043023          	sd	zero,-64(s0)
  unlink("echo-ok");
    3692:	00004517          	auipc	a0,0x4
    3696:	f4650513          	addi	a0,a0,-186 # 75d8 <malloc+0x1c38>
    369a:	673010ef          	jal	550c <unlink>
  pid = fork();
    369e:	617010ef          	jal	54b4 <fork>
  if (pid < 0) {
    36a2:	04054763          	bltz	a0,36f0 <exectest+0x86>
    36a6:	e4a6                	sd	s1,72(sp)
    36a8:	fc4e                	sd	s3,56(sp)
    36aa:	84aa                	mv	s1,a0
  if (pid == 0) {
    36ac:	ed49                	bnez	a0,3746 <exectest+0xdc>
    int errfd = dup(1);
    36ae:	4505                	li	a0,1
    36b0:	685010ef          	jal	5534 <dup>
    36b4:	89aa                	mv	s3,a0
    if (errfd < 0) {
    36b6:	04054963          	bltz	a0,3708 <exectest+0x9e>
    close(1);
    36ba:	4505                	li	a0,1
    36bc:	629010ef          	jal	54e4 <close>
    fd = open("echo-ok", O_CREATE | O_WRONLY);
    36c0:	20100593          	li	a1,513
    36c4:	00004517          	auipc	a0,0x4
    36c8:	f1450513          	addi	a0,a0,-236 # 75d8 <malloc+0x1c38>
    36cc:	631010ef          	jal	54fc <open>
    if (fd < 0) {
    36d0:	04054663          	bltz	a0,371c <exectest+0xb2>
    if (fd != 1) {
    36d4:	4785                	li	a5,1
    36d6:	04f50e63          	beq	a0,a5,3732 <exectest+0xc8>
      fprintf(errfd, "%s: wrong fd\n", s);
    36da:	864a                	mv	a2,s2
    36dc:	00004597          	auipc	a1,0x4
    36e0:	f1458593          	addi	a1,a1,-236 # 75f0 <malloc+0x1c50>
    36e4:	854e                	mv	a0,s3
    36e6:	1dc020ef          	jal	58c2 <fprintf>
      exit(1);
    36ea:	4505                	li	a0,1
    36ec:	5d1010ef          	jal	54bc <exit>
    36f0:	e4a6                	sd	s1,72(sp)
    36f2:	fc4e                	sd	s3,56(sp)
    printf("%s: fork failed\n", s);
    36f4:	85ca                	mv	a1,s2
    36f6:	00003517          	auipc	a0,0x3
    36fa:	c7250513          	addi	a0,a0,-910 # 6368 <malloc+0x9c8>
    36fe:	1ee020ef          	jal	58ec <printf>
    exit(1);
    3702:	4505                	li	a0,1
    3704:	5b9010ef          	jal	54bc <exit>
      printf("%s: dup failed\n", s);
    3708:	85ca                	mv	a1,s2
    370a:	00004517          	auipc	a0,0x4
    370e:	ed650513          	addi	a0,a0,-298 # 75e0 <malloc+0x1c40>
    3712:	1da020ef          	jal	58ec <printf>
      exit(1);
    3716:	4505                	li	a0,1
    3718:	5a5010ef          	jal	54bc <exit>
      fprintf(errfd, "%s: create failed\n", s);
    371c:	864a                	mv	a2,s2
    371e:	00003597          	auipc	a1,0x3
    3722:	dba58593          	addi	a1,a1,-582 # 64d8 <malloc+0xb38>
    3726:	854e                	mv	a0,s3
    3728:	19a020ef          	jal	58c2 <fprintf>
      exit(1);
    372c:	4505                	li	a0,1
    372e:	58f010ef          	jal	54bc <exit>
    if (exec("echo", echoargv) < 0) {
    3732:	fb040593          	addi	a1,s0,-80
    3736:	00002517          	auipc	a0,0x2
    373a:	3a250513          	addi	a0,a0,930 # 5ad8 <malloc+0x138>
    373e:	5b7010ef          	jal	54f4 <exec>
    3742:	02054563          	bltz	a0,376c <exectest+0x102>
  if (wait(&xstatus) != pid) {
    3746:	fcc40513          	addi	a0,s0,-52
    374a:	57b010ef          	jal	54c4 <wait>
    374e:	02951a63          	bne	a0,s1,3782 <exectest+0x118>
  if (xstatus != 0) {
    3752:	fcc42603          	lw	a2,-52(s0)
    3756:	ce15                	beqz	a2,3792 <exectest+0x128>
    printf("%s: nonzero wait status %d\n", s, xstatus);
    3758:	85ca                	mv	a1,s2
    375a:	00004517          	auipc	a0,0x4
    375e:	ed650513          	addi	a0,a0,-298 # 7630 <malloc+0x1c90>
    3762:	18a020ef          	jal	58ec <printf>
    exit(1);
    3766:	4505                	li	a0,1
    3768:	555010ef          	jal	54bc <exit>
      fprintf(errfd, "%s: exec echo failed\n", s);
    376c:	864a                	mv	a2,s2
    376e:	00004597          	auipc	a1,0x4
    3772:	e9258593          	addi	a1,a1,-366 # 7600 <malloc+0x1c60>
    3776:	854e                	mv	a0,s3
    3778:	14a020ef          	jal	58c2 <fprintf>
      exit(1);
    377c:	4505                	li	a0,1
    377e:	53f010ef          	jal	54bc <exit>
    printf("%s: wait failed!\n", s);
    3782:	85ca                	mv	a1,s2
    3784:	00004517          	auipc	a0,0x4
    3788:	e9450513          	addi	a0,a0,-364 # 7618 <malloc+0x1c78>
    378c:	160020ef          	jal	58ec <printf>
    3790:	b7c9                	j	3752 <exectest+0xe8>
  fd = open("echo-ok", O_RDONLY);
    3792:	4581                	li	a1,0
    3794:	00004517          	auipc	a0,0x4
    3798:	e4450513          	addi	a0,a0,-444 # 75d8 <malloc+0x1c38>
    379c:	561010ef          	jal	54fc <open>
  if (fd < 0) {
    37a0:	02054463          	bltz	a0,37c8 <exectest+0x15e>
  if (read(fd, buf, 2) != 2) {
    37a4:	4609                	li	a2,2
    37a6:	fa840593          	addi	a1,s0,-88
    37aa:	52b010ef          	jal	54d4 <read>
    37ae:	4789                	li	a5,2
    37b0:	02f50663          	beq	a0,a5,37dc <exectest+0x172>
    printf("%s: read failed\n", s);
    37b4:	85ca                	mv	a1,s2
    37b6:	00002517          	auipc	a0,0x2
    37ba:	6f250513          	addi	a0,a0,1778 # 5ea8 <malloc+0x508>
    37be:	12e020ef          	jal	58ec <printf>
    exit(1);
    37c2:	4505                	li	a0,1
    37c4:	4f9010ef          	jal	54bc <exit>
    printf("%s: open failed\n", s);
    37c8:	85ca                	mv	a1,s2
    37ca:	00003517          	auipc	a0,0x3
    37ce:	bb650513          	addi	a0,a0,-1098 # 6380 <malloc+0x9e0>
    37d2:	11a020ef          	jal	58ec <printf>
    exit(1);
    37d6:	4505                	li	a0,1
    37d8:	4e5010ef          	jal	54bc <exit>
  unlink("echo-ok");
    37dc:	00004517          	auipc	a0,0x4
    37e0:	dfc50513          	addi	a0,a0,-516 # 75d8 <malloc+0x1c38>
    37e4:	529010ef          	jal	550c <unlink>
  if (buf[0] == 'O' && buf[1] == 'K')
    37e8:	fa844703          	lbu	a4,-88(s0)
    37ec:	04f00793          	li	a5,79
    37f0:	00f71863          	bne	a4,a5,3800 <exectest+0x196>
    37f4:	fa944703          	lbu	a4,-87(s0)
    37f8:	04b00793          	li	a5,75
    37fc:	00f70c63          	beq	a4,a5,3814 <exectest+0x1aa>
    printf("%s: wrong output\n", s);
    3800:	85ca                	mv	a1,s2
    3802:	00004517          	auipc	a0,0x4
    3806:	e4e50513          	addi	a0,a0,-434 # 7650 <malloc+0x1cb0>
    380a:	0e2020ef          	jal	58ec <printf>
    exit(1);
    380e:	4505                	li	a0,1
    3810:	4ad010ef          	jal	54bc <exit>
    exit(0);
    3814:	4501                	li	a0,0
    3816:	4a7010ef          	jal	54bc <exit>

000000000000381a <killstatus>:
{
    381a:	7139                	addi	sp,sp,-64
    381c:	fc06                	sd	ra,56(sp)
    381e:	f822                	sd	s0,48(sp)
    3820:	f426                	sd	s1,40(sp)
    3822:	f04a                	sd	s2,32(sp)
    3824:	ec4e                	sd	s3,24(sp)
    3826:	e852                	sd	s4,16(sp)
    3828:	0080                	addi	s0,sp,64
    382a:	8a2a                	mv	s4,a0
    382c:	06400913          	li	s2,100
    if (xst != -1) {
    3830:	59fd                	li	s3,-1
    int pid1 = fork();
    3832:	483010ef          	jal	54b4 <fork>
    3836:	84aa                	mv	s1,a0
    if (pid1 < 0) {
    3838:	02054763          	bltz	a0,3866 <killstatus+0x4c>
    if (pid1 == 0) {
    383c:	cd1d                	beqz	a0,387a <killstatus+0x60>
    pause(1);
    383e:	4505                	li	a0,1
    3840:	50d010ef          	jal	554c <pause>
    kill(pid1);
    3844:	8526                	mv	a0,s1
    3846:	4a7010ef          	jal	54ec <kill>
    wait(&xst);
    384a:	fcc40513          	addi	a0,s0,-52
    384e:	477010ef          	jal	54c4 <wait>
    if (xst != -1) {
    3852:	fcc42783          	lw	a5,-52(s0)
    3856:	03379563          	bne	a5,s3,3880 <killstatus+0x66>
  for (int i = 0; i < 100; i++) {
    385a:	397d                	addiw	s2,s2,-1
    385c:	fc091be3          	bnez	s2,3832 <killstatus+0x18>
  exit(0);
    3860:	4501                	li	a0,0
    3862:	45b010ef          	jal	54bc <exit>
      printf("%s: fork failed\n", s);
    3866:	85d2                	mv	a1,s4
    3868:	00003517          	auipc	a0,0x3
    386c:	b0050513          	addi	a0,a0,-1280 # 6368 <malloc+0x9c8>
    3870:	07c020ef          	jal	58ec <printf>
      exit(1);
    3874:	4505                	li	a0,1
    3876:	447010ef          	jal	54bc <exit>
        getpid();
    387a:	4c3010ef          	jal	553c <getpid>
      while (1) {
    387e:	bff5                	j	387a <killstatus+0x60>
      printf("%s: status should be -1\n", s);
    3880:	85d2                	mv	a1,s4
    3882:	00004517          	auipc	a0,0x4
    3886:	de650513          	addi	a0,a0,-538 # 7668 <malloc+0x1cc8>
    388a:	062020ef          	jal	58ec <printf>
      exit(1);
    388e:	4505                	li	a0,1
    3890:	42d010ef          	jal	54bc <exit>

0000000000003894 <killzero>:
{
    3894:	7179                	addi	sp,sp,-48
    3896:	f406                	sd	ra,40(sp)
    3898:	f022                	sd	s0,32(sp)
    389a:	e84a                	sd	s2,16(sp)
    389c:	1800                	addi	s0,sp,48
    389e:	892a                	mv	s2,a0
  kill(0);
    38a0:	4501                	li	a0,0
    38a2:	44b010ef          	jal	54ec <kill>
  pid = fork();
    38a6:	40f010ef          	jal	54b4 <fork>
  if (pid < 0) {
    38aa:	00054863          	bltz	a0,38ba <killzero+0x26>
    38ae:	ec26                	sd	s1,24(sp)
    38b0:	84aa                	mv	s1,a0
  if (pid == 0) {
    38b2:	ed19                	bnez	a0,38d0 <killzero+0x3c>
    exit(7);
    38b4:	451d                	li	a0,7
    38b6:	407010ef          	jal	54bc <exit>
    38ba:	ec26                	sd	s1,24(sp)
    printf("%s: fork failed\n", s);
    38bc:	85ca                	mv	a1,s2
    38be:	00003517          	auipc	a0,0x3
    38c2:	aaa50513          	addi	a0,a0,-1366 # 6368 <malloc+0x9c8>
    38c6:	026020ef          	jal	58ec <printf>
    exit(1);
    38ca:	4505                	li	a0,1
    38cc:	3f1010ef          	jal	54bc <exit>
  if (wait(&xst) != pid) {
    38d0:	fdc40513          	addi	a0,s0,-36
    38d4:	3f1010ef          	jal	54c4 <wait>
    38d8:	02951163          	bne	a0,s1,38fa <killzero+0x66>
  if (xst != 7) {
    38dc:	fdc42603          	lw	a2,-36(s0)
    38e0:	479d                	li	a5,7
    38e2:	02f60663          	beq	a2,a5,390e <killzero+0x7a>
    printf("%s: child exited with status %d, expected 7\n", s, xst);
    38e6:	85ca                	mv	a1,s2
    38e8:	00004517          	auipc	a0,0x4
    38ec:	da050513          	addi	a0,a0,-608 # 7688 <malloc+0x1ce8>
    38f0:	7fd010ef          	jal	58ec <printf>
    exit(1);
    38f4:	4505                	li	a0,1
    38f6:	3c7010ef          	jal	54bc <exit>
    printf("%s: wait wrong pid\n", s);
    38fa:	85ca                	mv	a1,s2
    38fc:	00003517          	auipc	a0,0x3
    3900:	b7450513          	addi	a0,a0,-1164 # 6470 <malloc+0xad0>
    3904:	7e9010ef          	jal	58ec <printf>
    exit(1);
    3908:	4505                	li	a0,1
    390a:	3b3010ef          	jal	54bc <exit>
  exit(0);
    390e:	4501                	li	a0,0
    3910:	3ad010ef          	jal	54bc <exit>

0000000000003914 <preempt>:
{
    3914:	7139                	addi	sp,sp,-64
    3916:	fc06                	sd	ra,56(sp)
    3918:	f822                	sd	s0,48(sp)
    391a:	f426                	sd	s1,40(sp)
    391c:	f04a                	sd	s2,32(sp)
    391e:	ec4e                	sd	s3,24(sp)
    3920:	e852                	sd	s4,16(sp)
    3922:	0080                	addi	s0,sp,64
    3924:	892a                	mv	s2,a0
  pid1 = fork();
    3926:	38f010ef          	jal	54b4 <fork>
  if (pid1 < 0) {
    392a:	00054563          	bltz	a0,3934 <preempt+0x20>
    392e:	84aa                	mv	s1,a0
  if (pid1 == 0)
    3930:	ed01                	bnez	a0,3948 <preempt+0x34>
    for (;;)
    3932:	a001                	j	3932 <preempt+0x1e>
    printf("%s: fork failed", s);
    3934:	85ca                	mv	a1,s2
    3936:	00003517          	auipc	a0,0x3
    393a:	b7250513          	addi	a0,a0,-1166 # 64a8 <malloc+0xb08>
    393e:	7af010ef          	jal	58ec <printf>
    exit(1);
    3942:	4505                	li	a0,1
    3944:	379010ef          	jal	54bc <exit>
  pid2 = fork();
    3948:	36d010ef          	jal	54b4 <fork>
    394c:	89aa                	mv	s3,a0
  if (pid2 < 0) {
    394e:	00054463          	bltz	a0,3956 <preempt+0x42>
  if (pid2 == 0)
    3952:	ed01                	bnez	a0,396a <preempt+0x56>
    for (;;)
    3954:	a001                	j	3954 <preempt+0x40>
    printf("%s: fork failed\n", s);
    3956:	85ca                	mv	a1,s2
    3958:	00003517          	auipc	a0,0x3
    395c:	a1050513          	addi	a0,a0,-1520 # 6368 <malloc+0x9c8>
    3960:	78d010ef          	jal	58ec <printf>
    exit(1);
    3964:	4505                	li	a0,1
    3966:	357010ef          	jal	54bc <exit>
  pipe(pfds);
    396a:	fc840513          	addi	a0,s0,-56
    396e:	35f010ef          	jal	54cc <pipe>
  pid3 = fork();
    3972:	343010ef          	jal	54b4 <fork>
    3976:	8a2a                	mv	s4,a0
  if (pid3 < 0) {
    3978:	02054863          	bltz	a0,39a8 <preempt+0x94>
  if (pid3 == 0) {
    397c:	e921                	bnez	a0,39cc <preempt+0xb8>
    close(pfds[0]);
    397e:	fc842503          	lw	a0,-56(s0)
    3982:	363010ef          	jal	54e4 <close>
    if (write(pfds[1], "x", 1) != 1)
    3986:	4605                	li	a2,1
    3988:	00002597          	auipc	a1,0x2
    398c:	1c058593          	addi	a1,a1,448 # 5b48 <malloc+0x1a8>
    3990:	fcc42503          	lw	a0,-52(s0)
    3994:	349010ef          	jal	54dc <write>
    3998:	4785                	li	a5,1
    399a:	02f51163          	bne	a0,a5,39bc <preempt+0xa8>
    close(pfds[1]);
    399e:	fcc42503          	lw	a0,-52(s0)
    39a2:	343010ef          	jal	54e4 <close>
    for (;;)
    39a6:	a001                	j	39a6 <preempt+0x92>
    printf("%s: fork failed\n", s);
    39a8:	85ca                	mv	a1,s2
    39aa:	00003517          	auipc	a0,0x3
    39ae:	9be50513          	addi	a0,a0,-1602 # 6368 <malloc+0x9c8>
    39b2:	73b010ef          	jal	58ec <printf>
    exit(1);
    39b6:	4505                	li	a0,1
    39b8:	305010ef          	jal	54bc <exit>
      printf("%s: preempt write error", s);
    39bc:	85ca                	mv	a1,s2
    39be:	00004517          	auipc	a0,0x4
    39c2:	cfa50513          	addi	a0,a0,-774 # 76b8 <malloc+0x1d18>
    39c6:	727010ef          	jal	58ec <printf>
    39ca:	bfd1                	j	399e <preempt+0x8a>
  close(pfds[1]);
    39cc:	fcc42503          	lw	a0,-52(s0)
    39d0:	315010ef          	jal	54e4 <close>
  if (read(pfds[0], buf, sizeof(buf)) != 1) {
    39d4:	660d                	lui	a2,0x3
    39d6:	00009597          	auipc	a1,0x9
    39da:	32258593          	addi	a1,a1,802 # ccf8 <buf>
    39de:	fc842503          	lw	a0,-56(s0)
    39e2:	2f3010ef          	jal	54d4 <read>
    39e6:	4785                	li	a5,1
    39e8:	02f50163          	beq	a0,a5,3a0a <preempt+0xf6>
    printf("%s: preempt read error", s);
    39ec:	85ca                	mv	a1,s2
    39ee:	00004517          	auipc	a0,0x4
    39f2:	ce250513          	addi	a0,a0,-798 # 76d0 <malloc+0x1d30>
    39f6:	6f7010ef          	jal	58ec <printf>
}
    39fa:	70e2                	ld	ra,56(sp)
    39fc:	7442                	ld	s0,48(sp)
    39fe:	74a2                	ld	s1,40(sp)
    3a00:	7902                	ld	s2,32(sp)
    3a02:	69e2                	ld	s3,24(sp)
    3a04:	6a42                	ld	s4,16(sp)
    3a06:	6121                	addi	sp,sp,64
    3a08:	8082                	ret
  close(pfds[0]);
    3a0a:	fc842503          	lw	a0,-56(s0)
    3a0e:	2d7010ef          	jal	54e4 <close>
  printf("kill... ");
    3a12:	00004517          	auipc	a0,0x4
    3a16:	cd650513          	addi	a0,a0,-810 # 76e8 <malloc+0x1d48>
    3a1a:	6d3010ef          	jal	58ec <printf>
  kill(pid1);
    3a1e:	8526                	mv	a0,s1
    3a20:	2cd010ef          	jal	54ec <kill>
  kill(pid2);
    3a24:	854e                	mv	a0,s3
    3a26:	2c7010ef          	jal	54ec <kill>
  kill(pid3);
    3a2a:	8552                	mv	a0,s4
    3a2c:	2c1010ef          	jal	54ec <kill>
  printf("wait... ");
    3a30:	00004517          	auipc	a0,0x4
    3a34:	cc850513          	addi	a0,a0,-824 # 76f8 <malloc+0x1d58>
    3a38:	6b5010ef          	jal	58ec <printf>
  wait(0);
    3a3c:	4501                	li	a0,0
    3a3e:	287010ef          	jal	54c4 <wait>
  wait(0);
    3a42:	4501                	li	a0,0
    3a44:	281010ef          	jal	54c4 <wait>
  wait(0);
    3a48:	4501                	li	a0,0
    3a4a:	27b010ef          	jal	54c4 <wait>
    3a4e:	b775                	j	39fa <preempt+0xe6>

0000000000003a50 <reparent>:
{
    3a50:	7179                	addi	sp,sp,-48
    3a52:	f406                	sd	ra,40(sp)
    3a54:	f022                	sd	s0,32(sp)
    3a56:	ec26                	sd	s1,24(sp)
    3a58:	e84a                	sd	s2,16(sp)
    3a5a:	e44e                	sd	s3,8(sp)
    3a5c:	e052                	sd	s4,0(sp)
    3a5e:	1800                	addi	s0,sp,48
    3a60:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3a62:	2db010ef          	jal	553c <getpid>
    3a66:	8a2a                	mv	s4,a0
    3a68:	0c800913          	li	s2,200
    int pid = fork();
    3a6c:	249010ef          	jal	54b4 <fork>
    3a70:	84aa                	mv	s1,a0
    if (pid < 0) {
    3a72:	00054e63          	bltz	a0,3a8e <reparent+0x3e>
    if (pid) {
    3a76:	c121                	beqz	a0,3ab6 <reparent+0x66>
      if (wait(0) != pid) {
    3a78:	4501                	li	a0,0
    3a7a:	24b010ef          	jal	54c4 <wait>
    3a7e:	02951263          	bne	a0,s1,3aa2 <reparent+0x52>
  for (int i = 0; i < 200; i++) {
    3a82:	397d                	addiw	s2,s2,-1
    3a84:	fe0914e3          	bnez	s2,3a6c <reparent+0x1c>
  exit(0);
    3a88:	4501                	li	a0,0
    3a8a:	233010ef          	jal	54bc <exit>
      printf("%s: fork failed\n", s);
    3a8e:	85ce                	mv	a1,s3
    3a90:	00003517          	auipc	a0,0x3
    3a94:	8d850513          	addi	a0,a0,-1832 # 6368 <malloc+0x9c8>
    3a98:	655010ef          	jal	58ec <printf>
      exit(1);
    3a9c:	4505                	li	a0,1
    3a9e:	21f010ef          	jal	54bc <exit>
        printf("%s: wait wrong pid\n", s);
    3aa2:	85ce                	mv	a1,s3
    3aa4:	00003517          	auipc	a0,0x3
    3aa8:	9cc50513          	addi	a0,a0,-1588 # 6470 <malloc+0xad0>
    3aac:	641010ef          	jal	58ec <printf>
        exit(1);
    3ab0:	4505                	li	a0,1
    3ab2:	20b010ef          	jal	54bc <exit>
      int pid2 = fork();
    3ab6:	1ff010ef          	jal	54b4 <fork>
      if (pid2 < 0) {
    3aba:	00054563          	bltz	a0,3ac4 <reparent+0x74>
      exit(0);
    3abe:	4501                	li	a0,0
    3ac0:	1fd010ef          	jal	54bc <exit>
        kill(master_pid);
    3ac4:	8552                	mv	a0,s4
    3ac6:	227010ef          	jal	54ec <kill>
        exit(1);
    3aca:	4505                	li	a0,1
    3acc:	1f1010ef          	jal	54bc <exit>

0000000000003ad0 <sbrkfail>:
{
    3ad0:	7175                	addi	sp,sp,-144
    3ad2:	e506                	sd	ra,136(sp)
    3ad4:	e122                	sd	s0,128(sp)
    3ad6:	fca6                	sd	s1,120(sp)
    3ad8:	f8ca                	sd	s2,112(sp)
    3ada:	f4ce                	sd	s3,104(sp)
    3adc:	f0d2                	sd	s4,96(sp)
    3ade:	ecd6                	sd	s5,88(sp)
    3ae0:	e8da                	sd	s6,80(sp)
    3ae2:	e4de                	sd	s7,72(sp)
    3ae4:	0900                	addi	s0,sp,144
    3ae6:	8b2a                	mv	s6,a0
  if (pipe(fds) != 0) {
    3ae8:	fa040513          	addi	a0,s0,-96
    3aec:	1e1010ef          	jal	54cc <pipe>
    3af0:	e919                	bnez	a0,3b06 <sbrkfail+0x36>
    3af2:	8aaa                	mv	s5,a0
    3af4:	f7040493          	addi	s1,s0,-144
    3af8:	f9840993          	addi	s3,s0,-104
    3afc:	8926                	mv	s2,s1
    if (pids[i] != -1) {
    3afe:	5a7d                	li	s4,-1
      if (scratch == '0')
    3b00:	03000b93          	li	s7,48
    3b04:	a08d                	j	3b66 <sbrkfail+0x96>
    printf("%s: pipe() failed\n", s);
    3b06:	85da                	mv	a1,s6
    3b08:	00003517          	auipc	a0,0x3
    3b0c:	8e850513          	addi	a0,a0,-1816 # 63f0 <malloc+0xa50>
    3b10:	5dd010ef          	jal	58ec <printf>
    exit(1);
    3b14:	4505                	li	a0,1
    3b16:	1a7010ef          	jal	54bc <exit>
      if (sbrk(BIG - (uint64)sbrk(0)) == (char *)SBRK_ERROR)
    3b1a:	16f010ef          	jal	5488 <sbrk>
    3b1e:	064007b7          	lui	a5,0x6400
    3b22:	40a7853b          	subw	a0,a5,a0
    3b26:	163010ef          	jal	5488 <sbrk>
    3b2a:	57fd                	li	a5,-1
    3b2c:	02f50063          	beq	a0,a5,3b4c <sbrkfail+0x7c>
        write(fds[1], "1", 1);
    3b30:	4605                	li	a2,1
    3b32:	00004597          	auipc	a1,0x4
    3b36:	57e58593          	addi	a1,a1,1406 # 80b0 <malloc+0x2710>
    3b3a:	fa442503          	lw	a0,-92(s0)
    3b3e:	19f010ef          	jal	54dc <write>
        pause(1000);
    3b42:	3e800513          	li	a0,1000
    3b46:	207010ef          	jal	554c <pause>
      for (;;)
    3b4a:	bfe5                	j	3b42 <sbrkfail+0x72>
        write(fds[1], "0", 1);
    3b4c:	4605                	li	a2,1
    3b4e:	00004597          	auipc	a1,0x4
    3b52:	bba58593          	addi	a1,a1,-1094 # 7708 <malloc+0x1d68>
    3b56:	fa442503          	lw	a0,-92(s0)
    3b5a:	183010ef          	jal	54dc <write>
    3b5e:	b7d5                	j	3b42 <sbrkfail+0x72>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++) {
    3b60:	0911                	addi	s2,s2,4
    3b62:	03390663          	beq	s2,s3,3b8e <sbrkfail+0xbe>
    if ((pids[i] = fork()) == 0) {
    3b66:	14f010ef          	jal	54b4 <fork>
    3b6a:	00a92023          	sw	a0,0(s2)
    3b6e:	d555                	beqz	a0,3b1a <sbrkfail+0x4a>
    if (pids[i] != -1) {
    3b70:	ff4508e3          	beq	a0,s4,3b60 <sbrkfail+0x90>
      read(fds[0], &scratch, 1);
    3b74:	4605                	li	a2,1
    3b76:	f9f40593          	addi	a1,s0,-97
    3b7a:	fa042503          	lw	a0,-96(s0)
    3b7e:	157010ef          	jal	54d4 <read>
      if (scratch == '0')
    3b82:	f9f44783          	lbu	a5,-97(s0)
    3b86:	fd779de3          	bne	a5,s7,3b60 <sbrkfail+0x90>
        failed = 1;
    3b8a:	4a85                	li	s5,1
    3b8c:	bfd1                	j	3b60 <sbrkfail+0x90>
  if (!failed) {
    3b8e:	000a8863          	beqz	s5,3b9e <sbrkfail+0xce>
  c = sbrk(PGSIZE);
    3b92:	6505                	lui	a0,0x1
    3b94:	0f5010ef          	jal	5488 <sbrk>
    3b98:	8a2a                	mv	s4,a0
    if (pids[i] == -1)
    3b9a:	597d                	li	s2,-1
    3b9c:	a821                	j	3bb4 <sbrkfail+0xe4>
    printf("%s: no allocation failed; allocate more?\n", s);
    3b9e:	85da                	mv	a1,s6
    3ba0:	00004517          	auipc	a0,0x4
    3ba4:	b7050513          	addi	a0,a0,-1168 # 7710 <malloc+0x1d70>
    3ba8:	545010ef          	jal	58ec <printf>
    3bac:	b7dd                	j	3b92 <sbrkfail+0xc2>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++) {
    3bae:	0491                	addi	s1,s1,4
    3bb0:	01348b63          	beq	s1,s3,3bc6 <sbrkfail+0xf6>
    if (pids[i] == -1)
    3bb4:	4088                	lw	a0,0(s1)
    3bb6:	ff250ce3          	beq	a0,s2,3bae <sbrkfail+0xde>
    kill(pids[i]);
    3bba:	133010ef          	jal	54ec <kill>
    wait(0);
    3bbe:	4501                	li	a0,0
    3bc0:	105010ef          	jal	54c4 <wait>
    3bc4:	b7ed                	j	3bae <sbrkfail+0xde>
  if (c == (char *)SBRK_ERROR) {
    3bc6:	57fd                	li	a5,-1
    3bc8:	02fa0a63          	beq	s4,a5,3bfc <sbrkfail+0x12c>
  pid = fork();
    3bcc:	0e9010ef          	jal	54b4 <fork>
  if (pid < 0) {
    3bd0:	04054063          	bltz	a0,3c10 <sbrkfail+0x140>
  if (pid == 0) {
    3bd4:	e939                	bnez	a0,3c2a <sbrkfail+0x15a>
    a = sbrk(10 * BIG);
    3bd6:	3e800537          	lui	a0,0x3e800
    3bda:	0af010ef          	jal	5488 <sbrk>
    if (a == (char *)SBRK_ERROR) {
    3bde:	57fd                	li	a5,-1
    3be0:	04f50263          	beq	a0,a5,3c24 <sbrkfail+0x154>
    printf("%s: allocate a lot of memory succeeded %d\n", s, 10 * BIG);
    3be4:	3e800637          	lui	a2,0x3e800
    3be8:	85da                	mv	a1,s6
    3bea:	00004517          	auipc	a0,0x4
    3bee:	b7650513          	addi	a0,a0,-1162 # 7760 <malloc+0x1dc0>
    3bf2:	4fb010ef          	jal	58ec <printf>
    exit(1);
    3bf6:	4505                	li	a0,1
    3bf8:	0c5010ef          	jal	54bc <exit>
    printf("%s: failed sbrk leaked memory\n", s);
    3bfc:	85da                	mv	a1,s6
    3bfe:	00004517          	auipc	a0,0x4
    3c02:	b4250513          	addi	a0,a0,-1214 # 7740 <malloc+0x1da0>
    3c06:	4e7010ef          	jal	58ec <printf>
    exit(1);
    3c0a:	4505                	li	a0,1
    3c0c:	0b1010ef          	jal	54bc <exit>
    printf("%s: fork failed\n", s);
    3c10:	85da                	mv	a1,s6
    3c12:	00002517          	auipc	a0,0x2
    3c16:	75650513          	addi	a0,a0,1878 # 6368 <malloc+0x9c8>
    3c1a:	4d3010ef          	jal	58ec <printf>
    exit(1);
    3c1e:	4505                	li	a0,1
    3c20:	09d010ef          	jal	54bc <exit>
      exit(0);
    3c24:	4501                	li	a0,0
    3c26:	097010ef          	jal	54bc <exit>
  wait(&xstatus);
    3c2a:	fac40513          	addi	a0,s0,-84
    3c2e:	097010ef          	jal	54c4 <wait>
  if (xstatus != 0)
    3c32:	fac42783          	lw	a5,-84(s0)
    3c36:	ef81                	bnez	a5,3c4e <sbrkfail+0x17e>
}
    3c38:	60aa                	ld	ra,136(sp)
    3c3a:	640a                	ld	s0,128(sp)
    3c3c:	74e6                	ld	s1,120(sp)
    3c3e:	7946                	ld	s2,112(sp)
    3c40:	79a6                	ld	s3,104(sp)
    3c42:	7a06                	ld	s4,96(sp)
    3c44:	6ae6                	ld	s5,88(sp)
    3c46:	6b46                	ld	s6,80(sp)
    3c48:	6ba6                	ld	s7,72(sp)
    3c4a:	6149                	addi	sp,sp,144
    3c4c:	8082                	ret
    exit(1);
    3c4e:	4505                	li	a0,1
    3c50:	06d010ef          	jal	54bc <exit>

0000000000003c54 <mem>:
{
    3c54:	7139                	addi	sp,sp,-64
    3c56:	fc06                	sd	ra,56(sp)
    3c58:	f822                	sd	s0,48(sp)
    3c5a:	f426                	sd	s1,40(sp)
    3c5c:	f04a                	sd	s2,32(sp)
    3c5e:	ec4e                	sd	s3,24(sp)
    3c60:	0080                	addi	s0,sp,64
    3c62:	89aa                	mv	s3,a0
  if ((pid = fork()) == 0) {
    3c64:	051010ef          	jal	54b4 <fork>
    m1 = 0;
    3c68:	4481                	li	s1,0
    while ((m2 = malloc(10001)) != 0) {
    3c6a:	6909                	lui	s2,0x2
    3c6c:	71190913          	addi	s2,s2,1809 # 2711 <diskfull+0xd1>
  if ((pid = fork()) == 0) {
    3c70:	cd11                	beqz	a0,3c8c <mem+0x38>
    wait(&xstatus);
    3c72:	fcc40513          	addi	a0,s0,-52
    3c76:	04f010ef          	jal	54c4 <wait>
    if (xstatus == -1) {
    3c7a:	fcc42503          	lw	a0,-52(s0)
    3c7e:	57fd                	li	a5,-1
    3c80:	04f50363          	beq	a0,a5,3cc6 <mem+0x72>
    exit(xstatus);
    3c84:	039010ef          	jal	54bc <exit>
      *(char **)m2 = m1;
    3c88:	e104                	sd	s1,0(a0)
      m1 = m2;
    3c8a:	84aa                	mv	s1,a0
    while ((m2 = malloc(10001)) != 0) {
    3c8c:	854a                	mv	a0,s2
    3c8e:	513010ef          	jal	59a0 <malloc>
    3c92:	f97d                	bnez	a0,3c88 <mem+0x34>
    while (m1) {
    3c94:	c491                	beqz	s1,3ca0 <mem+0x4c>
      m2 = *(char **)m1;
    3c96:	8526                	mv	a0,s1
    3c98:	6084                	ld	s1,0(s1)
      free(m1);
    3c9a:	485010ef          	jal	591e <free>
    while (m1) {
    3c9e:	fce5                	bnez	s1,3c96 <mem+0x42>
    m1 = malloc(1024 * 20);
    3ca0:	6515                	lui	a0,0x5
    3ca2:	4ff010ef          	jal	59a0 <malloc>
    if (m1 == 0) {
    3ca6:	c511                	beqz	a0,3cb2 <mem+0x5e>
    free(m1);
    3ca8:	477010ef          	jal	591e <free>
    exit(0);
    3cac:	4501                	li	a0,0
    3cae:	00f010ef          	jal	54bc <exit>
      printf("%s: couldn't allocate mem?!!\n", s);
    3cb2:	85ce                	mv	a1,s3
    3cb4:	00004517          	auipc	a0,0x4
    3cb8:	adc50513          	addi	a0,a0,-1316 # 7790 <malloc+0x1df0>
    3cbc:	431010ef          	jal	58ec <printf>
      exit(1);
    3cc0:	4505                	li	a0,1
    3cc2:	7fa010ef          	jal	54bc <exit>
      exit(0);
    3cc6:	4501                	li	a0,0
    3cc8:	7f4010ef          	jal	54bc <exit>

0000000000003ccc <sharedfd>:
{
    3ccc:	7159                	addi	sp,sp,-112
    3cce:	f486                	sd	ra,104(sp)
    3cd0:	f0a2                	sd	s0,96(sp)
    3cd2:	e0d2                	sd	s4,64(sp)
    3cd4:	1880                	addi	s0,sp,112
    3cd6:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    3cd8:	00004517          	auipc	a0,0x4
    3cdc:	ad850513          	addi	a0,a0,-1320 # 77b0 <malloc+0x1e10>
    3ce0:	02d010ef          	jal	550c <unlink>
  fd = open("sharedfd", O_CREATE | O_RDWR);
    3ce4:	20200593          	li	a1,514
    3ce8:	00004517          	auipc	a0,0x4
    3cec:	ac850513          	addi	a0,a0,-1336 # 77b0 <malloc+0x1e10>
    3cf0:	00d010ef          	jal	54fc <open>
  if (fd < 0) {
    3cf4:	04054863          	bltz	a0,3d44 <sharedfd+0x78>
    3cf8:	eca6                	sd	s1,88(sp)
    3cfa:	e8ca                	sd	s2,80(sp)
    3cfc:	e4ce                	sd	s3,72(sp)
    3cfe:	fc56                	sd	s5,56(sp)
    3d00:	f85a                	sd	s6,48(sp)
    3d02:	f45e                	sd	s7,40(sp)
    3d04:	892a                	mv	s2,a0
  pid = fork();
    3d06:	7ae010ef          	jal	54b4 <fork>
    3d0a:	89aa                	mv	s3,a0
  memset(buf, pid == 0 ? 'c' : 'p', sizeof(buf));
    3d0c:	07000593          	li	a1,112
    3d10:	e119                	bnez	a0,3d16 <sharedfd+0x4a>
    3d12:	06300593          	li	a1,99
    3d16:	4629                	li	a2,10
    3d18:	fa040513          	addi	a0,s0,-96
    3d1c:	58e010ef          	jal	52aa <memset>
    3d20:	3e800493          	li	s1,1000
    if (write(fd, buf, sizeof(buf)) != sizeof(buf)) {
    3d24:	4629                	li	a2,10
    3d26:	fa040593          	addi	a1,s0,-96
    3d2a:	854a                	mv	a0,s2
    3d2c:	7b0010ef          	jal	54dc <write>
    3d30:	47a9                	li	a5,10
    3d32:	02f51963          	bne	a0,a5,3d64 <sharedfd+0x98>
  for (i = 0; i < N; i++) {
    3d36:	34fd                	addiw	s1,s1,-1
    3d38:	f4f5                	bnez	s1,3d24 <sharedfd+0x58>
  if (pid == 0) {
    3d3a:	02099f63          	bnez	s3,3d78 <sharedfd+0xac>
    exit(0);
    3d3e:	4501                	li	a0,0
    3d40:	77c010ef          	jal	54bc <exit>
    3d44:	eca6                	sd	s1,88(sp)
    3d46:	e8ca                	sd	s2,80(sp)
    3d48:	e4ce                	sd	s3,72(sp)
    3d4a:	fc56                	sd	s5,56(sp)
    3d4c:	f85a                	sd	s6,48(sp)
    3d4e:	f45e                	sd	s7,40(sp)
    printf("%s: cannot open sharedfd for writing", s);
    3d50:	85d2                	mv	a1,s4
    3d52:	00004517          	auipc	a0,0x4
    3d56:	a6e50513          	addi	a0,a0,-1426 # 77c0 <malloc+0x1e20>
    3d5a:	393010ef          	jal	58ec <printf>
    exit(1);
    3d5e:	4505                	li	a0,1
    3d60:	75c010ef          	jal	54bc <exit>
      printf("%s: write sharedfd failed\n", s);
    3d64:	85d2                	mv	a1,s4
    3d66:	00004517          	auipc	a0,0x4
    3d6a:	a8250513          	addi	a0,a0,-1406 # 77e8 <malloc+0x1e48>
    3d6e:	37f010ef          	jal	58ec <printf>
      exit(1);
    3d72:	4505                	li	a0,1
    3d74:	748010ef          	jal	54bc <exit>
    wait(&xstatus);
    3d78:	f9c40513          	addi	a0,s0,-100
    3d7c:	748010ef          	jal	54c4 <wait>
    if (xstatus != 0)
    3d80:	f9c42983          	lw	s3,-100(s0)
    3d84:	00098563          	beqz	s3,3d8e <sharedfd+0xc2>
      exit(xstatus);
    3d88:	854e                	mv	a0,s3
    3d8a:	732010ef          	jal	54bc <exit>
  close(fd);
    3d8e:	854a                	mv	a0,s2
    3d90:	754010ef          	jal	54e4 <close>
  fd = open("sharedfd", 0);
    3d94:	4581                	li	a1,0
    3d96:	00004517          	auipc	a0,0x4
    3d9a:	a1a50513          	addi	a0,a0,-1510 # 77b0 <malloc+0x1e10>
    3d9e:	75e010ef          	jal	54fc <open>
    3da2:	8baa                	mv	s7,a0
  nc = np = 0;
    3da4:	8ace                	mv	s5,s3
  if (fd < 0) {
    3da6:	02054363          	bltz	a0,3dcc <sharedfd+0x100>
    3daa:	faa40913          	addi	s2,s0,-86
      if (buf[i] == 'c')
    3dae:	06300493          	li	s1,99
      if (buf[i] == 'p')
    3db2:	07000b13          	li	s6,112
  while ((n = read(fd, buf, sizeof(buf))) > 0) {
    3db6:	4629                	li	a2,10
    3db8:	fa040593          	addi	a1,s0,-96
    3dbc:	855e                	mv	a0,s7
    3dbe:	716010ef          	jal	54d4 <read>
    3dc2:	02a05b63          	blez	a0,3df8 <sharedfd+0x12c>
    3dc6:	fa040793          	addi	a5,s0,-96
    3dca:	a839                	j	3de8 <sharedfd+0x11c>
    printf("%s: cannot open sharedfd for reading\n", s);
    3dcc:	85d2                	mv	a1,s4
    3dce:	00004517          	auipc	a0,0x4
    3dd2:	a3a50513          	addi	a0,a0,-1478 # 7808 <malloc+0x1e68>
    3dd6:	317010ef          	jal	58ec <printf>
    exit(1);
    3dda:	4505                	li	a0,1
    3ddc:	6e0010ef          	jal	54bc <exit>
        nc++;
    3de0:	2985                	addiw	s3,s3,1
    for (i = 0; i < sizeof(buf); i++) {
    3de2:	0785                	addi	a5,a5,1 # 6400001 <base+0x63f0309>
    3de4:	fd2789e3          	beq	a5,s2,3db6 <sharedfd+0xea>
      if (buf[i] == 'c')
    3de8:	0007c703          	lbu	a4,0(a5)
    3dec:	fe970ae3          	beq	a4,s1,3de0 <sharedfd+0x114>
      if (buf[i] == 'p')
    3df0:	ff6719e3          	bne	a4,s6,3de2 <sharedfd+0x116>
        np++;
    3df4:	2a85                	addiw	s5,s5,1
    3df6:	b7f5                	j	3de2 <sharedfd+0x116>
  close(fd);
    3df8:	855e                	mv	a0,s7
    3dfa:	6ea010ef          	jal	54e4 <close>
  unlink("sharedfd");
    3dfe:	00004517          	auipc	a0,0x4
    3e02:	9b250513          	addi	a0,a0,-1614 # 77b0 <malloc+0x1e10>
    3e06:	706010ef          	jal	550c <unlink>
  if (nc == N * SZ && np == N * SZ) {
    3e0a:	6789                	lui	a5,0x2
    3e0c:	71078793          	addi	a5,a5,1808 # 2710 <diskfull+0xd0>
    3e10:	00f99763          	bne	s3,a5,3e1e <sharedfd+0x152>
    3e14:	6789                	lui	a5,0x2
    3e16:	71078793          	addi	a5,a5,1808 # 2710 <diskfull+0xd0>
    3e1a:	00fa8c63          	beq	s5,a5,3e32 <sharedfd+0x166>
    printf("%s: nc/np test fails\n", s);
    3e1e:	85d2                	mv	a1,s4
    3e20:	00004517          	auipc	a0,0x4
    3e24:	a1050513          	addi	a0,a0,-1520 # 7830 <malloc+0x1e90>
    3e28:	2c5010ef          	jal	58ec <printf>
    exit(1);
    3e2c:	4505                	li	a0,1
    3e2e:	68e010ef          	jal	54bc <exit>
    exit(0);
    3e32:	4501                	li	a0,0
    3e34:	688010ef          	jal	54bc <exit>

0000000000003e38 <fourfiles>:
{
    3e38:	7135                	addi	sp,sp,-160
    3e3a:	ed06                	sd	ra,152(sp)
    3e3c:	e922                	sd	s0,144(sp)
    3e3e:	e526                	sd	s1,136(sp)
    3e40:	e14a                	sd	s2,128(sp)
    3e42:	fcce                	sd	s3,120(sp)
    3e44:	f8d2                	sd	s4,112(sp)
    3e46:	f4d6                	sd	s5,104(sp)
    3e48:	f0da                	sd	s6,96(sp)
    3e4a:	ecde                	sd	s7,88(sp)
    3e4c:	e8e2                	sd	s8,80(sp)
    3e4e:	e4e6                	sd	s9,72(sp)
    3e50:	e0ea                	sd	s10,64(sp)
    3e52:	fc6e                	sd	s11,56(sp)
    3e54:	1100                	addi	s0,sp,160
    3e56:	8caa                	mv	s9,a0
  char *names[] = {"f0", "f1", "f2", "f3"};
    3e58:	00004797          	auipc	a5,0x4
    3e5c:	9f078793          	addi	a5,a5,-1552 # 7848 <malloc+0x1ea8>
    3e60:	f6f43823          	sd	a5,-144(s0)
    3e64:	00004797          	auipc	a5,0x4
    3e68:	9ec78793          	addi	a5,a5,-1556 # 7850 <malloc+0x1eb0>
    3e6c:	f6f43c23          	sd	a5,-136(s0)
    3e70:	00004797          	auipc	a5,0x4
    3e74:	9e878793          	addi	a5,a5,-1560 # 7858 <malloc+0x1eb8>
    3e78:	f8f43023          	sd	a5,-128(s0)
    3e7c:	00004797          	auipc	a5,0x4
    3e80:	9e478793          	addi	a5,a5,-1564 # 7860 <malloc+0x1ec0>
    3e84:	f8f43423          	sd	a5,-120(s0)
  for (pi = 0; pi < NCHILD; pi++) {
    3e88:	f7040b93          	addi	s7,s0,-144
  char *names[] = {"f0", "f1", "f2", "f3"};
    3e8c:	895e                	mv	s2,s7
  for (pi = 0; pi < NCHILD; pi++) {
    3e8e:	4481                	li	s1,0
    3e90:	4a11                	li	s4,4
    fname = names[pi];
    3e92:	00093983          	ld	s3,0(s2)
    unlink(fname);
    3e96:	854e                	mv	a0,s3
    3e98:	674010ef          	jal	550c <unlink>
    pid = fork();
    3e9c:	618010ef          	jal	54b4 <fork>
    if (pid < 0) {
    3ea0:	02054e63          	bltz	a0,3edc <fourfiles+0xa4>
    if (pid == 0) {
    3ea4:	c531                	beqz	a0,3ef0 <fourfiles+0xb8>
  for (pi = 0; pi < NCHILD; pi++) {
    3ea6:	2485                	addiw	s1,s1,1
    3ea8:	0921                	addi	s2,s2,8
    3eaa:	ff4494e3          	bne	s1,s4,3e92 <fourfiles+0x5a>
    3eae:	4491                	li	s1,4
    wait(&xstatus);
    3eb0:	f6c40513          	addi	a0,s0,-148
    3eb4:	610010ef          	jal	54c4 <wait>
    if (xstatus != 0)
    3eb8:	f6c42a83          	lw	s5,-148(s0)
    3ebc:	0a0a9463          	bnez	s5,3f64 <fourfiles+0x12c>
  for (pi = 0; pi < NCHILD; pi++) {
    3ec0:	34fd                	addiw	s1,s1,-1
    3ec2:	f4fd                	bnez	s1,3eb0 <fourfiles+0x78>
    3ec4:	03000b13          	li	s6,48
    while ((n = read(fd, buf, sizeof(buf))) > 0) {
    3ec8:	00009a17          	auipc	s4,0x9
    3ecc:	e30a0a13          	addi	s4,s4,-464 # ccf8 <buf>
    if (total != N * SZ) {
    3ed0:	6d05                	lui	s10,0x1
    3ed2:	770d0d13          	addi	s10,s10,1904 # 1770 <createdelete+0xb6>
  for (i = 0; i < NCHILD; i++) {
    3ed6:	03400d93          	li	s11,52
    3eda:	a0ed                	j	3fc4 <fourfiles+0x18c>
      printf("%s: fork failed\n", s);
    3edc:	85e6                	mv	a1,s9
    3ede:	00002517          	auipc	a0,0x2
    3ee2:	48a50513          	addi	a0,a0,1162 # 6368 <malloc+0x9c8>
    3ee6:	207010ef          	jal	58ec <printf>
      exit(1);
    3eea:	4505                	li	a0,1
    3eec:	5d0010ef          	jal	54bc <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    3ef0:	20200593          	li	a1,514
    3ef4:	854e                	mv	a0,s3
    3ef6:	606010ef          	jal	54fc <open>
    3efa:	892a                	mv	s2,a0
      if (fd < 0) {
    3efc:	04054163          	bltz	a0,3f3e <fourfiles+0x106>
      memset(buf, '0' + pi, SZ);
    3f00:	1f400613          	li	a2,500
    3f04:	0304859b          	addiw	a1,s1,48
    3f08:	00009517          	auipc	a0,0x9
    3f0c:	df050513          	addi	a0,a0,-528 # ccf8 <buf>
    3f10:	39a010ef          	jal	52aa <memset>
    3f14:	44b1                	li	s1,12
        if ((n = write(fd, buf, SZ)) != SZ) {
    3f16:	00009997          	auipc	s3,0x9
    3f1a:	de298993          	addi	s3,s3,-542 # ccf8 <buf>
    3f1e:	1f400613          	li	a2,500
    3f22:	85ce                	mv	a1,s3
    3f24:	854a                	mv	a0,s2
    3f26:	5b6010ef          	jal	54dc <write>
    3f2a:	85aa                	mv	a1,a0
    3f2c:	1f400793          	li	a5,500
    3f30:	02f51163          	bne	a0,a5,3f52 <fourfiles+0x11a>
      for (i = 0; i < N; i++) {
    3f34:	34fd                	addiw	s1,s1,-1
    3f36:	f4e5                	bnez	s1,3f1e <fourfiles+0xe6>
      exit(0);
    3f38:	4501                	li	a0,0
    3f3a:	582010ef          	jal	54bc <exit>
        printf("%s: create failed\n", s);
    3f3e:	85e6                	mv	a1,s9
    3f40:	00002517          	auipc	a0,0x2
    3f44:	59850513          	addi	a0,a0,1432 # 64d8 <malloc+0xb38>
    3f48:	1a5010ef          	jal	58ec <printf>
        exit(1);
    3f4c:	4505                	li	a0,1
    3f4e:	56e010ef          	jal	54bc <exit>
          printf("write failed %d\n", n);
    3f52:	00004517          	auipc	a0,0x4
    3f56:	91650513          	addi	a0,a0,-1770 # 7868 <malloc+0x1ec8>
    3f5a:	193010ef          	jal	58ec <printf>
          exit(1);
    3f5e:	4505                	li	a0,1
    3f60:	55c010ef          	jal	54bc <exit>
      exit(xstatus);
    3f64:	8556                	mv	a0,s5
    3f66:	556010ef          	jal	54bc <exit>
          printf("%s: wrong char\n", s);
    3f6a:	85e6                	mv	a1,s9
    3f6c:	00004517          	auipc	a0,0x4
    3f70:	91450513          	addi	a0,a0,-1772 # 7880 <malloc+0x1ee0>
    3f74:	179010ef          	jal	58ec <printf>
          exit(1);
    3f78:	4505                	li	a0,1
    3f7a:	542010ef          	jal	54bc <exit>
      total += n;
    3f7e:	00a9093b          	addw	s2,s2,a0
    while ((n = read(fd, buf, sizeof(buf))) > 0) {
    3f82:	660d                	lui	a2,0x3
    3f84:	85d2                	mv	a1,s4
    3f86:	854e                	mv	a0,s3
    3f88:	54c010ef          	jal	54d4 <read>
    3f8c:	02a05063          	blez	a0,3fac <fourfiles+0x174>
    3f90:	00009797          	auipc	a5,0x9
    3f94:	d6878793          	addi	a5,a5,-664 # ccf8 <buf>
    3f98:	00f506b3          	add	a3,a0,a5
        if (buf[j] != '0' + i) {
    3f9c:	0007c703          	lbu	a4,0(a5)
    3fa0:	fc9715e3          	bne	a4,s1,3f6a <fourfiles+0x132>
      for (j = 0; j < n; j++) {
    3fa4:	0785                	addi	a5,a5,1
    3fa6:	fed79be3          	bne	a5,a3,3f9c <fourfiles+0x164>
    3faa:	bfd1                	j	3f7e <fourfiles+0x146>
    close(fd);
    3fac:	854e                	mv	a0,s3
    3fae:	536010ef          	jal	54e4 <close>
    if (total != N * SZ) {
    3fb2:	03a91463          	bne	s2,s10,3fda <fourfiles+0x1a2>
    unlink(fname);
    3fb6:	8562                	mv	a0,s8
    3fb8:	554010ef          	jal	550c <unlink>
  for (i = 0; i < NCHILD; i++) {
    3fbc:	0ba1                	addi	s7,s7,8
    3fbe:	2b05                	addiw	s6,s6,1
    3fc0:	03bb0763          	beq	s6,s11,3fee <fourfiles+0x1b6>
    fname = names[i];
    3fc4:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    3fc8:	4581                	li	a1,0
    3fca:	8562                	mv	a0,s8
    3fcc:	530010ef          	jal	54fc <open>
    3fd0:	89aa                	mv	s3,a0
    total = 0;
    3fd2:	8956                	mv	s2,s5
        if (buf[j] != '0' + i) {
    3fd4:	000b049b          	sext.w	s1,s6
    while ((n = read(fd, buf, sizeof(buf))) > 0) {
    3fd8:	b76d                	j	3f82 <fourfiles+0x14a>
      printf("wrong length %d\n", total);
    3fda:	85ca                	mv	a1,s2
    3fdc:	00004517          	auipc	a0,0x4
    3fe0:	8b450513          	addi	a0,a0,-1868 # 7890 <malloc+0x1ef0>
    3fe4:	109010ef          	jal	58ec <printf>
      exit(1);
    3fe8:	4505                	li	a0,1
    3fea:	4d2010ef          	jal	54bc <exit>
}
    3fee:	60ea                	ld	ra,152(sp)
    3ff0:	644a                	ld	s0,144(sp)
    3ff2:	64aa                	ld	s1,136(sp)
    3ff4:	690a                	ld	s2,128(sp)
    3ff6:	79e6                	ld	s3,120(sp)
    3ff8:	7a46                	ld	s4,112(sp)
    3ffa:	7aa6                	ld	s5,104(sp)
    3ffc:	7b06                	ld	s6,96(sp)
    3ffe:	6be6                	ld	s7,88(sp)
    4000:	6c46                	ld	s8,80(sp)
    4002:	6ca6                	ld	s9,72(sp)
    4004:	6d06                	ld	s10,64(sp)
    4006:	7de2                	ld	s11,56(sp)
    4008:	610d                	addi	sp,sp,160
    400a:	8082                	ret

000000000000400c <concreate>:
{
    400c:	7135                	addi	sp,sp,-160
    400e:	ed06                	sd	ra,152(sp)
    4010:	e922                	sd	s0,144(sp)
    4012:	e526                	sd	s1,136(sp)
    4014:	e14a                	sd	s2,128(sp)
    4016:	fcce                	sd	s3,120(sp)
    4018:	f8d2                	sd	s4,112(sp)
    401a:	f4d6                	sd	s5,104(sp)
    401c:	f0da                	sd	s6,96(sp)
    401e:	ecde                	sd	s7,88(sp)
    4020:	1100                	addi	s0,sp,160
    4022:	89aa                	mv	s3,a0
  file[0] = 'C';
    4024:	04300793          	li	a5,67
    4028:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    402c:	fa040523          	sb	zero,-86(s0)
  for (i = 0; i < N; i++) {
    4030:	4901                	li	s2,0
    if (pid && (i % 3) == 1) {
    4032:	4b0d                	li	s6,3
    4034:	4a85                	li	s5,1
      link("C0", file);
    4036:	00004b97          	auipc	s7,0x4
    403a:	872b8b93          	addi	s7,s7,-1934 # 78a8 <malloc+0x1f08>
  for (i = 0; i < N; i++) {
    403e:	02800a13          	li	s4,40
    4042:	a41d                	j	4268 <concreate+0x25c>
      link("C0", file);
    4044:	fa840593          	addi	a1,s0,-88
    4048:	855e                	mv	a0,s7
    404a:	4d2010ef          	jal	551c <link>
    if (pid == 0) {
    404e:	a411                	j	4252 <concreate+0x246>
    } else if (pid == 0 && (i % 5) == 1) {
    4050:	4795                	li	a5,5
    4052:	02f9693b          	remw	s2,s2,a5
    4056:	4785                	li	a5,1
    4058:	02f90563          	beq	s2,a5,4082 <concreate+0x76>
      fd = open(file, O_CREATE | O_RDWR);
    405c:	20200593          	li	a1,514
    4060:	fa840513          	addi	a0,s0,-88
    4064:	498010ef          	jal	54fc <open>
      if (fd < 0) {
    4068:	1e055063          	bgez	a0,4248 <concreate+0x23c>
        printf("concreate create %s failed\n", file);
    406c:	fa840593          	addi	a1,s0,-88
    4070:	00004517          	auipc	a0,0x4
    4074:	84050513          	addi	a0,a0,-1984 # 78b0 <malloc+0x1f10>
    4078:	075010ef          	jal	58ec <printf>
        exit(1);
    407c:	4505                	li	a0,1
    407e:	43e010ef          	jal	54bc <exit>
      link("C0", file);
    4082:	fa840593          	addi	a1,s0,-88
    4086:	00004517          	auipc	a0,0x4
    408a:	82250513          	addi	a0,a0,-2014 # 78a8 <malloc+0x1f08>
    408e:	48e010ef          	jal	551c <link>
      exit(0);
    4092:	4501                	li	a0,0
    4094:	428010ef          	jal	54bc <exit>
        exit(1);
    4098:	4505                	li	a0,1
    409a:	422010ef          	jal	54bc <exit>
  memset(fa, 0, sizeof(fa));
    409e:	02800613          	li	a2,40
    40a2:	4581                	li	a1,0
    40a4:	f8040513          	addi	a0,s0,-128
    40a8:	202010ef          	jal	52aa <memset>
  fd = open(".", 0);
    40ac:	4581                	li	a1,0
    40ae:	00002517          	auipc	a0,0x2
    40b2:	11250513          	addi	a0,a0,274 # 61c0 <malloc+0x820>
    40b6:	446010ef          	jal	54fc <open>
    40ba:	892a                	mv	s2,a0
  n = 0;
    40bc:	8aa6                	mv	s5,s1
    if (de.name[0] == 'C' && de.name[2] == '\0') {
    40be:	04300a13          	li	s4,67
      if (i < 0 || i >= sizeof(fa)) {
    40c2:	02700b13          	li	s6,39
      fa[i] = 1;
    40c6:	4b85                	li	s7,1
  while (read(fd, &de, sizeof(de)) > 0) {
    40c8:	4641                	li	a2,16
    40ca:	f7040593          	addi	a1,s0,-144
    40ce:	854a                	mv	a0,s2
    40d0:	404010ef          	jal	54d4 <read>
    40d4:	06a05a63          	blez	a0,4148 <concreate+0x13c>
    if (de.inum == 0)
    40d8:	f7045783          	lhu	a5,-144(s0)
    40dc:	d7f5                	beqz	a5,40c8 <concreate+0xbc>
    if (de.name[0] == 'C' && de.name[2] == '\0') {
    40de:	f7244783          	lbu	a5,-142(s0)
    40e2:	ff4793e3          	bne	a5,s4,40c8 <concreate+0xbc>
    40e6:	f7444783          	lbu	a5,-140(s0)
    40ea:	fff9                	bnez	a5,40c8 <concreate+0xbc>
      i = de.name[1] - '0';
    40ec:	f7344783          	lbu	a5,-141(s0)
    40f0:	fd07879b          	addiw	a5,a5,-48
    40f4:	0007871b          	sext.w	a4,a5
      if (i < 0 || i >= sizeof(fa)) {
    40f8:	02eb6063          	bltu	s6,a4,4118 <concreate+0x10c>
      if (fa[i]) {
    40fc:	fb070793          	addi	a5,a4,-80
    4100:	97a2                	add	a5,a5,s0
    4102:	fd07c783          	lbu	a5,-48(a5)
    4106:	e78d                	bnez	a5,4130 <concreate+0x124>
      fa[i] = 1;
    4108:	fb070793          	addi	a5,a4,-80
    410c:	00878733          	add	a4,a5,s0
    4110:	fd770823          	sb	s7,-48(a4)
      n++;
    4114:	2a85                	addiw	s5,s5,1
    4116:	bf4d                	j	40c8 <concreate+0xbc>
        printf("%s: concreate weird file %s\n", s, de.name);
    4118:	f7240613          	addi	a2,s0,-142
    411c:	85ce                	mv	a1,s3
    411e:	00003517          	auipc	a0,0x3
    4122:	7b250513          	addi	a0,a0,1970 # 78d0 <malloc+0x1f30>
    4126:	7c6010ef          	jal	58ec <printf>
        exit(1);
    412a:	4505                	li	a0,1
    412c:	390010ef          	jal	54bc <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4130:	f7240613          	addi	a2,s0,-142
    4134:	85ce                	mv	a1,s3
    4136:	00003517          	auipc	a0,0x3
    413a:	7ba50513          	addi	a0,a0,1978 # 78f0 <malloc+0x1f50>
    413e:	7ae010ef          	jal	58ec <printf>
        exit(1);
    4142:	4505                	li	a0,1
    4144:	378010ef          	jal	54bc <exit>
  close(fd);
    4148:	854a                	mv	a0,s2
    414a:	39a010ef          	jal	54e4 <close>
  if (n != N) {
    414e:	02800793          	li	a5,40
    4152:	00fa9763          	bne	s5,a5,4160 <concreate+0x154>
    if (((i % 3) == 0 && pid == 0) || ((i % 3) == 1 && pid != 0)) {
    4156:	4a8d                	li	s5,3
    4158:	4b05                	li	s6,1
  for (i = 0; i < N; i++) {
    415a:	02800a13          	li	s4,40
    415e:	a079                	j	41ec <concreate+0x1e0>
    printf("%s: concreate not enough files in directory listing\n", s);
    4160:	85ce                	mv	a1,s3
    4162:	00003517          	auipc	a0,0x3
    4166:	7b650513          	addi	a0,a0,1974 # 7918 <malloc+0x1f78>
    416a:	782010ef          	jal	58ec <printf>
    exit(1);
    416e:	4505                	li	a0,1
    4170:	34c010ef          	jal	54bc <exit>
      printf("%s: fork failed\n", s);
    4174:	85ce                	mv	a1,s3
    4176:	00002517          	auipc	a0,0x2
    417a:	1f250513          	addi	a0,a0,498 # 6368 <malloc+0x9c8>
    417e:	76e010ef          	jal	58ec <printf>
      exit(1);
    4182:	4505                	li	a0,1
    4184:	338010ef          	jal	54bc <exit>
      close(open(file, 0));
    4188:	4581                	li	a1,0
    418a:	fa840513          	addi	a0,s0,-88
    418e:	36e010ef          	jal	54fc <open>
    4192:	352010ef          	jal	54e4 <close>
      close(open(file, 0));
    4196:	4581                	li	a1,0
    4198:	fa840513          	addi	a0,s0,-88
    419c:	360010ef          	jal	54fc <open>
    41a0:	344010ef          	jal	54e4 <close>
      close(open(file, 0));
    41a4:	4581                	li	a1,0
    41a6:	fa840513          	addi	a0,s0,-88
    41aa:	352010ef          	jal	54fc <open>
    41ae:	336010ef          	jal	54e4 <close>
      close(open(file, 0));
    41b2:	4581                	li	a1,0
    41b4:	fa840513          	addi	a0,s0,-88
    41b8:	344010ef          	jal	54fc <open>
    41bc:	328010ef          	jal	54e4 <close>
      close(open(file, 0));
    41c0:	4581                	li	a1,0
    41c2:	fa840513          	addi	a0,s0,-88
    41c6:	336010ef          	jal	54fc <open>
    41ca:	31a010ef          	jal	54e4 <close>
      close(open(file, 0));
    41ce:	4581                	li	a1,0
    41d0:	fa840513          	addi	a0,s0,-88
    41d4:	328010ef          	jal	54fc <open>
    41d8:	30c010ef          	jal	54e4 <close>
    if (pid == 0)
    41dc:	06090363          	beqz	s2,4242 <concreate+0x236>
      wait(0);
    41e0:	4501                	li	a0,0
    41e2:	2e2010ef          	jal	54c4 <wait>
  for (i = 0; i < N; i++) {
    41e6:	2485                	addiw	s1,s1,1
    41e8:	0b448963          	beq	s1,s4,429a <concreate+0x28e>
    file[1] = '0' + i;
    41ec:	0304879b          	addiw	a5,s1,48
    41f0:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    41f4:	2c0010ef          	jal	54b4 <fork>
    41f8:	892a                	mv	s2,a0
    if (pid < 0) {
    41fa:	f6054de3          	bltz	a0,4174 <concreate+0x168>
    if (((i % 3) == 0 && pid == 0) || ((i % 3) == 1 && pid != 0)) {
    41fe:	0354e73b          	remw	a4,s1,s5
    4202:	00a767b3          	or	a5,a4,a0
    4206:	2781                	sext.w	a5,a5
    4208:	d3c1                	beqz	a5,4188 <concreate+0x17c>
    420a:	01671363          	bne	a4,s6,4210 <concreate+0x204>
    420e:	fd2d                	bnez	a0,4188 <concreate+0x17c>
      unlink(file);
    4210:	fa840513          	addi	a0,s0,-88
    4214:	2f8010ef          	jal	550c <unlink>
      unlink(file);
    4218:	fa840513          	addi	a0,s0,-88
    421c:	2f0010ef          	jal	550c <unlink>
      unlink(file);
    4220:	fa840513          	addi	a0,s0,-88
    4224:	2e8010ef          	jal	550c <unlink>
      unlink(file);
    4228:	fa840513          	addi	a0,s0,-88
    422c:	2e0010ef          	jal	550c <unlink>
      unlink(file);
    4230:	fa840513          	addi	a0,s0,-88
    4234:	2d8010ef          	jal	550c <unlink>
      unlink(file);
    4238:	fa840513          	addi	a0,s0,-88
    423c:	2d0010ef          	jal	550c <unlink>
    4240:	bf71                	j	41dc <concreate+0x1d0>
      exit(0);
    4242:	4501                	li	a0,0
    4244:	278010ef          	jal	54bc <exit>
      close(fd);
    4248:	29c010ef          	jal	54e4 <close>
    if (pid == 0) {
    424c:	b599                	j	4092 <concreate+0x86>
      close(fd);
    424e:	296010ef          	jal	54e4 <close>
      wait(&xstatus);
    4252:	f6c40513          	addi	a0,s0,-148
    4256:	26e010ef          	jal	54c4 <wait>
      if (xstatus != 0)
    425a:	f6c42483          	lw	s1,-148(s0)
    425e:	e2049de3          	bnez	s1,4098 <concreate+0x8c>
  for (i = 0; i < N; i++) {
    4262:	2905                	addiw	s2,s2,1
    4264:	e3490de3          	beq	s2,s4,409e <concreate+0x92>
    file[1] = '0' + i;
    4268:	0309079b          	addiw	a5,s2,48
    426c:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4270:	fa840513          	addi	a0,s0,-88
    4274:	298010ef          	jal	550c <unlink>
    pid = fork();
    4278:	23c010ef          	jal	54b4 <fork>
    if (pid && (i % 3) == 1) {
    427c:	dc050ae3          	beqz	a0,4050 <concreate+0x44>
    4280:	036967bb          	remw	a5,s2,s6
    4284:	dd5780e3          	beq	a5,s5,4044 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4288:	20200593          	li	a1,514
    428c:	fa840513          	addi	a0,s0,-88
    4290:	26c010ef          	jal	54fc <open>
      if (fd < 0) {
    4294:	fa055de3          	bgez	a0,424e <concreate+0x242>
    4298:	bbd1                	j	406c <concreate+0x60>
}
    429a:	60ea                	ld	ra,152(sp)
    429c:	644a                	ld	s0,144(sp)
    429e:	64aa                	ld	s1,136(sp)
    42a0:	690a                	ld	s2,128(sp)
    42a2:	79e6                	ld	s3,120(sp)
    42a4:	7a46                	ld	s4,112(sp)
    42a6:	7aa6                	ld	s5,104(sp)
    42a8:	7b06                	ld	s6,96(sp)
    42aa:	6be6                	ld	s7,88(sp)
    42ac:	610d                	addi	sp,sp,160
    42ae:	8082                	ret

00000000000042b0 <bigfile>:
{
    42b0:	7139                	addi	sp,sp,-64
    42b2:	fc06                	sd	ra,56(sp)
    42b4:	f822                	sd	s0,48(sp)
    42b6:	f426                	sd	s1,40(sp)
    42b8:	f04a                	sd	s2,32(sp)
    42ba:	ec4e                	sd	s3,24(sp)
    42bc:	e852                	sd	s4,16(sp)
    42be:	e456                	sd	s5,8(sp)
    42c0:	0080                	addi	s0,sp,64
    42c2:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    42c4:	00003517          	auipc	a0,0x3
    42c8:	68c50513          	addi	a0,a0,1676 # 7950 <malloc+0x1fb0>
    42cc:	240010ef          	jal	550c <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    42d0:	20200593          	li	a1,514
    42d4:	00003517          	auipc	a0,0x3
    42d8:	67c50513          	addi	a0,a0,1660 # 7950 <malloc+0x1fb0>
    42dc:	220010ef          	jal	54fc <open>
    42e0:	89aa                	mv	s3,a0
  for (i = 0; i < N; i++) {
    42e2:	4481                	li	s1,0
    memset(buf, i, SZ);
    42e4:	00009917          	auipc	s2,0x9
    42e8:	a1490913          	addi	s2,s2,-1516 # ccf8 <buf>
  for (i = 0; i < N; i++) {
    42ec:	4a51                	li	s4,20
  if (fd < 0) {
    42ee:	08054663          	bltz	a0,437a <bigfile+0xca>
    memset(buf, i, SZ);
    42f2:	25800613          	li	a2,600
    42f6:	85a6                	mv	a1,s1
    42f8:	854a                	mv	a0,s2
    42fa:	7b1000ef          	jal	52aa <memset>
    if (write(fd, buf, SZ) != SZ) {
    42fe:	25800613          	li	a2,600
    4302:	85ca                	mv	a1,s2
    4304:	854e                	mv	a0,s3
    4306:	1d6010ef          	jal	54dc <write>
    430a:	25800793          	li	a5,600
    430e:	08f51063          	bne	a0,a5,438e <bigfile+0xde>
  for (i = 0; i < N; i++) {
    4312:	2485                	addiw	s1,s1,1
    4314:	fd449fe3          	bne	s1,s4,42f2 <bigfile+0x42>
  close(fd);
    4318:	854e                	mv	a0,s3
    431a:	1ca010ef          	jal	54e4 <close>
  fd = open("bigfile.dat", 0);
    431e:	4581                	li	a1,0
    4320:	00003517          	auipc	a0,0x3
    4324:	63050513          	addi	a0,a0,1584 # 7950 <malloc+0x1fb0>
    4328:	1d4010ef          	jal	54fc <open>
    432c:	8a2a                	mv	s4,a0
  total = 0;
    432e:	4981                	li	s3,0
  for (i = 0;; i++) {
    4330:	4481                	li	s1,0
    cc = read(fd, buf, SZ / 2);
    4332:	00009917          	auipc	s2,0x9
    4336:	9c690913          	addi	s2,s2,-1594 # ccf8 <buf>
  if (fd < 0) {
    433a:	06054463          	bltz	a0,43a2 <bigfile+0xf2>
    cc = read(fd, buf, SZ / 2);
    433e:	12c00613          	li	a2,300
    4342:	85ca                	mv	a1,s2
    4344:	8552                	mv	a0,s4
    4346:	18e010ef          	jal	54d4 <read>
    if (cc < 0) {
    434a:	06054663          	bltz	a0,43b6 <bigfile+0x106>
    if (cc == 0)
    434e:	c155                	beqz	a0,43f2 <bigfile+0x142>
    if (cc != SZ / 2) {
    4350:	12c00793          	li	a5,300
    4354:	06f51b63          	bne	a0,a5,43ca <bigfile+0x11a>
    if (buf[0] != i / 2 || buf[SZ / 2 - 1] != i / 2) {
    4358:	01f4d79b          	srliw	a5,s1,0x1f
    435c:	9fa5                	addw	a5,a5,s1
    435e:	4017d79b          	sraiw	a5,a5,0x1
    4362:	00094703          	lbu	a4,0(s2)
    4366:	06f71c63          	bne	a4,a5,43de <bigfile+0x12e>
    436a:	12b94703          	lbu	a4,299(s2)
    436e:	06f71863          	bne	a4,a5,43de <bigfile+0x12e>
    total += cc;
    4372:	12c9899b          	addiw	s3,s3,300
  for (i = 0;; i++) {
    4376:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ / 2);
    4378:	b7d9                	j	433e <bigfile+0x8e>
    printf("%s: cannot create bigfile", s);
    437a:	85d6                	mv	a1,s5
    437c:	00003517          	auipc	a0,0x3
    4380:	5e450513          	addi	a0,a0,1508 # 7960 <malloc+0x1fc0>
    4384:	568010ef          	jal	58ec <printf>
    exit(1);
    4388:	4505                	li	a0,1
    438a:	132010ef          	jal	54bc <exit>
      printf("%s: write bigfile failed\n", s);
    438e:	85d6                	mv	a1,s5
    4390:	00003517          	auipc	a0,0x3
    4394:	5f050513          	addi	a0,a0,1520 # 7980 <malloc+0x1fe0>
    4398:	554010ef          	jal	58ec <printf>
      exit(1);
    439c:	4505                	li	a0,1
    439e:	11e010ef          	jal	54bc <exit>
    printf("%s: cannot open bigfile\n", s);
    43a2:	85d6                	mv	a1,s5
    43a4:	00003517          	auipc	a0,0x3
    43a8:	5fc50513          	addi	a0,a0,1532 # 79a0 <malloc+0x2000>
    43ac:	540010ef          	jal	58ec <printf>
    exit(1);
    43b0:	4505                	li	a0,1
    43b2:	10a010ef          	jal	54bc <exit>
      printf("%s: read bigfile failed\n", s);
    43b6:	85d6                	mv	a1,s5
    43b8:	00003517          	auipc	a0,0x3
    43bc:	60850513          	addi	a0,a0,1544 # 79c0 <malloc+0x2020>
    43c0:	52c010ef          	jal	58ec <printf>
      exit(1);
    43c4:	4505                	li	a0,1
    43c6:	0f6010ef          	jal	54bc <exit>
      printf("%s: short read bigfile\n", s);
    43ca:	85d6                	mv	a1,s5
    43cc:	00003517          	auipc	a0,0x3
    43d0:	61450513          	addi	a0,a0,1556 # 79e0 <malloc+0x2040>
    43d4:	518010ef          	jal	58ec <printf>
      exit(1);
    43d8:	4505                	li	a0,1
    43da:	0e2010ef          	jal	54bc <exit>
      printf("%s: read bigfile wrong data\n", s);
    43de:	85d6                	mv	a1,s5
    43e0:	00003517          	auipc	a0,0x3
    43e4:	61850513          	addi	a0,a0,1560 # 79f8 <malloc+0x2058>
    43e8:	504010ef          	jal	58ec <printf>
      exit(1);
    43ec:	4505                	li	a0,1
    43ee:	0ce010ef          	jal	54bc <exit>
  close(fd);
    43f2:	8552                	mv	a0,s4
    43f4:	0f0010ef          	jal	54e4 <close>
  if (total != N * SZ) {
    43f8:	678d                	lui	a5,0x3
    43fa:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x494>
    43fe:	02f99163          	bne	s3,a5,4420 <bigfile+0x170>
  unlink("bigfile.dat");
    4402:	00003517          	auipc	a0,0x3
    4406:	54e50513          	addi	a0,a0,1358 # 7950 <malloc+0x1fb0>
    440a:	102010ef          	jal	550c <unlink>
}
    440e:	70e2                	ld	ra,56(sp)
    4410:	7442                	ld	s0,48(sp)
    4412:	74a2                	ld	s1,40(sp)
    4414:	7902                	ld	s2,32(sp)
    4416:	69e2                	ld	s3,24(sp)
    4418:	6a42                	ld	s4,16(sp)
    441a:	6aa2                	ld	s5,8(sp)
    441c:	6121                	addi	sp,sp,64
    441e:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4420:	85d6                	mv	a1,s5
    4422:	00003517          	auipc	a0,0x3
    4426:	5f650513          	addi	a0,a0,1526 # 7a18 <malloc+0x2078>
    442a:	4c2010ef          	jal	58ec <printf>
    exit(1);
    442e:	4505                	li	a0,1
    4430:	08c010ef          	jal	54bc <exit>

0000000000004434 <bigargtest>:
{
    4434:	7121                	addi	sp,sp,-448
    4436:	ff06                	sd	ra,440(sp)
    4438:	fb22                	sd	s0,432(sp)
    443a:	f726                	sd	s1,424(sp)
    443c:	0380                	addi	s0,sp,448
    443e:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    4440:	00003517          	auipc	a0,0x3
    4444:	5f850513          	addi	a0,a0,1528 # 7a38 <malloc+0x2098>
    4448:	0c4010ef          	jal	550c <unlink>
  pid = fork();
    444c:	068010ef          	jal	54b4 <fork>
  if (pid == 0) {
    4450:	c915                	beqz	a0,4484 <bigargtest+0x50>
  } else if (pid < 0) {
    4452:	08054a63          	bltz	a0,44e6 <bigargtest+0xb2>
  wait(&xstatus);
    4456:	fdc40513          	addi	a0,s0,-36
    445a:	06a010ef          	jal	54c4 <wait>
  if (xstatus != 0)
    445e:	fdc42503          	lw	a0,-36(s0)
    4462:	ed41                	bnez	a0,44fa <bigargtest+0xc6>
  fd = open("bigarg-ok", 0);
    4464:	4581                	li	a1,0
    4466:	00003517          	auipc	a0,0x3
    446a:	5d250513          	addi	a0,a0,1490 # 7a38 <malloc+0x2098>
    446e:	08e010ef          	jal	54fc <open>
  if (fd < 0) {
    4472:	08054663          	bltz	a0,44fe <bigargtest+0xca>
  close(fd);
    4476:	06e010ef          	jal	54e4 <close>
}
    447a:	70fa                	ld	ra,440(sp)
    447c:	745a                	ld	s0,432(sp)
    447e:	74ba                	ld	s1,424(sp)
    4480:	6139                	addi	sp,sp,448
    4482:	8082                	ret
    memset(big, ' ', sizeof(big));
    4484:	19000613          	li	a2,400
    4488:	02000593          	li	a1,32
    448c:	e4840513          	addi	a0,s0,-440
    4490:	61b000ef          	jal	52aa <memset>
    big[sizeof(big) - 1] = '\0';
    4494:	fc040ba3          	sb	zero,-41(s0)
    for (i = 0; i < MAXARG - 1; i++)
    4498:	00005797          	auipc	a5,0x5
    449c:	04878793          	addi	a5,a5,72 # 94e0 <args.1>
    44a0:	00005697          	auipc	a3,0x5
    44a4:	13868693          	addi	a3,a3,312 # 95d8 <args.1+0xf8>
      args[i] = big;
    44a8:	e4840713          	addi	a4,s0,-440
    44ac:	e398                	sd	a4,0(a5)
    for (i = 0; i < MAXARG - 1; i++)
    44ae:	07a1                	addi	a5,a5,8
    44b0:	fed79ee3          	bne	a5,a3,44ac <bigargtest+0x78>
    args[MAXARG - 1] = 0;
    44b4:	00005597          	auipc	a1,0x5
    44b8:	02c58593          	addi	a1,a1,44 # 94e0 <args.1>
    44bc:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    44c0:	00001517          	auipc	a0,0x1
    44c4:	61850513          	addi	a0,a0,1560 # 5ad8 <malloc+0x138>
    44c8:	02c010ef          	jal	54f4 <exec>
    fd = open("bigarg-ok", O_CREATE);
    44cc:	20000593          	li	a1,512
    44d0:	00003517          	auipc	a0,0x3
    44d4:	56850513          	addi	a0,a0,1384 # 7a38 <malloc+0x2098>
    44d8:	024010ef          	jal	54fc <open>
    close(fd);
    44dc:	008010ef          	jal	54e4 <close>
    exit(0);
    44e0:	4501                	li	a0,0
    44e2:	7db000ef          	jal	54bc <exit>
    printf("%s: bigargtest: fork failed\n", s);
    44e6:	85a6                	mv	a1,s1
    44e8:	00003517          	auipc	a0,0x3
    44ec:	56050513          	addi	a0,a0,1376 # 7a48 <malloc+0x20a8>
    44f0:	3fc010ef          	jal	58ec <printf>
    exit(1);
    44f4:	4505                	li	a0,1
    44f6:	7c7000ef          	jal	54bc <exit>
    exit(xstatus);
    44fa:	7c3000ef          	jal	54bc <exit>
    printf("%s: bigarg test failed!\n", s);
    44fe:	85a6                	mv	a1,s1
    4500:	00003517          	auipc	a0,0x3
    4504:	56850513          	addi	a0,a0,1384 # 7a68 <malloc+0x20c8>
    4508:	3e4010ef          	jal	58ec <printf>
    exit(1);
    450c:	4505                	li	a0,1
    450e:	7af000ef          	jal	54bc <exit>

0000000000004512 <partial_write>:
{
    4512:	bc010113          	addi	sp,sp,-1088
    4516:	42113c23          	sd	ra,1080(sp)
    451a:	42813823          	sd	s0,1072(sp)
    451e:	42913423          	sd	s1,1064(sp)
    4522:	43213023          	sd	s2,1056(sp)
    4526:	41313c23          	sd	s3,1048(sp)
    452a:	44010413          	addi	s0,sp,1088
    452e:	89aa                	mv	s3,a0
  unlink("testfile");
    4530:	00003517          	auipc	a0,0x3
    4534:	55850513          	addi	a0,a0,1368 # 7a88 <malloc+0x20e8>
    4538:	7d5000ef          	jal	550c <unlink>
  int fd = open("testfile", O_CREATE | O_RDWR);
    453c:	20200593          	li	a1,514
    4540:	00003517          	auipc	a0,0x3
    4544:	54850513          	addi	a0,a0,1352 # 7a88 <malloc+0x20e8>
    4548:	7b5000ef          	jal	54fc <open>
  if (fd < 0) {
    454c:	14054c63          	bltz	a0,46a4 <partial_write+0x192>
    4550:	84aa                	mv	s1,a0
  int cc = write(fd, "A", 1);
    4552:	4605                	li	a2,1
    4554:	00003597          	auipc	a1,0x3
    4558:	56458593          	addi	a1,a1,1380 # 7ab8 <malloc+0x2118>
    455c:	781000ef          	jal	54dc <write>
  if (cc != 1) {
    4560:	4785                	li	a5,1
    4562:	14f51b63          	bne	a0,a5,46b8 <partial_write+0x1a6>
  close(fd);
    4566:	8526                	mv	a0,s1
    4568:	77d000ef          	jal	54e4 <close>
  fd = open("testfile", O_RDWR);
    456c:	4589                	li	a1,2
    456e:	00003517          	auipc	a0,0x3
    4572:	51a50513          	addi	a0,a0,1306 # 7a88 <malloc+0x20e8>
    4576:	787000ef          	jal	54fc <open>
    457a:	892a                	mv	s2,a0
  if (fd < 0) {
    457c:	14054863          	bltz	a0,46cc <partial_write+0x1ba>
  char *p = sbrk(0);
    4580:	4501                	li	a0,0
    4582:	707000ef          	jal	5488 <sbrk>
  sbrk(PGSIZE - ((uint64)p % PGSIZE));
    4586:	6485                	lui	s1,0x1
    4588:	14fd                	addi	s1,s1,-1 # fff <pgbug+0x2b>
    458a:	009577b3          	and	a5,a0,s1
    458e:	6505                	lui	a0,0x1
    4590:	9d1d                	subw	a0,a0,a5
    4592:	6f7000ef          	jal	5488 <sbrk>
  p = sbrk(0);
    4596:	4501                	li	a0,0
    4598:	6f1000ef          	jal	5488 <sbrk>
  if ((uint64)p % PGSIZE != 0) {
    459c:	8ce9                	and	s1,s1,a0
    459e:	14049163          	bnez	s1,46e0 <partial_write+0x1ce>
  p[-1] = 'X';
    45a2:	05800793          	li	a5,88
    45a6:	fef50fa3          	sb	a5,-1(a0) # fff <pgbug+0x2b>
  cc = write(fd, p - 1, 2);
    45aa:	4609                	li	a2,2
    45ac:	fff50593          	addi	a1,a0,-1
    45b0:	854a                	mv	a0,s2
    45b2:	72b000ef          	jal	54dc <write>
  if (cc != -1) {
    45b6:	57fd                	li	a5,-1
    45b8:	12f51e63          	bne	a0,a5,46f4 <partial_write+0x1e2>
  close(fd);
    45bc:	854a                	mv	a0,s2
    45be:	727000ef          	jal	54e4 <close>
  fd = open("testfile", O_RDONLY);
    45c2:	4581                	li	a1,0
    45c4:	00003517          	auipc	a0,0x3
    45c8:	4c450513          	addi	a0,a0,1220 # 7a88 <malloc+0x20e8>
    45cc:	731000ef          	jal	54fc <open>
    45d0:	84aa                	mv	s1,a0
  if (fd < 0) {
    45d2:	12054b63          	bltz	a0,4708 <partial_write+0x1f6>
  cc = read(fd, &b, 1);
    45d6:	4605                	li	a2,1
    45d8:	fcf40593          	addi	a1,s0,-49
    45dc:	6f9000ef          	jal	54d4 <read>
  if (cc != 1) {
    45e0:	4785                	li	a5,1
    45e2:	12f51d63          	bne	a0,a5,471c <partial_write+0x20a>
  close(fd);
    45e6:	8526                	mv	a0,s1
    45e8:	6fd000ef          	jal	54e4 <close>
  if (b != 'X') {
    45ec:	fcf44603          	lbu	a2,-49(s0)
    45f0:	05800793          	li	a5,88
    45f4:	12f61e63          	bne	a2,a5,4730 <partial_write+0x21e>
  fd = open("bigfile", O_CREATE | O_RDWR);
    45f8:	20200593          	li	a1,514
    45fc:	00003517          	auipc	a0,0x3
    4600:	58c50513          	addi	a0,a0,1420 # 7b88 <malloc+0x21e8>
    4604:	6f9000ef          	jal	54fc <open>
    4608:	892a                	mv	s2,a0
    460a:	04000493          	li	s1,64
    memset(buf, 0, sizeof(buf));
    460e:	40000613          	li	a2,1024
    4612:	4581                	li	a1,0
    4614:	bc840513          	addi	a0,s0,-1080
    4618:	493000ef          	jal	52aa <memset>
    cc = write(fd, buf, sizeof(buf));
    461c:	40000613          	li	a2,1024
    4620:	bc840593          	addi	a1,s0,-1080
    4624:	854a                	mv	a0,s2
    4626:	6b7000ef          	jal	54dc <write>
    if (cc != sizeof(buf)) {
    462a:	40000793          	li	a5,1024
    462e:	10f51b63          	bne	a0,a5,4744 <partial_write+0x232>
  for (int i = 0; i < 64; i++) {
    4632:	34fd                	addiw	s1,s1,-1
    4634:	fce9                	bnez	s1,460e <partial_write+0xfc>
  close(fd);
    4636:	854a                	mv	a0,s2
    4638:	6ad000ef          	jal	54e4 <close>
  unlink("bigfile");
    463c:	00003517          	auipc	a0,0x3
    4640:	54c50513          	addi	a0,a0,1356 # 7b88 <malloc+0x21e8>
    4644:	6c9000ef          	jal	550c <unlink>
  fd = open("testfile", O_RDONLY);
    4648:	4581                	li	a1,0
    464a:	00003517          	auipc	a0,0x3
    464e:	43e50513          	addi	a0,a0,1086 # 7a88 <malloc+0x20e8>
    4652:	6ab000ef          	jal	54fc <open>
    4656:	84aa                	mv	s1,a0
  if (fd < 0) {
    4658:	10054063          	bltz	a0,4758 <partial_write+0x246>
  cc = read(fd, &b, 1);
    465c:	4605                	li	a2,1
    465e:	fcf40593          	addi	a1,s0,-49
    4662:	673000ef          	jal	54d4 <read>
  if (cc != 1) {
    4666:	4785                	li	a5,1
    4668:	10f51263          	bne	a0,a5,476c <partial_write+0x25a>
  close(fd);
    466c:	8526                	mv	a0,s1
    466e:	677000ef          	jal	54e4 <close>
  if (b != 'X') {
    4672:	fcf44603          	lbu	a2,-49(s0)
    4676:	05800793          	li	a5,88
    467a:	10f61363          	bne	a2,a5,4780 <partial_write+0x26e>
  unlink("testfile");
    467e:	00003517          	auipc	a0,0x3
    4682:	40a50513          	addi	a0,a0,1034 # 7a88 <malloc+0x20e8>
    4686:	687000ef          	jal	550c <unlink>
}
    468a:	43813083          	ld	ra,1080(sp)
    468e:	43013403          	ld	s0,1072(sp)
    4692:	42813483          	ld	s1,1064(sp)
    4696:	42013903          	ld	s2,1056(sp)
    469a:	41813983          	ld	s3,1048(sp)
    469e:	44010113          	addi	sp,sp,1088
    46a2:	8082                	ret
    printf("%s: cannot create testfile\n", s);
    46a4:	85ce                	mv	a1,s3
    46a6:	00003517          	auipc	a0,0x3
    46aa:	3f250513          	addi	a0,a0,1010 # 7a98 <malloc+0x20f8>
    46ae:	23e010ef          	jal	58ec <printf>
    exit(1);
    46b2:	4505                	li	a0,1
    46b4:	609000ef          	jal	54bc <exit>
    printf("%s: could not write A\n", s);
    46b8:	85ce                	mv	a1,s3
    46ba:	00003517          	auipc	a0,0x3
    46be:	40650513          	addi	a0,a0,1030 # 7ac0 <malloc+0x2120>
    46c2:	22a010ef          	jal	58ec <printf>
    exit(1);
    46c6:	4505                	li	a0,1
    46c8:	5f5000ef          	jal	54bc <exit>
    printf("%s: cannot re-open testfile\n", s);
    46cc:	85ce                	mv	a1,s3
    46ce:	00003517          	auipc	a0,0x3
    46d2:	40a50513          	addi	a0,a0,1034 # 7ad8 <malloc+0x2138>
    46d6:	216010ef          	jal	58ec <printf>
    exit(1);
    46da:	4505                	li	a0,1
    46dc:	5e1000ef          	jal	54bc <exit>
    printf("%s: sbrk did not align\n", s);
    46e0:	85ce                	mv	a1,s3
    46e2:	00003517          	auipc	a0,0x3
    46e6:	41650513          	addi	a0,a0,1046 # 7af8 <malloc+0x2158>
    46ea:	202010ef          	jal	58ec <printf>
    exit(1);
    46ee:	4505                	li	a0,1
    46f0:	5cd000ef          	jal	54bc <exit>
    printf("%s: write succeeded, should have failed\n", s);
    46f4:	85ce                	mv	a1,s3
    46f6:	00003517          	auipc	a0,0x3
    46fa:	41a50513          	addi	a0,a0,1050 # 7b10 <malloc+0x2170>
    46fe:	1ee010ef          	jal	58ec <printf>
    exit(1);
    4702:	4505                	li	a0,1
    4704:	5b9000ef          	jal	54bc <exit>
    printf("%s: cannot re-open testfile\n", s);
    4708:	85ce                	mv	a1,s3
    470a:	00003517          	auipc	a0,0x3
    470e:	3ce50513          	addi	a0,a0,974 # 7ad8 <malloc+0x2138>
    4712:	1da010ef          	jal	58ec <printf>
    exit(1);
    4716:	4505                	li	a0,1
    4718:	5a5000ef          	jal	54bc <exit>
    printf("%s: cannot read testfile\n", s);
    471c:	85ce                	mv	a1,s3
    471e:	00003517          	auipc	a0,0x3
    4722:	42250513          	addi	a0,a0,1058 # 7b40 <malloc+0x21a0>
    4726:	1c6010ef          	jal	58ec <printf>
    exit(1);
    472a:	4505                	li	a0,1
    472c:	591000ef          	jal	54bc <exit>
    printf("%s: read returned %c, expected X\n", s, b);
    4730:	85ce                	mv	a1,s3
    4732:	00003517          	auipc	a0,0x3
    4736:	42e50513          	addi	a0,a0,1070 # 7b60 <malloc+0x21c0>
    473a:	1b2010ef          	jal	58ec <printf>
    exit(1);
    473e:	4505                	li	a0,1
    4740:	57d000ef          	jal	54bc <exit>
      printf("%s: could not write to bigfile\n", s);
    4744:	85ce                	mv	a1,s3
    4746:	00003517          	auipc	a0,0x3
    474a:	44a50513          	addi	a0,a0,1098 # 7b90 <malloc+0x21f0>
    474e:	19e010ef          	jal	58ec <printf>
      exit(-1);
    4752:	557d                	li	a0,-1
    4754:	569000ef          	jal	54bc <exit>
    printf("%s: cannot re-open testfile\n", s);
    4758:	85ce                	mv	a1,s3
    475a:	00003517          	auipc	a0,0x3
    475e:	37e50513          	addi	a0,a0,894 # 7ad8 <malloc+0x2138>
    4762:	18a010ef          	jal	58ec <printf>
    exit(1);
    4766:	4505                	li	a0,1
    4768:	555000ef          	jal	54bc <exit>
    printf("%s: cannot read testfile\n", s);
    476c:	85ce                	mv	a1,s3
    476e:	00003517          	auipc	a0,0x3
    4772:	3d250513          	addi	a0,a0,978 # 7b40 <malloc+0x21a0>
    4776:	176010ef          	jal	58ec <printf>
    exit(1);
    477a:	4505                	li	a0,1
    477c:	541000ef          	jal	54bc <exit>
    printf("%s: read returned %c, expected X\n", s, b);
    4780:	85ce                	mv	a1,s3
    4782:	00003517          	auipc	a0,0x3
    4786:	3de50513          	addi	a0,a0,990 # 7b60 <malloc+0x21c0>
    478a:	162010ef          	jal	58ec <printf>
    exit(1);
    478e:	4505                	li	a0,1
    4790:	52d000ef          	jal	54bc <exit>

0000000000004794 <lazy_alloc>:
{
    4794:	1141                	addi	sp,sp,-16
    4796:	e406                	sd	ra,8(sp)
    4798:	e022                	sd	s0,0(sp)
    479a:	0800                	addi	s0,sp,16
  prev_end = sbrklazy(REGION_SZ);
    479c:	40000537          	lui	a0,0x40000
    47a0:	4ff000ef          	jal	549e <sbrklazy>
  if (prev_end == (char *)SBRK_ERROR) {
    47a4:	57fd                	li	a5,-1
    47a6:	02f50a63          	beq	a0,a5,47da <lazy_alloc+0x46>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    47aa:	6605                	lui	a2,0x1
    47ac:	962a                	add	a2,a2,a0
    47ae:	400017b7          	lui	a5,0x40001
    47b2:	00f50733          	add	a4,a0,a5
    47b6:	87b2                	mv	a5,a2
    47b8:	000406b7          	lui	a3,0x40
    *(char **)i = i;
    47bc:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    47be:	97b6                	add	a5,a5,a3
    47c0:	fee79ee3          	bne	a5,a4,47bc <lazy_alloc+0x28>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    47c4:	000406b7          	lui	a3,0x40
    if (*(char **)i != i) {
    47c8:	621c                	ld	a5,0(a2)
    47ca:	02c79163          	bne	a5,a2,47ec <lazy_alloc+0x58>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    47ce:	9636                	add	a2,a2,a3
    47d0:	fee61ce3          	bne	a2,a4,47c8 <lazy_alloc+0x34>
  exit(0);
    47d4:	4501                	li	a0,0
    47d6:	4e7000ef          	jal	54bc <exit>
    printf("sbrklazy() failed\n");
    47da:	00003517          	auipc	a0,0x3
    47de:	3d650513          	addi	a0,a0,982 # 7bb0 <malloc+0x2210>
    47e2:	10a010ef          	jal	58ec <printf>
    exit(1);
    47e6:	4505                	li	a0,1
    47e8:	4d5000ef          	jal	54bc <exit>
      printf("failed to read value from memory\n");
    47ec:	00003517          	auipc	a0,0x3
    47f0:	3dc50513          	addi	a0,a0,988 # 7bc8 <malloc+0x2228>
    47f4:	0f8010ef          	jal	58ec <printf>
      exit(1);
    47f8:	4505                	li	a0,1
    47fa:	4c3000ef          	jal	54bc <exit>

00000000000047fe <lazy_unmap>:
{
    47fe:	7139                	addi	sp,sp,-64
    4800:	fc06                	sd	ra,56(sp)
    4802:	f822                	sd	s0,48(sp)
    4804:	0080                	addi	s0,sp,64
  prev_end = sbrklazy(REGION_SZ);
    4806:	40000537          	lui	a0,0x40000
    480a:	495000ef          	jal	549e <sbrklazy>
  if (prev_end == (char *)SBRK_ERROR) {
    480e:	57fd                	li	a5,-1
    4810:	04f50663          	beq	a0,a5,485c <lazy_unmap+0x5e>
    4814:	f426                	sd	s1,40(sp)
    4816:	f04a                	sd	s2,32(sp)
    4818:	ec4e                	sd	s3,24(sp)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    481a:	6905                	lui	s2,0x1
    481c:	992a                	add	s2,s2,a0
    481e:	400017b7          	lui	a5,0x40001
    4822:	00f504b3          	add	s1,a0,a5
    4826:	87ca                	mv	a5,s2
    4828:	01000737          	lui	a4,0x1000
    *(char **)i = i;
    482c:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    482e:	97ba                	add	a5,a5,a4
    4830:	fe979ee3          	bne	a5,s1,482c <lazy_unmap+0x2e>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    4834:	010009b7          	lui	s3,0x1000
    pid = fork();
    4838:	47d000ef          	jal	54b4 <fork>
    if (pid < 0) {
    483c:	02054c63          	bltz	a0,4874 <lazy_unmap+0x76>
    } else if (pid == 0) {
    4840:	c139                	beqz	a0,4886 <lazy_unmap+0x88>
      wait(&status);
    4842:	fcc40513          	addi	a0,s0,-52
    4846:	47f000ef          	jal	54c4 <wait>
      if (status == 0) {
    484a:	fcc42783          	lw	a5,-52(s0)
    484e:	c7a9                	beqz	a5,4898 <lazy_unmap+0x9a>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    4850:	994e                	add	s2,s2,s3
    4852:	fe9913e3          	bne	s2,s1,4838 <lazy_unmap+0x3a>
  exit(0);
    4856:	4501                	li	a0,0
    4858:	465000ef          	jal	54bc <exit>
    485c:	f426                	sd	s1,40(sp)
    485e:	f04a                	sd	s2,32(sp)
    4860:	ec4e                	sd	s3,24(sp)
    printf("sbrklazy() failed\n");
    4862:	00003517          	auipc	a0,0x3
    4866:	34e50513          	addi	a0,a0,846 # 7bb0 <malloc+0x2210>
    486a:	082010ef          	jal	58ec <printf>
    exit(1);
    486e:	4505                	li	a0,1
    4870:	44d000ef          	jal	54bc <exit>
      printf("error forking\n");
    4874:	00003517          	auipc	a0,0x3
    4878:	37c50513          	addi	a0,a0,892 # 7bf0 <malloc+0x2250>
    487c:	070010ef          	jal	58ec <printf>
      exit(1);
    4880:	4505                	li	a0,1
    4882:	43b000ef          	jal	54bc <exit>
      sbrklazy(-1L * REGION_SZ);
    4886:	c0000537          	lui	a0,0xc0000
    488a:	415000ef          	jal	549e <sbrklazy>
      *(char **)i = i;
    488e:	01293023          	sd	s2,0(s2) # 1000 <badarg>
      exit(0);
    4892:	4501                	li	a0,0
    4894:	429000ef          	jal	54bc <exit>
        printf("memory not unmapped\n");
    4898:	00003517          	auipc	a0,0x3
    489c:	36850513          	addi	a0,a0,872 # 7c00 <malloc+0x2260>
    48a0:	04c010ef          	jal	58ec <printf>
        exit(1);
    48a4:	4505                	li	a0,1
    48a6:	417000ef          	jal	54bc <exit>

00000000000048aa <lazy_copy>:
{
    48aa:	7159                	addi	sp,sp,-112
    48ac:	f486                	sd	ra,104(sp)
    48ae:	f0a2                	sd	s0,96(sp)
    48b0:	eca6                	sd	s1,88(sp)
    48b2:	e8ca                	sd	s2,80(sp)
    48b4:	e4ce                	sd	s3,72(sp)
    48b6:	e0d2                	sd	s4,64(sp)
    48b8:	fc56                	sd	s5,56(sp)
    48ba:	f85a                	sd	s6,48(sp)
    48bc:	1880                	addi	s0,sp,112
    char *p = sbrk(0);
    48be:	4501                	li	a0,0
    48c0:	3c9000ef          	jal	5488 <sbrk>
    48c4:	84aa                	mv	s1,a0
    sbrklazy(4 * PGSIZE);
    48c6:	6511                	lui	a0,0x4
    48c8:	3d7000ef          	jal	549e <sbrklazy>
    open(p + 8192, 0);
    48cc:	4581                	li	a1,0
    48ce:	6509                	lui	a0,0x2
    48d0:	9526                	add	a0,a0,s1
    48d2:	42b000ef          	jal	54fc <open>
    void *xx = sbrk(0);
    48d6:	4501                	li	a0,0
    48d8:	3b1000ef          	jal	5488 <sbrk>
    48dc:	84aa                	mv	s1,a0
    void *ret = sbrk(-(((uint64)xx) + 1));
    48de:	fff54513          	not	a0,a0
    48e2:	2501                	sext.w	a0,a0
    48e4:	3a5000ef          	jal	5488 <sbrk>
    if (ret != xx) {
    48e8:	00a48c63          	beq	s1,a0,4900 <lazy_copy+0x56>
    48ec:	85aa                	mv	a1,a0
      printf("sbrk(sbrk(0)+1) returned %p, not old sz\n", ret);
    48ee:	00003517          	auipc	a0,0x3
    48f2:	32a50513          	addi	a0,a0,810 # 7c18 <malloc+0x2278>
    48f6:	7f7000ef          	jal	58ec <printf>
      exit(1);
    48fa:	4505                	li	a0,1
    48fc:	3c1000ef          	jal	54bc <exit>
  unsigned long bad[] = {
    4900:	00004797          	auipc	a5,0x4
    4904:	ad078793          	addi	a5,a5,-1328 # 83d0 <malloc+0x2a30>
    4908:	7fa8                	ld	a0,120(a5)
    490a:	63cc                	ld	a1,128(a5)
    490c:	67d0                	ld	a2,136(a5)
    490e:	6bd4                	ld	a3,144(a5)
    4910:	6fd8                	ld	a4,152(a5)
    4912:	73dc                	ld	a5,160(a5)
    4914:	f8a43823          	sd	a0,-112(s0)
    4918:	f8b43c23          	sd	a1,-104(s0)
    491c:	fac43023          	sd	a2,-96(s0)
    4920:	fad43423          	sd	a3,-88(s0)
    4924:	fae43823          	sd	a4,-80(s0)
    4928:	faf43c23          	sd	a5,-72(s0)
  for (int i = 0; i < sizeof(bad) / sizeof(bad[0]); i++) {
    492c:	f9040913          	addi	s2,s0,-112
    4930:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
    4934:	00001a17          	auipc	s4,0x1
    4938:	37ca0a13          	addi	s4,s4,892 # 5cb0 <malloc+0x310>
    fd = open("junk", O_CREATE | O_RDWR | O_TRUNC);
    493c:	00001a97          	auipc	s5,0x1
    4940:	284a8a93          	addi	s5,s5,644 # 5bc0 <malloc+0x220>
    int fd = open("README", 0);
    4944:	4581                	li	a1,0
    4946:	8552                	mv	a0,s4
    4948:	3b5000ef          	jal	54fc <open>
    494c:	84aa                	mv	s1,a0
    if (fd < 0) {
    494e:	04054663          	bltz	a0,499a <lazy_copy+0xf0>
    if (read(fd, (char *)bad[i], 512) >= 0) {
    4952:	00093983          	ld	s3,0(s2)
    4956:	20000613          	li	a2,512
    495a:	85ce                	mv	a1,s3
    495c:	379000ef          	jal	54d4 <read>
    4960:	04055663          	bgez	a0,49ac <lazy_copy+0x102>
    close(fd);
    4964:	8526                	mv	a0,s1
    4966:	37f000ef          	jal	54e4 <close>
    fd = open("junk", O_CREATE | O_RDWR | O_TRUNC);
    496a:	60200593          	li	a1,1538
    496e:	8556                	mv	a0,s5
    4970:	38d000ef          	jal	54fc <open>
    4974:	84aa                	mv	s1,a0
    if (fd < 0) {
    4976:	04054463          	bltz	a0,49be <lazy_copy+0x114>
    if (write(fd, (char *)bad[i], 512) >= 0) {
    497a:	20000613          	li	a2,512
    497e:	85ce                	mv	a1,s3
    4980:	35d000ef          	jal	54dc <write>
    4984:	04055663          	bgez	a0,49d0 <lazy_copy+0x126>
    close(fd);
    4988:	8526                	mv	a0,s1
    498a:	35b000ef          	jal	54e4 <close>
  for (int i = 0; i < sizeof(bad) / sizeof(bad[0]); i++) {
    498e:	0921                	addi	s2,s2,8
    4990:	fb691ae3          	bne	s2,s6,4944 <lazy_copy+0x9a>
  exit(0);
    4994:	4501                	li	a0,0
    4996:	327000ef          	jal	54bc <exit>
      printf("cannot open README\n");
    499a:	00003517          	auipc	a0,0x3
    499e:	2ae50513          	addi	a0,a0,686 # 7c48 <malloc+0x22a8>
    49a2:	74b000ef          	jal	58ec <printf>
      exit(1);
    49a6:	4505                	li	a0,1
    49a8:	315000ef          	jal	54bc <exit>
      printf("read succeeded\n");
    49ac:	00003517          	auipc	a0,0x3
    49b0:	2b450513          	addi	a0,a0,692 # 7c60 <malloc+0x22c0>
    49b4:	739000ef          	jal	58ec <printf>
      exit(1);
    49b8:	4505                	li	a0,1
    49ba:	303000ef          	jal	54bc <exit>
      printf("cannot open junk\n");
    49be:	00003517          	auipc	a0,0x3
    49c2:	2b250513          	addi	a0,a0,690 # 7c70 <malloc+0x22d0>
    49c6:	727000ef          	jal	58ec <printf>
      exit(1);
    49ca:	4505                	li	a0,1
    49cc:	2f1000ef          	jal	54bc <exit>
      printf("write succeeded\n");
    49d0:	00003517          	auipc	a0,0x3
    49d4:	2b850513          	addi	a0,a0,696 # 7c88 <malloc+0x22e8>
    49d8:	715000ef          	jal	58ec <printf>
      exit(1);
    49dc:	4505                	li	a0,1
    49de:	2df000ef          	jal	54bc <exit>

00000000000049e2 <lazy_sbrk>:
{
    49e2:	1101                	addi	sp,sp,-32
    49e4:	ec06                	sd	ra,24(sp)
    49e6:	e822                	sd	s0,16(sp)
    49e8:	e426                	sd	s1,8(sp)
    49ea:	e04a                	sd	s2,0(sp)
    49ec:	1000                	addi	s0,sp,32
  char *p = sbrk(0);
    49ee:	4501                	li	a0,0
    49f0:	299000ef          	jal	5488 <sbrk>
    49f4:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA - (1 << 30)) {
    49f6:	0ff00793          	li	a5,255
    49fa:	07fa                	slli	a5,a5,0x1e
    49fc:	00f57d63          	bgeu	a0,a5,4a16 <lazy_sbrk+0x34>
    4a00:	893e                	mv	s2,a5
    p = sbrklazy(1 << 30);
    4a02:	40000537          	lui	a0,0x40000
    4a06:	299000ef          	jal	549e <sbrklazy>
    p = sbrklazy(0);
    4a0a:	4501                	li	a0,0
    4a0c:	293000ef          	jal	549e <sbrklazy>
    4a10:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA - (1 << 30)) {
    4a12:	ff2568e3          	bltu	a0,s2,4a02 <lazy_sbrk+0x20>
  int n = TRAPFRAME - PGSIZE - (uint64)p;
    4a16:	7975                	lui	s2,0xffffd
    4a18:	4099093b          	subw	s2,s2,s1
  char *p1 = sbrklazy(n);
    4a1c:	854a                	mv	a0,s2
    4a1e:	281000ef          	jal	549e <sbrklazy>
    4a22:	862a                	mv	a2,a0
  if (p1 < 0 || p1 != p) {
    4a24:	00950d63          	beq	a0,s1,4a3e <lazy_sbrk+0x5c>
    printf("sbrklazy(%d) returned %p, not expected %p\n", n, p1, p);
    4a28:	86a6                	mv	a3,s1
    4a2a:	85ca                	mv	a1,s2
    4a2c:	00003517          	auipc	a0,0x3
    4a30:	27450513          	addi	a0,a0,628 # 7ca0 <malloc+0x2300>
    4a34:	6b9000ef          	jal	58ec <printf>
    exit(1);
    4a38:	4505                	li	a0,1
    4a3a:	283000ef          	jal	54bc <exit>
  p = sbrk(PGSIZE);
    4a3e:	6505                	lui	a0,0x1
    4a40:	249000ef          	jal	5488 <sbrk>
    4a44:	862a                	mv	a2,a0
  if (p < 0 || (uint64)p != TRAPFRAME - PGSIZE) {
    4a46:	040007b7          	lui	a5,0x4000
    4a4a:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3ff0305>
    4a4c:	07b2                	slli	a5,a5,0xc
    4a4e:	00f50c63          	beq	a0,a5,4a66 <lazy_sbrk+0x84>
    printf("sbrk(%d) returned %p, not expected TRAPFRAME-PGSIZE\n", PGSIZE, p);
    4a52:	6585                	lui	a1,0x1
    4a54:	00003517          	auipc	a0,0x3
    4a58:	27c50513          	addi	a0,a0,636 # 7cd0 <malloc+0x2330>
    4a5c:	691000ef          	jal	58ec <printf>
    exit(1);
    4a60:	4505                	li	a0,1
    4a62:	25b000ef          	jal	54bc <exit>
  p[0] = 1;
    4a66:	040007b7          	lui	a5,0x4000
    4a6a:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3ff0305>
    4a6c:	07b2                	slli	a5,a5,0xc
    4a6e:	4705                	li	a4,1
    4a70:	00e78023          	sb	a4,0(a5)
  if (p[1] != 0) {
    4a74:	0017c783          	lbu	a5,1(a5)
    4a78:	cb91                	beqz	a5,4a8c <lazy_sbrk+0xaa>
    printf("sbrk() returned non-zero-filled memory\n");
    4a7a:	00003517          	auipc	a0,0x3
    4a7e:	28e50513          	addi	a0,a0,654 # 7d08 <malloc+0x2368>
    4a82:	66b000ef          	jal	58ec <printf>
    exit(1);
    4a86:	4505                	li	a0,1
    4a88:	235000ef          	jal	54bc <exit>
  p = sbrk(1);
    4a8c:	4505                	li	a0,1
    4a8e:	1fb000ef          	jal	5488 <sbrk>
    4a92:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4a94:	57fd                	li	a5,-1
    4a96:	00f50b63          	beq	a0,a5,4aac <lazy_sbrk+0xca>
    printf("sbrk(1) returned %p, expected error\n", p);
    4a9a:	00003517          	auipc	a0,0x3
    4a9e:	29650513          	addi	a0,a0,662 # 7d30 <malloc+0x2390>
    4aa2:	64b000ef          	jal	58ec <printf>
    exit(1);
    4aa6:	4505                	li	a0,1
    4aa8:	215000ef          	jal	54bc <exit>
  p = sbrklazy(1);
    4aac:	4505                	li	a0,1
    4aae:	1f1000ef          	jal	549e <sbrklazy>
    4ab2:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4ab4:	57fd                	li	a5,-1
    4ab6:	00f50b63          	beq	a0,a5,4acc <lazy_sbrk+0xea>
    printf("sbrklazy(1) returned %p, expected error\n", p);
    4aba:	00003517          	auipc	a0,0x3
    4abe:	29e50513          	addi	a0,a0,670 # 7d58 <malloc+0x23b8>
    4ac2:	62b000ef          	jal	58ec <printf>
    exit(1);
    4ac6:	4505                	li	a0,1
    4ac8:	1f5000ef          	jal	54bc <exit>
  exit(0);
    4acc:	4501                	li	a0,0
    4ace:	1ef000ef          	jal	54bc <exit>

0000000000004ad2 <lazy_copyinstr>:
{
    4ad2:	715d                	addi	sp,sp,-80
    4ad4:	e486                	sd	ra,72(sp)
    4ad6:	e0a2                	sd	s0,64(sp)
    4ad8:	fc26                	sd	s1,56(sp)
    4ada:	f84a                	sd	s2,48(sp)
    4adc:	f44e                	sd	s3,40(sp)
    4ade:	0880                	addi	s0,sp,80
    4ae0:	89aa                	mv	s3,a0
  char *p = sbrk(0);
    4ae2:	4501                	li	a0,0
    4ae4:	1a5000ef          	jal	5488 <sbrk>
  sbrk(PGSIZE - ((uint64)p % PGSIZE));
    4ae8:	6485                	lui	s1,0x1
    4aea:	14fd                	addi	s1,s1,-1 # fff <pgbug+0x2b>
    4aec:	009577b3          	and	a5,a0,s1
    4af0:	6505                	lui	a0,0x1
    4af2:	9d1d                	subw	a0,a0,a5
    4af4:	195000ef          	jal	5488 <sbrk>
  p = sbrk(0);
    4af8:	4501                	li	a0,0
    4afa:	18f000ef          	jal	5488 <sbrk>
  if ((uint64)p % PGSIZE != 0) {
    4afe:	8ce9                	and	s1,s1,a0
    4b00:	e8a9                	bnez	s1,4b52 <lazy_copyinstr+0x80>
    4b02:	892a                	mv	s2,a0
  sbrklazy(2 * PGSIZE);
    4b04:	6509                	lui	a0,0x2
    4b06:	199000ef          	jal	549e <sbrklazy>
  p[4095] = '/';
    4b0a:	6505                	lui	a0,0x1
    4b0c:	00a907b3          	add	a5,s2,a0
    4b10:	02f00713          	li	a4,47
    4b14:	fee78fa3          	sb	a4,-1(a5)
  int fd = open(&p[4095], O_RDONLY);
    4b18:	157d                	addi	a0,a0,-1 # fff <pgbug+0x2b>
    4b1a:	4581                	li	a1,0
    4b1c:	954a                	add	a0,a0,s2
    4b1e:	1df000ef          	jal	54fc <open>
    4b22:	84aa                	mv	s1,a0
  if (fd < 0) {
    4b24:	04054163          	bltz	a0,4b66 <lazy_copyinstr+0x94>
  int r = fstat(fd, &st);
    4b28:	fb840593          	addi	a1,s0,-72
    4b2c:	1e9000ef          	jal	5514 <fstat>
  if (r < 0) {
    4b30:	04054463          	bltz	a0,4b78 <lazy_copyinstr+0xa6>
  if (st.type != T_DIR) {
    4b34:	fc041703          	lh	a4,-64(s0)
    4b38:	4785                	li	a5,1
    4b3a:	04f71863          	bne	a4,a5,4b8a <lazy_copyinstr+0xb8>
  close(fd);
    4b3e:	8526                	mv	a0,s1
    4b40:	1a5000ef          	jal	54e4 <close>
}
    4b44:	60a6                	ld	ra,72(sp)
    4b46:	6406                	ld	s0,64(sp)
    4b48:	74e2                	ld	s1,56(sp)
    4b4a:	7942                	ld	s2,48(sp)
    4b4c:	79a2                	ld	s3,40(sp)
    4b4e:	6161                	addi	sp,sp,80
    4b50:	8082                	ret
    printf("%s: sbrk did not align\n", s);
    4b52:	85ce                	mv	a1,s3
    4b54:	00003517          	auipc	a0,0x3
    4b58:	fa450513          	addi	a0,a0,-92 # 7af8 <malloc+0x2158>
    4b5c:	591000ef          	jal	58ec <printf>
    exit(1);
    4b60:	4505                	li	a0,1
    4b62:	15b000ef          	jal	54bc <exit>
    printf("could not open /");
    4b66:	00003517          	auipc	a0,0x3
    4b6a:	22250513          	addi	a0,a0,546 # 7d88 <malloc+0x23e8>
    4b6e:	57f000ef          	jal	58ec <printf>
    exit(1);
    4b72:	4505                	li	a0,1
    4b74:	149000ef          	jal	54bc <exit>
    printf("could not stat /");
    4b78:	00003517          	auipc	a0,0x3
    4b7c:	22850513          	addi	a0,a0,552 # 7da0 <malloc+0x2400>
    4b80:	56d000ef          	jal	58ec <printf>
    exit(1);
    4b84:	4505                	li	a0,1
    4b86:	137000ef          	jal	54bc <exit>
    printf("/ is not T_DIR");
    4b8a:	00003517          	auipc	a0,0x3
    4b8e:	22e50513          	addi	a0,a0,558 # 7db8 <malloc+0x2418>
    4b92:	55b000ef          	jal	58ec <printf>
    exit(1);
    4b96:	4505                	li	a0,1
    4b98:	125000ef          	jal	54bc <exit>

0000000000004b9c <fsfull>:
{
    4b9c:	7171                	addi	sp,sp,-176
    4b9e:	f506                	sd	ra,168(sp)
    4ba0:	f122                	sd	s0,160(sp)
    4ba2:	ed26                	sd	s1,152(sp)
    4ba4:	e94a                	sd	s2,144(sp)
    4ba6:	e54e                	sd	s3,136(sp)
    4ba8:	e152                	sd	s4,128(sp)
    4baa:	fcd6                	sd	s5,120(sp)
    4bac:	f8da                	sd	s6,112(sp)
    4bae:	f4de                	sd	s7,104(sp)
    4bb0:	f0e2                	sd	s8,96(sp)
    4bb2:	ece6                	sd	s9,88(sp)
    4bb4:	e8ea                	sd	s10,80(sp)
    4bb6:	e4ee                	sd	s11,72(sp)
    4bb8:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4bba:	00003517          	auipc	a0,0x3
    4bbe:	20e50513          	addi	a0,a0,526 # 7dc8 <malloc+0x2428>
    4bc2:	52b000ef          	jal	58ec <printf>
  int fsblocks = 0;
    4bc6:	4a81                	li	s5,0
  for (nfiles = 0;; nfiles++) {
    4bc8:	4481                	li	s1,0
    name[0] = 'f';
    4bca:	06600d93          	li	s11,102
    name[1] = '0' + nfiles / 1000;
    4bce:	3e800c93          	li	s9,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4bd2:	06400c13          	li	s8,100
    name[3] = '0' + (nfiles % 100) / 10;
    4bd6:	4ba9                	li	s7,10
    printf("writing %s\n", name);
    4bd8:	00003d17          	auipc	s10,0x3
    4bdc:	200d0d13          	addi	s10,s10,512 # 7dd8 <malloc+0x2438>
    name[0] = 'f';
    4be0:	f5b40823          	sb	s11,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4be4:	0394c7bb          	divw	a5,s1,s9
    4be8:	0307879b          	addiw	a5,a5,48
    4bec:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4bf0:	0394e7bb          	remw	a5,s1,s9
    4bf4:	0387c7bb          	divw	a5,a5,s8
    4bf8:	0307879b          	addiw	a5,a5,48
    4bfc:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c00:	0384e7bb          	remw	a5,s1,s8
    4c04:	0377c7bb          	divw	a5,a5,s7
    4c08:	0307879b          	addiw	a5,a5,48
    4c0c:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c10:	0374e7bb          	remw	a5,s1,s7
    4c14:	0307879b          	addiw	a5,a5,48
    4c18:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c1c:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4c20:	f5040593          	addi	a1,s0,-176
    4c24:	856a                	mv	a0,s10
    4c26:	4c7000ef          	jal	58ec <printf>
    int fd = open(name, O_CREATE | O_RDWR);
    4c2a:	20200593          	li	a1,514
    4c2e:	f5040513          	addi	a0,s0,-176
    4c32:	0cb000ef          	jal	54fc <open>
    4c36:	892a                	mv	s2,a0
    if (fd < 0) {
    4c38:	0a055163          	bgez	a0,4cda <fsfull+0x13e>
      printf("open %s failed\n", name);
    4c3c:	f5040593          	addi	a1,s0,-176
    4c40:	00003517          	auipc	a0,0x3
    4c44:	1a850513          	addi	a0,a0,424 # 7de8 <malloc+0x2448>
    4c48:	4a5000ef          	jal	58ec <printf>
  while (nfiles >= 0) {
    4c4c:	0604c163          	bltz	s1,4cae <fsfull+0x112>
    name[0] = 'f';
    4c50:	06600b93          	li	s7,102
    name[1] = '0' + nfiles / 1000;
    4c54:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4c58:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4c5c:	4929                	li	s2,10
  while (nfiles >= 0) {
    4c5e:	5b7d                	li	s6,-1
    name[0] = 'f';
    4c60:	f5740823          	sb	s7,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c64:	0344c7bb          	divw	a5,s1,s4
    4c68:	0307879b          	addiw	a5,a5,48
    4c6c:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c70:	0344e7bb          	remw	a5,s1,s4
    4c74:	0337c7bb          	divw	a5,a5,s3
    4c78:	0307879b          	addiw	a5,a5,48
    4c7c:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c80:	0334e7bb          	remw	a5,s1,s3
    4c84:	0327c7bb          	divw	a5,a5,s2
    4c88:	0307879b          	addiw	a5,a5,48
    4c8c:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c90:	0324e7bb          	remw	a5,s1,s2
    4c94:	0307879b          	addiw	a5,a5,48
    4c98:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c9c:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4ca0:	f5040513          	addi	a0,s0,-176
    4ca4:	069000ef          	jal	550c <unlink>
    nfiles--;
    4ca8:	34fd                	addiw	s1,s1,-1
  while (nfiles >= 0) {
    4caa:	fb649be3          	bne	s1,s6,4c60 <fsfull+0xc4>
  printf("fsfull test finished, %d blocks\n", fsblocks);
    4cae:	85d6                	mv	a1,s5
    4cb0:	00003517          	auipc	a0,0x3
    4cb4:	15850513          	addi	a0,a0,344 # 7e08 <malloc+0x2468>
    4cb8:	435000ef          	jal	58ec <printf>
}
    4cbc:	70aa                	ld	ra,168(sp)
    4cbe:	740a                	ld	s0,160(sp)
    4cc0:	64ea                	ld	s1,152(sp)
    4cc2:	694a                	ld	s2,144(sp)
    4cc4:	69aa                	ld	s3,136(sp)
    4cc6:	6a0a                	ld	s4,128(sp)
    4cc8:	7ae6                	ld	s5,120(sp)
    4cca:	7b46                	ld	s6,112(sp)
    4ccc:	7ba6                	ld	s7,104(sp)
    4cce:	7c06                	ld	s8,96(sp)
    4cd0:	6ce6                	ld	s9,88(sp)
    4cd2:	6d46                	ld	s10,80(sp)
    4cd4:	6da6                	ld	s11,72(sp)
    4cd6:	614d                	addi	sp,sp,176
    4cd8:	8082                	ret
    int total = 0;
    4cda:	4981                	li	s3,0
      int cc = write(fd, buf, BSIZE);
    4cdc:	00008b17          	auipc	s6,0x8
    4ce0:	01cb0b13          	addi	s6,s6,28 # ccf8 <buf>
      if (cc < BSIZE)
    4ce4:	3ff00a13          	li	s4,1023
      int cc = write(fd, buf, BSIZE);
    4ce8:	40000613          	li	a2,1024
    4cec:	85da                	mv	a1,s6
    4cee:	854a                	mv	a0,s2
    4cf0:	7ec000ef          	jal	54dc <write>
      if (cc < BSIZE)
    4cf4:	00aa5663          	bge	s4,a0,4d00 <fsfull+0x164>
      total += cc;
    4cf8:	00a989bb          	addw	s3,s3,a0
      fsblocks++;
    4cfc:	2a85                	addiw	s5,s5,1
    while (1) {
    4cfe:	b7ed                	j	4ce8 <fsfull+0x14c>
    printf("wrote %d bytes\n", total);
    4d00:	85ce                	mv	a1,s3
    4d02:	00003517          	auipc	a0,0x3
    4d06:	0f650513          	addi	a0,a0,246 # 7df8 <malloc+0x2458>
    4d0a:	3e3000ef          	jal	58ec <printf>
    close(fd);
    4d0e:	854a                	mv	a0,s2
    4d10:	7d4000ef          	jal	54e4 <close>
    if (total == 0)
    4d14:	f2098ce3          	beqz	s3,4c4c <fsfull+0xb0>
  for (nfiles = 0;; nfiles++) {
    4d18:	2485                	addiw	s1,s1,1
    4d1a:	b5d9                	j	4be0 <fsfull+0x44>

0000000000004d1c <linkoverflow>:

void
linkoverflow(char *s)
{
    4d1c:	7175                	addi	sp,sp,-144
    4d1e:	e506                	sd	ra,136(sp)
    4d20:	e122                	sd	s0,128(sp)
    4d22:	fca6                	sd	s1,120(sp)
    4d24:	f8ca                	sd	s2,112(sp)
    4d26:	f4ce                	sd	s3,104(sp)
    4d28:	f0d2                	sd	s4,96(sp)
    4d2a:	ecd6                	sd	s5,88(sp)
    4d2c:	e8da                	sd	s6,80(sp)
    4d2e:	e4de                	sd	s7,72(sp)
    4d30:	e0e2                	sd	s8,64(sp)
    4d32:	fc66                	sd	s9,56(sp)
    4d34:	f86a                	sd	s10,48(sp)
    4d36:	0900                	addi	s0,sp,144
    4d38:	8caa                	mv	s9,a0
  enum { TARGET = 32768 };
  enum { DIRS = 64 };
  struct stat st;
  int i;

  unlink("/lof");
    4d3a:	00003517          	auipc	a0,0x3
    4d3e:	0f650513          	addi	a0,a0,246 # 7e30 <malloc+0x2490>
    4d42:	7ca000ef          	jal	550c <unlink>
  int fd = open("/lof", O_CREATE | O_RDWR);
    4d46:	20200593          	li	a1,514
    4d4a:	00003517          	auipc	a0,0x3
    4d4e:	0e650513          	addi	a0,a0,230 # 7e30 <malloc+0x2490>
    4d52:	7aa000ef          	jal	54fc <open>
  if (fd < 0) {
    4d56:	02054863          	bltz	a0,4d86 <linkoverflow+0x6a>
    printf("%s: cannot create /lof\n", s);
    exit(1);
  }
  close(fd);
    4d5a:	78a000ef          	jal	54e4 <close>

  for (i = 0; i < TARGET; i++) {
    4d5e:	4901                	li	s2,0
    int d = i % DIRS;
    int f = i / DIRS;

    char pn[16];
    pn[0] = '/';
    4d60:	02f00993          	li	s3,47
    pn[1] = 'd';
    4d64:	06400a93          	li	s5,100
    pn[2] = '_';
    4d68:	05f00a13          	li	s4,95
      printf("%s: mkdir(%s) failed\n", s, pn);
      exit(1);
    }

    pn[5] = '/';
    pn[6] = 'l';
    4d6c:	06c00b93          	li	s7,108
    pn[7] = 'a' + (f / 256);
    pn[8] = 'a' + ((f / 16) % 16);
    pn[9] = 'a' + (f % 16);
    pn[10] = '\0';

    if (link("/lof", pn) < 0) {
    4d70:	00003b17          	auipc	s6,0x3
    4d74:	0c0b0b13          	addi	s6,s6,192 # 7e30 <malloc+0x2490>
      }
      printf("%s: link failed after %d links (nlink=%d)\n", s, i, st.nlink);
      exit(1);
    }

    if (i % 100 == 0) {
    4d78:	06400c13          	li	s8,100
      printf("%s: i=%d, pn=%s\n", s, i, pn);
    4d7c:	00003d17          	auipc	s10,0x3
    4d80:	134d0d13          	addi	s10,s10,308 # 7eb0 <malloc+0x2510>
    4d84:	a061                	j	4e0c <linkoverflow+0xf0>
    printf("%s: cannot create /lof\n", s);
    4d86:	85e6                	mv	a1,s9
    4d88:	00003517          	auipc	a0,0x3
    4d8c:	0b050513          	addi	a0,a0,176 # 7e38 <malloc+0x2498>
    4d90:	35d000ef          	jal	58ec <printf>
    exit(1);
    4d94:	4505                	li	a0,1
    4d96:	726000ef          	jal	54bc <exit>
    pn[5] = '/';
    4d9a:	f7340ea3          	sb	s3,-131(s0)
    pn[6] = 'l';
    4d9e:	f7740f23          	sb	s7,-130(s0)
    pn[7] = 'a' + (f / 256);
    4da2:	41f9579b          	sraiw	a5,s2,0x1f
    4da6:	0127d79b          	srliw	a5,a5,0x12
    4daa:	012787bb          	addw	a5,a5,s2
    4dae:	40e7d79b          	sraiw	a5,a5,0xe
    4db2:	0617879b          	addiw	a5,a5,97
    4db6:	f6f40fa3          	sb	a5,-129(s0)
    pn[8] = 'a' + ((f / 16) % 16);
    4dba:	41f4d71b          	sraiw	a4,s1,0x1f
    4dbe:	01c7571b          	srliw	a4,a4,0x1c
    4dc2:	9cb9                	addw	s1,s1,a4
    4dc4:	4044d79b          	sraiw	a5,s1,0x4
    4dc8:	41f4d69b          	sraiw	a3,s1,0x1f
    4dcc:	01c6d69b          	srliw	a3,a3,0x1c
    4dd0:	9fb5                	addw	a5,a5,a3
    4dd2:	8bbd                	andi	a5,a5,15
    4dd4:	9f95                	subw	a5,a5,a3
    4dd6:	0617879b          	addiw	a5,a5,97
    4dda:	f8f40023          	sb	a5,-128(s0)
    pn[9] = 'a' + (f % 16);
    4dde:	88bd                	andi	s1,s1,15
    4de0:	9c99                	subw	s1,s1,a4
    4de2:	0614849b          	addiw	s1,s1,97
    4de6:	f89400a3          	sb	s1,-127(s0)
    pn[10] = '\0';
    4dea:	f8040123          	sb	zero,-126(s0)
    if (link("/lof", pn) < 0) {
    4dee:	f7840593          	addi	a1,s0,-136
    4df2:	855a                	mv	a0,s6
    4df4:	728000ef          	jal	551c <link>
    4df8:	08054363          	bltz	a0,4e7e <linkoverflow+0x162>
    if (i % 100 == 0) {
    4dfc:	038967bb          	remw	a5,s2,s8
    4e00:	10078663          	beqz	a5,4f0c <linkoverflow+0x1f0>
  for (i = 0; i < TARGET; i++) {
    4e04:	2905                	addiw	s2,s2,1 # ffffffffffffd001 <base+0xfffffffffffed309>
    4e06:	67a1                	lui	a5,0x8
    4e08:	08f90b63          	beq	s2,a5,4e9e <linkoverflow+0x182>
    int d = i % DIRS;
    4e0c:	41f9571b          	sraiw	a4,s2,0x1f
    4e10:	01a7571b          	srliw	a4,a4,0x1a
    4e14:	012704bb          	addw	s1,a4,s2
    4e18:	03f4f793          	andi	a5,s1,63
    4e1c:	9f99                	subw	a5,a5,a4
    int f = i / DIRS;
    4e1e:	4064d49b          	sraiw	s1,s1,0x6
    4e22:	0004861b          	sext.w	a2,s1
    pn[0] = '/';
    4e26:	f7340c23          	sb	s3,-136(s0)
    pn[1] = 'd';
    4e2a:	f7540ca3          	sb	s5,-135(s0)
    pn[2] = '_';
    4e2e:	f7440d23          	sb	s4,-134(s0)
    pn[3] = 'a' + (d / 16);
    4e32:	41f7d71b          	sraiw	a4,a5,0x1f
    4e36:	01c7571b          	srliw	a4,a4,0x1c
    4e3a:	9fb9                	addw	a5,a5,a4
    4e3c:	4047d69b          	sraiw	a3,a5,0x4
    4e40:	0616869b          	addiw	a3,a3,97 # 40061 <base+0x30369>
    4e44:	f6d40da3          	sb	a3,-133(s0)
    pn[4] = 'a' + (d % 16);
    4e48:	8bbd                	andi	a5,a5,15
    4e4a:	9f99                	subw	a5,a5,a4
    4e4c:	0617879b          	addiw	a5,a5,97 # 8061 <malloc+0x26c1>
    4e50:	f6f40e23          	sb	a5,-132(s0)
    pn[5] = '\0';
    4e54:	f6040ea3          	sb	zero,-131(s0)
    if (f == 0 && mkdir(pn) < 0) {
    4e58:	f229                	bnez	a2,4d9a <linkoverflow+0x7e>
    4e5a:	f7840513          	addi	a0,s0,-136
    4e5e:	6c6000ef          	jal	5524 <mkdir>
    4e62:	f2055ce3          	bgez	a0,4d9a <linkoverflow+0x7e>
      printf("%s: mkdir(%s) failed\n", s, pn);
    4e66:	f7840613          	addi	a2,s0,-136
    4e6a:	85e6                	mv	a1,s9
    4e6c:	00003517          	auipc	a0,0x3
    4e70:	fe450513          	addi	a0,a0,-28 # 7e50 <malloc+0x24b0>
    4e74:	279000ef          	jal	58ec <printf>
      exit(1);
    4e78:	4505                	li	a0,1
    4e7a:	642000ef          	jal	54bc <exit>
      if (stat("/lof", &st) < 0) {
    4e7e:	f8840593          	addi	a1,s0,-120
    4e82:	00003517          	auipc	a0,0x3
    4e86:	fae50513          	addi	a0,a0,-82 # 7e30 <malloc+0x2490>
    4e8a:	4d6000ef          	jal	5360 <stat>
    4e8e:	04054a63          	bltz	a0,4ee2 <linkoverflow+0x1c6>
      if (st.nlink >= 32767) {
    4e92:	f9241683          	lh	a3,-110(s0)
    4e96:	67a1                	lui	a5,0x8
    4e98:	17fd                	addi	a5,a5,-1 # 7fff <malloc+0x265f>
    4e9a:	04f69e63          	bne	a3,a5,4ef6 <linkoverflow+0x1da>
    }
  }

  if (stat("/lof", &st) < 0) {
    4e9e:	f8840593          	addi	a1,s0,-120
    4ea2:	00003517          	auipc	a0,0x3
    4ea6:	f8e50513          	addi	a0,a0,-114 # 7e30 <malloc+0x2490>
    4eaa:	4b6000ef          	jal	5360 <stat>
    4eae:	06054763          	bltz	a0,4f1c <linkoverflow+0x200>
    printf("%s: stat(/lof) failed\n", s);
    exit(1);
  }

  unlink("/lof");
    4eb2:	00003517          	auipc	a0,0x3
    4eb6:	f7e50513          	addi	a0,a0,-130 # 7e30 <malloc+0x2490>
    4eba:	652000ef          	jal	550c <unlink>

  if (st.nlink < 0) {
    4ebe:	f9241603          	lh	a2,-110(s0)
    4ec2:	06064763          	bltz	a2,4f30 <linkoverflow+0x214>
    printf("%s: negative link count: %d\n", s, st.nlink);
    exit(1);
  }
}
    4ec6:	60aa                	ld	ra,136(sp)
    4ec8:	640a                	ld	s0,128(sp)
    4eca:	74e6                	ld	s1,120(sp)
    4ecc:	7946                	ld	s2,112(sp)
    4ece:	79a6                	ld	s3,104(sp)
    4ed0:	7a06                	ld	s4,96(sp)
    4ed2:	6ae6                	ld	s5,88(sp)
    4ed4:	6b46                	ld	s6,80(sp)
    4ed6:	6ba6                	ld	s7,72(sp)
    4ed8:	6c06                	ld	s8,64(sp)
    4eda:	7ce2                	ld	s9,56(sp)
    4edc:	7d42                	ld	s10,48(sp)
    4ede:	6149                	addi	sp,sp,144
    4ee0:	8082                	ret
        printf("%s: stat(/lof) failed\n", s);
    4ee2:	85e6                	mv	a1,s9
    4ee4:	00003517          	auipc	a0,0x3
    4ee8:	f8450513          	addi	a0,a0,-124 # 7e68 <malloc+0x24c8>
    4eec:	201000ef          	jal	58ec <printf>
        exit(1);
    4ef0:	4505                	li	a0,1
    4ef2:	5ca000ef          	jal	54bc <exit>
      printf("%s: link failed after %d links (nlink=%d)\n", s, i, st.nlink);
    4ef6:	864a                	mv	a2,s2
    4ef8:	85e6                	mv	a1,s9
    4efa:	00003517          	auipc	a0,0x3
    4efe:	f8650513          	addi	a0,a0,-122 # 7e80 <malloc+0x24e0>
    4f02:	1eb000ef          	jal	58ec <printf>
      exit(1);
    4f06:	4505                	li	a0,1
    4f08:	5b4000ef          	jal	54bc <exit>
      printf("%s: i=%d, pn=%s\n", s, i, pn);
    4f0c:	f7840693          	addi	a3,s0,-136
    4f10:	864a                	mv	a2,s2
    4f12:	85e6                	mv	a1,s9
    4f14:	856a                	mv	a0,s10
    4f16:	1d7000ef          	jal	58ec <printf>
    4f1a:	b5ed                	j	4e04 <linkoverflow+0xe8>
    printf("%s: stat(/lof) failed\n", s);
    4f1c:	85e6                	mv	a1,s9
    4f1e:	00003517          	auipc	a0,0x3
    4f22:	f4a50513          	addi	a0,a0,-182 # 7e68 <malloc+0x24c8>
    4f26:	1c7000ef          	jal	58ec <printf>
    exit(1);
    4f2a:	4505                	li	a0,1
    4f2c:	590000ef          	jal	54bc <exit>
    printf("%s: negative link count: %d\n", s, st.nlink);
    4f30:	85e6                	mv	a1,s9
    4f32:	00003517          	auipc	a0,0x3
    4f36:	f9650513          	addi	a0,a0,-106 # 7ec8 <malloc+0x2528>
    4f3a:	1b3000ef          	jal	58ec <printf>
    exit(1);
    4f3e:	4505                	li	a0,1
    4f40:	57c000ef          	jal	54bc <exit>

0000000000004f44 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s)
{
    4f44:	7179                	addi	sp,sp,-48
    4f46:	f406                	sd	ra,40(sp)
    4f48:	f022                	sd	s0,32(sp)
    4f4a:	ec26                	sd	s1,24(sp)
    4f4c:	e84a                	sd	s2,16(sp)
    4f4e:	1800                	addi	s0,sp,48
    4f50:	84aa                	mv	s1,a0
    4f52:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4f54:	00003517          	auipc	a0,0x3
    4f58:	f9450513          	addi	a0,a0,-108 # 7ee8 <malloc+0x2548>
    4f5c:	191000ef          	jal	58ec <printf>
  if ((pid = fork()) < 0) {
    4f60:	554000ef          	jal	54b4 <fork>
    4f64:	02054a63          	bltz	a0,4f98 <run+0x54>
    printf("runtest: fork error\n");
    exit(1);
  }
  if (pid == 0) {
    4f68:	c129                	beqz	a0,4faa <run+0x66>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4f6a:	fdc40513          	addi	a0,s0,-36
    4f6e:	556000ef          	jal	54c4 <wait>
    if (xstatus != 0)
    4f72:	fdc42783          	lw	a5,-36(s0)
    4f76:	cf9d                	beqz	a5,4fb4 <run+0x70>
      printf("FAILED\n");
    4f78:	00003517          	auipc	a0,0x3
    4f7c:	f9850513          	addi	a0,a0,-104 # 7f10 <malloc+0x2570>
    4f80:	16d000ef          	jal	58ec <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    4f84:	fdc42503          	lw	a0,-36(s0)
  }
}
    4f88:	00153513          	seqz	a0,a0
    4f8c:	70a2                	ld	ra,40(sp)
    4f8e:	7402                	ld	s0,32(sp)
    4f90:	64e2                	ld	s1,24(sp)
    4f92:	6942                	ld	s2,16(sp)
    4f94:	6145                	addi	sp,sp,48
    4f96:	8082                	ret
    printf("runtest: fork error\n");
    4f98:	00003517          	auipc	a0,0x3
    4f9c:	f6050513          	addi	a0,a0,-160 # 7ef8 <malloc+0x2558>
    4fa0:	14d000ef          	jal	58ec <printf>
    exit(1);
    4fa4:	4505                	li	a0,1
    4fa6:	516000ef          	jal	54bc <exit>
    f(s);
    4faa:	854a                	mv	a0,s2
    4fac:	9482                	jalr	s1
    exit(0);
    4fae:	4501                	li	a0,0
    4fb0:	50c000ef          	jal	54bc <exit>
      printf("OK\n");
    4fb4:	00003517          	auipc	a0,0x3
    4fb8:	f6450513          	addi	a0,a0,-156 # 7f18 <malloc+0x2578>
    4fbc:	131000ef          	jal	58ec <printf>
    4fc0:	b7d1                	j	4f84 <run+0x40>

0000000000004fc2 <runtests>:

int
runtests(struct test *tests, char *justone, int continuous)
{
    4fc2:	7139                	addi	sp,sp,-64
    4fc4:	fc06                	sd	ra,56(sp)
    4fc6:	f822                	sd	s0,48(sp)
    4fc8:	f426                	sd	s1,40(sp)
    4fca:	ec4e                	sd	s3,24(sp)
    4fcc:	0080                	addi	s0,sp,64
    4fce:	84aa                	mv	s1,a0
  int ntests = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    4fd0:	6508                	ld	a0,8(a0)
    4fd2:	cd39                	beqz	a0,5030 <runtests+0x6e>
    4fd4:	f04a                	sd	s2,32(sp)
    4fd6:	e852                	sd	s4,16(sp)
    4fd8:	e456                	sd	s5,8(sp)
    4fda:	892e                	mv	s2,a1
    4fdc:	8a32                	mv	s4,a2
  int ntests = 0;
    4fde:	4981                	li	s3,0
    if ((justone == 0) || strcmp(t->s, justone) == 0) {
      ntests++;
      if (!run(t->f, t->s)) {
        if (continuous != 2) {
    4fe0:	4a89                	li	s5,2
    4fe2:	a021                	j	4fea <runtests+0x28>
  for (struct test *t = tests; t->s != 0; t++) {
    4fe4:	04c1                	addi	s1,s1,16
    4fe6:	6488                	ld	a0,8(s1)
    4fe8:	c915                	beqz	a0,501c <runtests+0x5a>
    if ((justone == 0) || strcmp(t->s, justone) == 0) {
    4fea:	00090663          	beqz	s2,4ff6 <runtests+0x34>
    4fee:	85ca                	mv	a1,s2
    4ff0:	264000ef          	jal	5254 <strcmp>
    4ff4:	f965                	bnez	a0,4fe4 <runtests+0x22>
      ntests++;
    4ff6:	2985                	addiw	s3,s3,1 # 1000001 <base+0xff0309>
      if (!run(t->f, t->s)) {
    4ff8:	648c                	ld	a1,8(s1)
    4ffa:	6088                	ld	a0,0(s1)
    4ffc:	f49ff0ef          	jal	4f44 <run>
    5000:	f175                	bnez	a0,4fe4 <runtests+0x22>
        if (continuous != 2) {
    5002:	ff5a01e3          	beq	s4,s5,4fe4 <runtests+0x22>
          printf("SOME TESTS FAILED\n");
    5006:	00003517          	auipc	a0,0x3
    500a:	f1a50513          	addi	a0,a0,-230 # 7f20 <malloc+0x2580>
    500e:	0df000ef          	jal	58ec <printf>
          return -1;
    5012:	59fd                	li	s3,-1
    5014:	7902                	ld	s2,32(sp)
    5016:	6a42                	ld	s4,16(sp)
    5018:	6aa2                	ld	s5,8(sp)
    501a:	a021                	j	5022 <runtests+0x60>
    501c:	7902                	ld	s2,32(sp)
    501e:	6a42                	ld	s4,16(sp)
    5020:	6aa2                	ld	s5,8(sp)
        }
      }
    }
  }
  return ntests;
}
    5022:	854e                	mv	a0,s3
    5024:	70e2                	ld	ra,56(sp)
    5026:	7442                	ld	s0,48(sp)
    5028:	74a2                	ld	s1,40(sp)
    502a:	69e2                	ld	s3,24(sp)
    502c:	6121                	addi	sp,sp,64
    502e:	8082                	ret
  return ntests;
    5030:	4981                	li	s3,0
    5032:	bfc5                	j	5022 <runtests+0x60>

0000000000005034 <countfree>:

// use sbrk() to count how many free physical memory pages there are.
int
countfree()
{
    5034:	7179                	addi	sp,sp,-48
    5036:	f406                	sd	ra,40(sp)
    5038:	f022                	sd	s0,32(sp)
    503a:	ec26                	sd	s1,24(sp)
    503c:	e84a                	sd	s2,16(sp)
    503e:	e44e                	sd	s3,8(sp)
    5040:	1800                	addi	s0,sp,48
  int n = 0;
  uint64 sz0 = (uint64)sbrk(0);
    5042:	4501                	li	a0,0
    5044:	444000ef          	jal	5488 <sbrk>
    5048:	89aa                	mv	s3,a0
  int n = 0;
    504a:	4481                	li	s1,0
  while (1) {
    char *a = sbrk(PGSIZE);
    if (a == SBRK_ERROR) {
    504c:	597d                	li	s2,-1
    504e:	a011                	j	5052 <countfree+0x1e>
      break;
    }
    n += 1;
    5050:	2485                	addiw	s1,s1,1
    char *a = sbrk(PGSIZE);
    5052:	6505                	lui	a0,0x1
    5054:	434000ef          	jal	5488 <sbrk>
    if (a == SBRK_ERROR) {
    5058:	ff251ce3          	bne	a0,s2,5050 <countfree+0x1c>
  }
  sbrk(-((uint64)sbrk(0) - sz0));
    505c:	4501                	li	a0,0
    505e:	42a000ef          	jal	5488 <sbrk>
    5062:	40a9853b          	subw	a0,s3,a0
    5066:	422000ef          	jal	5488 <sbrk>
  return n;
}
    506a:	8526                	mv	a0,s1
    506c:	70a2                	ld	ra,40(sp)
    506e:	7402                	ld	s0,32(sp)
    5070:	64e2                	ld	s1,24(sp)
    5072:	6942                	ld	s2,16(sp)
    5074:	69a2                	ld	s3,8(sp)
    5076:	6145                	addi	sp,sp,48
    5078:	8082                	ret

000000000000507a <drivetests>:

int
drivetests(int quick, int continuous, char *justone)
{
    507a:	7159                	addi	sp,sp,-112
    507c:	f486                	sd	ra,104(sp)
    507e:	f0a2                	sd	s0,96(sp)
    5080:	eca6                	sd	s1,88(sp)
    5082:	e8ca                	sd	s2,80(sp)
    5084:	e4ce                	sd	s3,72(sp)
    5086:	e0d2                	sd	s4,64(sp)
    5088:	fc56                	sd	s5,56(sp)
    508a:	f85a                	sd	s6,48(sp)
    508c:	f45e                	sd	s7,40(sp)
    508e:	f062                	sd	s8,32(sp)
    5090:	ec66                	sd	s9,24(sp)
    5092:	e86a                	sd	s10,16(sp)
    5094:	e46e                	sd	s11,8(sp)
    5096:	1880                	addi	s0,sp,112
    5098:	8aaa                	mv	s5,a0
    509a:	89ae                	mv	s3,a1
    509c:	8a32                	mv	s4,a2
  do {
    printf("usertests starting\n");
    509e:	00003c17          	auipc	s8,0x3
    50a2:	e9ac0c13          	addi	s8,s8,-358 # 7f38 <malloc+0x2598>
    int free0 = countfree();
    int free1 = 0;
    int ntests = 0;
    int n;
    n = runtests(quicktests, justone, continuous);
    50a6:	00004b97          	auipc	s7,0x4
    50aa:	f6ab8b93          	addi	s7,s7,-150 # 9010 <quicktests>
    if (n < 0) {
      if (continuous != 2) {
    50ae:	4b09                	li	s6,2
      ntests += n;
    }
    if (!quick) {
      if (justone == 0)
        printf("usertests slow tests starting\n");
      n = runtests(slowtests, justone, continuous);
    50b0:	00004c97          	auipc	s9,0x4
    50b4:	3b0c8c93          	addi	s9,s9,944 # 9460 <slowtests>
        printf("usertests slow tests starting\n");
    50b8:	00003d97          	auipc	s11,0x3
    50bc:	e98d8d93          	addi	s11,s11,-360 # 7f50 <malloc+0x25b0>
      } else {
        ntests += n;
      }
    }
    if ((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    50c0:	00003d17          	auipc	s10,0x3
    50c4:	eb0d0d13          	addi	s10,s10,-336 # 7f70 <malloc+0x25d0>
    50c8:	a025                	j	50f0 <drivetests+0x76>
      if (continuous != 2) {
    50ca:	09699063          	bne	s3,s6,514a <drivetests+0xd0>
    int ntests = 0;
    50ce:	4481                	li	s1,0
    50d0:	a835                	j	510c <drivetests+0x92>
        printf("usertests slow tests starting\n");
    50d2:	856e                	mv	a0,s11
    50d4:	019000ef          	jal	58ec <printf>
    50d8:	a835                	j	5114 <drivetests+0x9a>
        if (continuous != 2) {
    50da:	07699a63          	bne	s3,s6,514e <drivetests+0xd4>
    if ((free1 = countfree()) < free0) {
    50de:	f57ff0ef          	jal	5034 <countfree>
    50e2:	05254263          	blt	a0,s2,5126 <drivetests+0xac>
      if (continuous != 2) {
        return 1;
      }
    }
    if (justone != 0 && ntests == 0) {
    50e6:	000a0363          	beqz	s4,50ec <drivetests+0x72>
    50ea:	c8a1                	beqz	s1,513a <drivetests+0xc0>
      printf("NO TESTS EXECUTED\n");
      return 1;
    }
  } while (continuous);
    50ec:	06098563          	beqz	s3,5156 <drivetests+0xdc>
    printf("usertests starting\n");
    50f0:	8562                	mv	a0,s8
    50f2:	7fa000ef          	jal	58ec <printf>
    int free0 = countfree();
    50f6:	f3fff0ef          	jal	5034 <countfree>
    50fa:	892a                	mv	s2,a0
    n = runtests(quicktests, justone, continuous);
    50fc:	864e                	mv	a2,s3
    50fe:	85d2                	mv	a1,s4
    5100:	855e                	mv	a0,s7
    5102:	ec1ff0ef          	jal	4fc2 <runtests>
    5106:	84aa                	mv	s1,a0
    if (n < 0) {
    5108:	fc0541e3          	bltz	a0,50ca <drivetests+0x50>
    if (!quick) {
    510c:	fc0a99e3          	bnez	s5,50de <drivetests+0x64>
      if (justone == 0)
    5110:	fc0a01e3          	beqz	s4,50d2 <drivetests+0x58>
      n = runtests(slowtests, justone, continuous);
    5114:	864e                	mv	a2,s3
    5116:	85d2                	mv	a1,s4
    5118:	8566                	mv	a0,s9
    511a:	ea9ff0ef          	jal	4fc2 <runtests>
      if (n < 0) {
    511e:	fa054ee3          	bltz	a0,50da <drivetests+0x60>
        ntests += n;
    5122:	9ca9                	addw	s1,s1,a0
    5124:	bf6d                	j	50de <drivetests+0x64>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5126:	864a                	mv	a2,s2
    5128:	85aa                	mv	a1,a0
    512a:	856a                	mv	a0,s10
    512c:	7c0000ef          	jal	58ec <printf>
      if (continuous != 2) {
    5130:	03699163          	bne	s3,s6,5152 <drivetests+0xd8>
    if (justone != 0 && ntests == 0) {
    5134:	fa0a1be3          	bnez	s4,50ea <drivetests+0x70>
    5138:	bf65                	j	50f0 <drivetests+0x76>
      printf("NO TESTS EXECUTED\n");
    513a:	00003517          	auipc	a0,0x3
    513e:	e6650513          	addi	a0,a0,-410 # 7fa0 <malloc+0x2600>
    5142:	7aa000ef          	jal	58ec <printf>
      return 1;
    5146:	4505                	li	a0,1
    5148:	a801                	j	5158 <drivetests+0xde>
        return 1;
    514a:	4505                	li	a0,1
    514c:	a031                	j	5158 <drivetests+0xde>
          return 1;
    514e:	4505                	li	a0,1
    5150:	a021                	j	5158 <drivetests+0xde>
        return 1;
    5152:	4505                	li	a0,1
    5154:	a011                	j	5158 <drivetests+0xde>
  return 0;
    5156:	854e                	mv	a0,s3
}
    5158:	70a6                	ld	ra,104(sp)
    515a:	7406                	ld	s0,96(sp)
    515c:	64e6                	ld	s1,88(sp)
    515e:	6946                	ld	s2,80(sp)
    5160:	69a6                	ld	s3,72(sp)
    5162:	6a06                	ld	s4,64(sp)
    5164:	7ae2                	ld	s5,56(sp)
    5166:	7b42                	ld	s6,48(sp)
    5168:	7ba2                	ld	s7,40(sp)
    516a:	7c02                	ld	s8,32(sp)
    516c:	6ce2                	ld	s9,24(sp)
    516e:	6d42                	ld	s10,16(sp)
    5170:	6da2                	ld	s11,8(sp)
    5172:	6165                	addi	sp,sp,112
    5174:	8082                	ret

0000000000005176 <main>:

int
main(int argc, char *argv[])
{
    5176:	1101                	addi	sp,sp,-32
    5178:	ec06                	sd	ra,24(sp)
    517a:	e822                	sd	s0,16(sp)
    517c:	e426                	sd	s1,8(sp)
    517e:	e04a                	sd	s2,0(sp)
    5180:	1000                	addi	s0,sp,32
    5182:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if (argc == 2 && strcmp(argv[1], "-q") == 0) {
    5184:	4789                	li	a5,2
    5186:	00f50e63          	beq	a0,a5,51a2 <main+0x2c>
    continuous = 1;
  } else if (argc == 2 && strcmp(argv[1], "-C") == 0) {
    continuous = 2;
  } else if (argc == 2 && argv[1][0] != '-') {
    justone = argv[1];
  } else if (argc > 1) {
    518a:	4785                	li	a5,1
    518c:	06a7c663          	blt	a5,a0,51f8 <main+0x82>
  char *justone = 0;
    5190:	4601                	li	a2,0
  int quick = 0;
    5192:	4501                	li	a0,0
  int continuous = 0;
    5194:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    5196:	ee5ff0ef          	jal	507a <drivetests>
    519a:	cd35                	beqz	a0,5216 <main+0xa0>
    exit(1);
    519c:	4505                	li	a0,1
    519e:	31e000ef          	jal	54bc <exit>
    51a2:	892e                	mv	s2,a1
  if (argc == 2 && strcmp(argv[1], "-q") == 0) {
    51a4:	00003597          	auipc	a1,0x3
    51a8:	e1458593          	addi	a1,a1,-492 # 7fb8 <malloc+0x2618>
    51ac:	00893503          	ld	a0,8(s2)
    51b0:	0a4000ef          	jal	5254 <strcmp>
    51b4:	85aa                	mv	a1,a0
    51b6:	e501                	bnez	a0,51be <main+0x48>
  char *justone = 0;
    51b8:	4601                	li	a2,0
    quick = 1;
    51ba:	4505                	li	a0,1
    51bc:	bfe9                	j	5196 <main+0x20>
  } else if (argc == 2 && strcmp(argv[1], "-c") == 0) {
    51be:	00003597          	auipc	a1,0x3
    51c2:	e0258593          	addi	a1,a1,-510 # 7fc0 <malloc+0x2620>
    51c6:	00893503          	ld	a0,8(s2)
    51ca:	08a000ef          	jal	5254 <strcmp>
    51ce:	cd15                	beqz	a0,520a <main+0x94>
  } else if (argc == 2 && strcmp(argv[1], "-C") == 0) {
    51d0:	00003597          	auipc	a1,0x3
    51d4:	e4058593          	addi	a1,a1,-448 # 8010 <malloc+0x2670>
    51d8:	00893503          	ld	a0,8(s2)
    51dc:	078000ef          	jal	5254 <strcmp>
    51e0:	c905                	beqz	a0,5210 <main+0x9a>
  } else if (argc == 2 && argv[1][0] != '-') {
    51e2:	00893603          	ld	a2,8(s2)
    51e6:	00064703          	lbu	a4,0(a2) # 1000 <badarg>
    51ea:	02d00793          	li	a5,45
    51ee:	00f70563          	beq	a4,a5,51f8 <main+0x82>
  int quick = 0;
    51f2:	4501                	li	a0,0
  int continuous = 0;
    51f4:	4581                	li	a1,0
    51f6:	b745                	j	5196 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    51f8:	00003517          	auipc	a0,0x3
    51fc:	dd050513          	addi	a0,a0,-560 # 7fc8 <malloc+0x2628>
    5200:	6ec000ef          	jal	58ec <printf>
    exit(1);
    5204:	4505                	li	a0,1
    5206:	2b6000ef          	jal	54bc <exit>
  char *justone = 0;
    520a:	4601                	li	a2,0
    continuous = 1;
    520c:	4585                	li	a1,1
    520e:	b761                	j	5196 <main+0x20>
    continuous = 2;
    5210:	85a6                	mv	a1,s1
  char *justone = 0;
    5212:	4601                	li	a2,0
    5214:	b749                	j	5196 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    5216:	00003517          	auipc	a0,0x3
    521a:	de250513          	addi	a0,a0,-542 # 7ff8 <malloc+0x2658>
    521e:	6ce000ef          	jal	58ec <printf>
  exit(0);
    5222:	4501                	li	a0,0
    5224:	298000ef          	jal	54bc <exit>

0000000000005228 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
    5228:	1141                	addi	sp,sp,-16
    522a:	e406                	sd	ra,8(sp)
    522c:	e022                	sd	s0,0(sp)
    522e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
    5230:	f47ff0ef          	jal	5176 <main>
  exit(r);
    5234:	288000ef          	jal	54bc <exit>

0000000000005238 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
    5238:	1141                	addi	sp,sp,-16
    523a:	e422                	sd	s0,8(sp)
    523c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
    523e:	87aa                	mv	a5,a0
    5240:	0585                	addi	a1,a1,1
    5242:	0785                	addi	a5,a5,1
    5244:	fff5c703          	lbu	a4,-1(a1)
    5248:	fee78fa3          	sb	a4,-1(a5)
    524c:	fb75                	bnez	a4,5240 <strcpy+0x8>
    ;
  return os;
}
    524e:	6422                	ld	s0,8(sp)
    5250:	0141                	addi	sp,sp,16
    5252:	8082                	ret

0000000000005254 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5254:	1141                	addi	sp,sp,-16
    5256:	e422                	sd	s0,8(sp)
    5258:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
    525a:	00054783          	lbu	a5,0(a0)
    525e:	cb91                	beqz	a5,5272 <strcmp+0x1e>
    5260:	0005c703          	lbu	a4,0(a1)
    5264:	00f71763          	bne	a4,a5,5272 <strcmp+0x1e>
    p++, q++;
    5268:	0505                	addi	a0,a0,1
    526a:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
    526c:	00054783          	lbu	a5,0(a0)
    5270:	fbe5                	bnez	a5,5260 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5272:	0005c503          	lbu	a0,0(a1)
}
    5276:	40a7853b          	subw	a0,a5,a0
    527a:	6422                	ld	s0,8(sp)
    527c:	0141                	addi	sp,sp,16
    527e:	8082                	ret

0000000000005280 <strlen>:

uint
strlen(const char *s)
{
    5280:	1141                	addi	sp,sp,-16
    5282:	e422                	sd	s0,8(sp)
    5284:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    5286:	00054783          	lbu	a5,0(a0)
    528a:	cf91                	beqz	a5,52a6 <strlen+0x26>
    528c:	0505                	addi	a0,a0,1
    528e:	87aa                	mv	a5,a0
    5290:	86be                	mv	a3,a5
    5292:	0785                	addi	a5,a5,1
    5294:	fff7c703          	lbu	a4,-1(a5)
    5298:	ff65                	bnez	a4,5290 <strlen+0x10>
    529a:	40a6853b          	subw	a0,a3,a0
    529e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    52a0:	6422                	ld	s0,8(sp)
    52a2:	0141                	addi	sp,sp,16
    52a4:	8082                	ret
  for (n = 0; s[n]; n++)
    52a6:	4501                	li	a0,0
    52a8:	bfe5                	j	52a0 <strlen+0x20>

00000000000052aa <memset>:

void *
memset(void *dst, int c, uint n)
{
    52aa:	1141                	addi	sp,sp,-16
    52ac:	e422                	sd	s0,8(sp)
    52ae:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    52b0:	ca19                	beqz	a2,52c6 <memset+0x1c>
    52b2:	87aa                	mv	a5,a0
    52b4:	1602                	slli	a2,a2,0x20
    52b6:	9201                	srli	a2,a2,0x20
    52b8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    52bc:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    52c0:	0785                	addi	a5,a5,1
    52c2:	fee79de3          	bne	a5,a4,52bc <memset+0x12>
  }
  return dst;
}
    52c6:	6422                	ld	s0,8(sp)
    52c8:	0141                	addi	sp,sp,16
    52ca:	8082                	ret

00000000000052cc <strchr>:

char *
strchr(const char *s, char c)
{
    52cc:	1141                	addi	sp,sp,-16
    52ce:	e422                	sd	s0,8(sp)
    52d0:	0800                	addi	s0,sp,16
  for (; *s; s++)
    52d2:	00054783          	lbu	a5,0(a0)
    52d6:	cb99                	beqz	a5,52ec <strchr+0x20>
    if (*s == c)
    52d8:	00f58763          	beq	a1,a5,52e6 <strchr+0x1a>
  for (; *s; s++)
    52dc:	0505                	addi	a0,a0,1
    52de:	00054783          	lbu	a5,0(a0)
    52e2:	fbfd                	bnez	a5,52d8 <strchr+0xc>
      return (char *)s;
  return 0;
    52e4:	4501                	li	a0,0
}
    52e6:	6422                	ld	s0,8(sp)
    52e8:	0141                	addi	sp,sp,16
    52ea:	8082                	ret
  return 0;
    52ec:	4501                	li	a0,0
    52ee:	bfe5                	j	52e6 <strchr+0x1a>

00000000000052f0 <gets>:

char *
gets(char *buf, int max)
{
    52f0:	711d                	addi	sp,sp,-96
    52f2:	ec86                	sd	ra,88(sp)
    52f4:	e8a2                	sd	s0,80(sp)
    52f6:	e4a6                	sd	s1,72(sp)
    52f8:	e0ca                	sd	s2,64(sp)
    52fa:	fc4e                	sd	s3,56(sp)
    52fc:	f852                	sd	s4,48(sp)
    52fe:	f456                	sd	s5,40(sp)
    5300:	f05a                	sd	s6,32(sp)
    5302:	ec5e                	sd	s7,24(sp)
    5304:	1080                	addi	s0,sp,96
    5306:	8baa                	mv	s7,a0
    5308:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
    530a:	892a                	mv	s2,a0
    530c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
    530e:	4aa9                	li	s5,10
    5310:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
    5312:	89a6                	mv	s3,s1
    5314:	2485                	addiw	s1,s1,1
    5316:	0344d663          	bge	s1,s4,5342 <gets+0x52>
    cc = read(0, &c, 1);
    531a:	4605                	li	a2,1
    531c:	faf40593          	addi	a1,s0,-81
    5320:	4501                	li	a0,0
    5322:	1b2000ef          	jal	54d4 <read>
    if (cc < 1)
    5326:	00a05e63          	blez	a0,5342 <gets+0x52>
    buf[i++] = c;
    532a:	faf44783          	lbu	a5,-81(s0)
    532e:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
    5332:	01578763          	beq	a5,s5,5340 <gets+0x50>
    5336:	0905                	addi	s2,s2,1
    5338:	fd679de3          	bne	a5,s6,5312 <gets+0x22>
    buf[i++] = c;
    533c:	89a6                	mv	s3,s1
    533e:	a011                	j	5342 <gets+0x52>
    5340:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5342:	99de                	add	s3,s3,s7
    5344:	00098023          	sb	zero,0(s3)
  return buf;
}
    5348:	855e                	mv	a0,s7
    534a:	60e6                	ld	ra,88(sp)
    534c:	6446                	ld	s0,80(sp)
    534e:	64a6                	ld	s1,72(sp)
    5350:	6906                	ld	s2,64(sp)
    5352:	79e2                	ld	s3,56(sp)
    5354:	7a42                	ld	s4,48(sp)
    5356:	7aa2                	ld	s5,40(sp)
    5358:	7b02                	ld	s6,32(sp)
    535a:	6be2                	ld	s7,24(sp)
    535c:	6125                	addi	sp,sp,96
    535e:	8082                	ret

0000000000005360 <stat>:

int
stat(const char *n, struct stat *st)
{
    5360:	1101                	addi	sp,sp,-32
    5362:	ec06                	sd	ra,24(sp)
    5364:	e822                	sd	s0,16(sp)
    5366:	e04a                	sd	s2,0(sp)
    5368:	1000                	addi	s0,sp,32
    536a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    536c:	4581                	li	a1,0
    536e:	18e000ef          	jal	54fc <open>
  if (fd < 0)
    5372:	02054263          	bltz	a0,5396 <stat+0x36>
    5376:	e426                	sd	s1,8(sp)
    5378:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    537a:	85ca                	mv	a1,s2
    537c:	198000ef          	jal	5514 <fstat>
    5380:	892a                	mv	s2,a0
  close(fd);
    5382:	8526                	mv	a0,s1
    5384:	160000ef          	jal	54e4 <close>
  return r;
    5388:	64a2                	ld	s1,8(sp)
}
    538a:	854a                	mv	a0,s2
    538c:	60e2                	ld	ra,24(sp)
    538e:	6442                	ld	s0,16(sp)
    5390:	6902                	ld	s2,0(sp)
    5392:	6105                	addi	sp,sp,32
    5394:	8082                	ret
    return -1;
    5396:	597d                	li	s2,-1
    5398:	bfcd                	j	538a <stat+0x2a>

000000000000539a <atoi>:

int
atoi(const char *s)
{
    539a:	1141                	addi	sp,sp,-16
    539c:	e422                	sd	s0,8(sp)
    539e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
    53a0:	00054683          	lbu	a3,0(a0)
    53a4:	fd06879b          	addiw	a5,a3,-48
    53a8:	0ff7f793          	zext.b	a5,a5
    53ac:	4625                	li	a2,9
    53ae:	02f66863          	bltu	a2,a5,53de <atoi+0x44>
    53b2:	872a                	mv	a4,a0
  n = 0;
    53b4:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
    53b6:	0705                	addi	a4,a4,1 # 1000001 <base+0xff0309>
    53b8:	0025179b          	slliw	a5,a0,0x2
    53bc:	9fa9                	addw	a5,a5,a0
    53be:	0017979b          	slliw	a5,a5,0x1
    53c2:	9fb5                	addw	a5,a5,a3
    53c4:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
    53c8:	00074683          	lbu	a3,0(a4)
    53cc:	fd06879b          	addiw	a5,a3,-48
    53d0:	0ff7f793          	zext.b	a5,a5
    53d4:	fef671e3          	bgeu	a2,a5,53b6 <atoi+0x1c>
  return n;
}
    53d8:	6422                	ld	s0,8(sp)
    53da:	0141                	addi	sp,sp,16
    53dc:	8082                	ret
  n = 0;
    53de:	4501                	li	a0,0
    53e0:	bfe5                	j	53d8 <atoi+0x3e>

00000000000053e2 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
    53e2:	1141                	addi	sp,sp,-16
    53e4:	e422                	sd	s0,8(sp)
    53e6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    53e8:	02b57463          	bgeu	a0,a1,5410 <memmove+0x2e>
    while (n-- > 0)
    53ec:	00c05f63          	blez	a2,540a <memmove+0x28>
    53f0:	1602                	slli	a2,a2,0x20
    53f2:	9201                	srli	a2,a2,0x20
    53f4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    53f8:	872a                	mv	a4,a0
      *dst++ = *src++;
    53fa:	0585                	addi	a1,a1,1
    53fc:	0705                	addi	a4,a4,1
    53fe:	fff5c683          	lbu	a3,-1(a1)
    5402:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    5406:	fef71ae3          	bne	a4,a5,53fa <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    540a:	6422                	ld	s0,8(sp)
    540c:	0141                	addi	sp,sp,16
    540e:	8082                	ret
    dst += n;
    5410:	00c50733          	add	a4,a0,a2
    src += n;
    5414:	95b2                	add	a1,a1,a2
    while (n-- > 0)
    5416:	fec05ae3          	blez	a2,540a <memmove+0x28>
    541a:	fff6079b          	addiw	a5,a2,-1
    541e:	1782                	slli	a5,a5,0x20
    5420:	9381                	srli	a5,a5,0x20
    5422:	fff7c793          	not	a5,a5
    5426:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5428:	15fd                	addi	a1,a1,-1
    542a:	177d                	addi	a4,a4,-1
    542c:	0005c683          	lbu	a3,0(a1)
    5430:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
    5434:	fee79ae3          	bne	a5,a4,5428 <memmove+0x46>
    5438:	bfc9                	j	540a <memmove+0x28>

000000000000543a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    543a:	1141                	addi	sp,sp,-16
    543c:	e422                	sd	s0,8(sp)
    543e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5440:	ca05                	beqz	a2,5470 <memcmp+0x36>
    5442:	fff6069b          	addiw	a3,a2,-1
    5446:	1682                	slli	a3,a3,0x20
    5448:	9281                	srli	a3,a3,0x20
    544a:	0685                	addi	a3,a3,1
    544c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    544e:	00054783          	lbu	a5,0(a0)
    5452:	0005c703          	lbu	a4,0(a1)
    5456:	00e79863          	bne	a5,a4,5466 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    545a:	0505                	addi	a0,a0,1
    p2++;
    545c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    545e:	fed518e3          	bne	a0,a3,544e <memcmp+0x14>
  }
  return 0;
    5462:	4501                	li	a0,0
    5464:	a019                	j	546a <memcmp+0x30>
      return *p1 - *p2;
    5466:	40e7853b          	subw	a0,a5,a4
}
    546a:	6422                	ld	s0,8(sp)
    546c:	0141                	addi	sp,sp,16
    546e:	8082                	ret
  return 0;
    5470:	4501                	li	a0,0
    5472:	bfe5                	j	546a <memcmp+0x30>

0000000000005474 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5474:	1141                	addi	sp,sp,-16
    5476:	e406                	sd	ra,8(sp)
    5478:	e022                	sd	s0,0(sp)
    547a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    547c:	f67ff0ef          	jal	53e2 <memmove>
}
    5480:	60a2                	ld	ra,8(sp)
    5482:	6402                	ld	s0,0(sp)
    5484:	0141                	addi	sp,sp,16
    5486:	8082                	ret

0000000000005488 <sbrk>:

char *
sbrk(int n)
{
    5488:	1141                	addi	sp,sp,-16
    548a:	e406                	sd	ra,8(sp)
    548c:	e022                	sd	s0,0(sp)
    548e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    5490:	4585                	li	a1,1
    5492:	0b2000ef          	jal	5544 <sys_sbrk>
}
    5496:	60a2                	ld	ra,8(sp)
    5498:	6402                	ld	s0,0(sp)
    549a:	0141                	addi	sp,sp,16
    549c:	8082                	ret

000000000000549e <sbrklazy>:

char *
sbrklazy(int n)
{
    549e:	1141                	addi	sp,sp,-16
    54a0:	e406                	sd	ra,8(sp)
    54a2:	e022                	sd	s0,0(sp)
    54a4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    54a6:	4589                	li	a1,2
    54a8:	09c000ef          	jal	5544 <sys_sbrk>
}
    54ac:	60a2                	ld	ra,8(sp)
    54ae:	6402                	ld	s0,0(sp)
    54b0:	0141                	addi	sp,sp,16
    54b2:	8082                	ret

00000000000054b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    54b4:	4885                	li	a7,1
 ecall
    54b6:	00000073          	ecall
 ret
    54ba:	8082                	ret

00000000000054bc <exit>:
.global exit
exit:
 li a7, SYS_exit
    54bc:	4889                	li	a7,2
 ecall
    54be:	00000073          	ecall
 ret
    54c2:	8082                	ret

00000000000054c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
    54c4:	488d                	li	a7,3
 ecall
    54c6:	00000073          	ecall
 ret
    54ca:	8082                	ret

00000000000054cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    54cc:	4891                	li	a7,4
 ecall
    54ce:	00000073          	ecall
 ret
    54d2:	8082                	ret

00000000000054d4 <read>:
.global read
read:
 li a7, SYS_read
    54d4:	4895                	li	a7,5
 ecall
    54d6:	00000073          	ecall
 ret
    54da:	8082                	ret

00000000000054dc <write>:
.global write
write:
 li a7, SYS_write
    54dc:	48c1                	li	a7,16
 ecall
    54de:	00000073          	ecall
 ret
    54e2:	8082                	ret

00000000000054e4 <close>:
.global close
close:
 li a7, SYS_close
    54e4:	48d5                	li	a7,21
 ecall
    54e6:	00000073          	ecall
 ret
    54ea:	8082                	ret

00000000000054ec <kill>:
.global kill
kill:
 li a7, SYS_kill
    54ec:	4899                	li	a7,6
 ecall
    54ee:	00000073          	ecall
 ret
    54f2:	8082                	ret

00000000000054f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
    54f4:	489d                	li	a7,7
 ecall
    54f6:	00000073          	ecall
 ret
    54fa:	8082                	ret

00000000000054fc <open>:
.global open
open:
 li a7, SYS_open
    54fc:	48bd                	li	a7,15
 ecall
    54fe:	00000073          	ecall
 ret
    5502:	8082                	ret

0000000000005504 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5504:	48c5                	li	a7,17
 ecall
    5506:	00000073          	ecall
 ret
    550a:	8082                	ret

000000000000550c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    550c:	48c9                	li	a7,18
 ecall
    550e:	00000073          	ecall
 ret
    5512:	8082                	ret

0000000000005514 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5514:	48a1                	li	a7,8
 ecall
    5516:	00000073          	ecall
 ret
    551a:	8082                	ret

000000000000551c <link>:
.global link
link:
 li a7, SYS_link
    551c:	48cd                	li	a7,19
 ecall
    551e:	00000073          	ecall
 ret
    5522:	8082                	ret

0000000000005524 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5524:	48d1                	li	a7,20
 ecall
    5526:	00000073          	ecall
 ret
    552a:	8082                	ret

000000000000552c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    552c:	48a5                	li	a7,9
 ecall
    552e:	00000073          	ecall
 ret
    5532:	8082                	ret

0000000000005534 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5534:	48a9                	li	a7,10
 ecall
    5536:	00000073          	ecall
 ret
    553a:	8082                	ret

000000000000553c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    553c:	48ad                	li	a7,11
 ecall
    553e:	00000073          	ecall
 ret
    5542:	8082                	ret

0000000000005544 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    5544:	48b1                	li	a7,12
 ecall
    5546:	00000073          	ecall
 ret
    554a:	8082                	ret

000000000000554c <pause>:
.global pause
pause:
 li a7, SYS_pause
    554c:	48b5                	li	a7,13
 ecall
    554e:	00000073          	ecall
 ret
    5552:	8082                	ret

0000000000005554 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5554:	48b9                	li	a7,14
 ecall
    5556:	00000073          	ecall
 ret
    555a:	8082                	ret

000000000000555c <sync>:
.global sync
sync:
 li a7, SYS_sync
    555c:	48d9                	li	a7,22
 ecall
    555e:	00000073          	ecall
 ret
    5562:	8082                	ret

0000000000005564 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5564:	1101                	addi	sp,sp,-32
    5566:	ec06                	sd	ra,24(sp)
    5568:	e822                	sd	s0,16(sp)
    556a:	1000                	addi	s0,sp,32
    556c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5570:	4605                	li	a2,1
    5572:	fef40593          	addi	a1,s0,-17
    5576:	f67ff0ef          	jal	54dc <write>
}
    557a:	60e2                	ld	ra,24(sp)
    557c:	6442                	ld	s0,16(sp)
    557e:	6105                	addi	sp,sp,32
    5580:	8082                	ret

0000000000005582 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    5582:	715d                	addi	sp,sp,-80
    5584:	e486                	sd	ra,72(sp)
    5586:	e0a2                	sd	s0,64(sp)
    5588:	f84a                	sd	s2,48(sp)
    558a:	0880                	addi	s0,sp,80
    558c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
    558e:	c299                	beqz	a3,5594 <printint+0x12>
    5590:	0805c363          	bltz	a1,5616 <printint+0x94>
  neg = 0;
    5594:	4881                	li	a7,0
    5596:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    559a:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    559c:	00003517          	auipc	a0,0x3
    55a0:	edc50513          	addi	a0,a0,-292 # 8478 <digits>
    55a4:	883e                	mv	a6,a5
    55a6:	2785                	addiw	a5,a5,1
    55a8:	02c5f733          	remu	a4,a1,a2
    55ac:	972a                	add	a4,a4,a0
    55ae:	00074703          	lbu	a4,0(a4)
    55b2:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    55b6:	872e                	mv	a4,a1
    55b8:	02c5d5b3          	divu	a1,a1,a2
    55bc:	0685                	addi	a3,a3,1
    55be:	fec773e3          	bgeu	a4,a2,55a4 <printint+0x22>
  if (neg)
    55c2:	00088b63          	beqz	a7,55d8 <printint+0x56>
    buf[i++] = '-';
    55c6:	fd078793          	addi	a5,a5,-48
    55ca:	97a2                	add	a5,a5,s0
    55cc:	02d00713          	li	a4,45
    55d0:	fee78423          	sb	a4,-24(a5)
    55d4:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
    55d8:	02f05a63          	blez	a5,560c <printint+0x8a>
    55dc:	fc26                	sd	s1,56(sp)
    55de:	f44e                	sd	s3,40(sp)
    55e0:	fb840713          	addi	a4,s0,-72
    55e4:	00f704b3          	add	s1,a4,a5
    55e8:	fff70993          	addi	s3,a4,-1
    55ec:	99be                	add	s3,s3,a5
    55ee:	37fd                	addiw	a5,a5,-1
    55f0:	1782                	slli	a5,a5,0x20
    55f2:	9381                	srli	a5,a5,0x20
    55f4:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    55f8:	fff4c583          	lbu	a1,-1(s1)
    55fc:	854a                	mv	a0,s2
    55fe:	f67ff0ef          	jal	5564 <putc>
  while (--i >= 0)
    5602:	14fd                	addi	s1,s1,-1
    5604:	ff349ae3          	bne	s1,s3,55f8 <printint+0x76>
    5608:	74e2                	ld	s1,56(sp)
    560a:	79a2                	ld	s3,40(sp)
}
    560c:	60a6                	ld	ra,72(sp)
    560e:	6406                	ld	s0,64(sp)
    5610:	7942                	ld	s2,48(sp)
    5612:	6161                	addi	sp,sp,80
    5614:	8082                	ret
    x = -xx;
    5616:	40b005b3          	neg	a1,a1
    neg = 1;
    561a:	4885                	li	a7,1
    x = -xx;
    561c:	bfad                	j	5596 <printint+0x14>

000000000000561e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    561e:	711d                	addi	sp,sp,-96
    5620:	ec86                	sd	ra,88(sp)
    5622:	e8a2                	sd	s0,80(sp)
    5624:	e0ca                	sd	s2,64(sp)
    5626:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
    5628:	0005c903          	lbu	s2,0(a1)
    562c:	28090663          	beqz	s2,58b8 <vprintf+0x29a>
    5630:	e4a6                	sd	s1,72(sp)
    5632:	fc4e                	sd	s3,56(sp)
    5634:	f852                	sd	s4,48(sp)
    5636:	f456                	sd	s5,40(sp)
    5638:	f05a                	sd	s6,32(sp)
    563a:	ec5e                	sd	s7,24(sp)
    563c:	e862                	sd	s8,16(sp)
    563e:	e466                	sd	s9,8(sp)
    5640:	8b2a                	mv	s6,a0
    5642:	8a2e                	mv	s4,a1
    5644:	8bb2                	mv	s7,a2
  state = 0;
    5646:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
    5648:	4481                	li	s1,0
    564a:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
    564c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
    5650:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
    5654:	06c00c93          	li	s9,108
    5658:	a005                	j	5678 <vprintf+0x5a>
        putc(fd, c0);
    565a:	85ca                	mv	a1,s2
    565c:	855a                	mv	a0,s6
    565e:	f07ff0ef          	jal	5564 <putc>
    5662:	a019                	j	5668 <vprintf+0x4a>
    } else if (state == '%') {
    5664:	03598263          	beq	s3,s5,5688 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
    5668:	2485                	addiw	s1,s1,1
    566a:	8726                	mv	a4,s1
    566c:	009a07b3          	add	a5,s4,s1
    5670:	0007c903          	lbu	s2,0(a5)
    5674:	22090a63          	beqz	s2,58a8 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
    5678:	0009079b          	sext.w	a5,s2
    if (state == 0) {
    567c:	fe0994e3          	bnez	s3,5664 <vprintf+0x46>
      if (c0 == '%') {
    5680:	fd579de3          	bne	a5,s5,565a <vprintf+0x3c>
        state = '%';
    5684:	89be                	mv	s3,a5
    5686:	b7cd                	j	5668 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
    5688:	00ea06b3          	add	a3,s4,a4
    568c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    5690:	8636                	mv	a2,a3
      if (c1)
    5692:	c681                	beqz	a3,569a <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
    5694:	9752                	add	a4,a4,s4
    5696:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
    569a:	05878363          	beq	a5,s8,56e0 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
    569e:	05978d63          	beq	a5,s9,56f8 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
    56a2:	07500713          	li	a4,117
    56a6:	0ee78763          	beq	a5,a4,5794 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
    56aa:	07800713          	li	a4,120
    56ae:	12e78963          	beq	a5,a4,57e0 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
    56b2:	07000713          	li	a4,112
    56b6:	14e78e63          	beq	a5,a4,5812 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
    56ba:	06300713          	li	a4,99
    56be:	18e78e63          	beq	a5,a4,585a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
    56c2:	07300713          	li	a4,115
    56c6:	1ae78463          	beq	a5,a4,586e <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
    56ca:	02500713          	li	a4,37
    56ce:	04e79563          	bne	a5,a4,5718 <vprintf+0xfa>
        putc(fd, '%');
    56d2:	02500593          	li	a1,37
    56d6:	855a                	mv	a0,s6
    56d8:	e8dff0ef          	jal	5564 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    56dc:	4981                	li	s3,0
    56de:	b769                	j	5668 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    56e0:	008b8913          	addi	s2,s7,8
    56e4:	4685                	li	a3,1
    56e6:	4629                	li	a2,10
    56e8:	000ba583          	lw	a1,0(s7)
    56ec:	855a                	mv	a0,s6
    56ee:	e95ff0ef          	jal	5582 <printint>
    56f2:	8bca                	mv	s7,s2
      state = 0;
    56f4:	4981                	li	s3,0
    56f6:	bf8d                	j	5668 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
    56f8:	06400793          	li	a5,100
    56fc:	02f68963          	beq	a3,a5,572e <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    5700:	06c00793          	li	a5,108
    5704:	04f68263          	beq	a3,a5,5748 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
    5708:	07500793          	li	a5,117
    570c:	0af68063          	beq	a3,a5,57ac <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
    5710:	07800793          	li	a5,120
    5714:	0ef68263          	beq	a3,a5,57f8 <vprintf+0x1da>
        putc(fd, '%');
    5718:	02500593          	li	a1,37
    571c:	855a                	mv	a0,s6
    571e:	e47ff0ef          	jal	5564 <putc>
        putc(fd, c0);
    5722:	85ca                	mv	a1,s2
    5724:	855a                	mv	a0,s6
    5726:	e3fff0ef          	jal	5564 <putc>
      state = 0;
    572a:	4981                	li	s3,0
    572c:	bf35                	j	5668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    572e:	008b8913          	addi	s2,s7,8
    5732:	4685                	li	a3,1
    5734:	4629                	li	a2,10
    5736:	000bb583          	ld	a1,0(s7)
    573a:	855a                	mv	a0,s6
    573c:	e47ff0ef          	jal	5582 <printint>
        i += 1;
    5740:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    5742:	8bca                	mv	s7,s2
      state = 0;
    5744:	4981                	li	s3,0
        i += 1;
    5746:	b70d                	j	5668 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    5748:	06400793          	li	a5,100
    574c:	02f60763          	beq	a2,a5,577a <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    5750:	07500793          	li	a5,117
    5754:	06f60963          	beq	a2,a5,57c6 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    5758:	07800793          	li	a5,120
    575c:	faf61ee3          	bne	a2,a5,5718 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    5760:	008b8913          	addi	s2,s7,8
    5764:	4681                	li	a3,0
    5766:	4641                	li	a2,16
    5768:	000bb583          	ld	a1,0(s7)
    576c:	855a                	mv	a0,s6
    576e:	e15ff0ef          	jal	5582 <printint>
        i += 2;
    5772:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    5774:	8bca                	mv	s7,s2
      state = 0;
    5776:	4981                	li	s3,0
        i += 2;
    5778:	bdc5                	j	5668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    577a:	008b8913          	addi	s2,s7,8
    577e:	4685                	li	a3,1
    5780:	4629                	li	a2,10
    5782:	000bb583          	ld	a1,0(s7)
    5786:	855a                	mv	a0,s6
    5788:	dfbff0ef          	jal	5582 <printint>
        i += 2;
    578c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    578e:	8bca                	mv	s7,s2
      state = 0;
    5790:	4981                	li	s3,0
        i += 2;
    5792:	bdd9                	j	5668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    5794:	008b8913          	addi	s2,s7,8
    5798:	4681                	li	a3,0
    579a:	4629                	li	a2,10
    579c:	000be583          	lwu	a1,0(s7)
    57a0:	855a                	mv	a0,s6
    57a2:	de1ff0ef          	jal	5582 <printint>
    57a6:	8bca                	mv	s7,s2
      state = 0;
    57a8:	4981                	li	s3,0
    57aa:	bd7d                	j	5668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    57ac:	008b8913          	addi	s2,s7,8
    57b0:	4681                	li	a3,0
    57b2:	4629                	li	a2,10
    57b4:	000bb583          	ld	a1,0(s7)
    57b8:	855a                	mv	a0,s6
    57ba:	dc9ff0ef          	jal	5582 <printint>
        i += 1;
    57be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    57c0:	8bca                	mv	s7,s2
      state = 0;
    57c2:	4981                	li	s3,0
        i += 1;
    57c4:	b555                	j	5668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    57c6:	008b8913          	addi	s2,s7,8
    57ca:	4681                	li	a3,0
    57cc:	4629                	li	a2,10
    57ce:	000bb583          	ld	a1,0(s7)
    57d2:	855a                	mv	a0,s6
    57d4:	dafff0ef          	jal	5582 <printint>
        i += 2;
    57d8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    57da:	8bca                	mv	s7,s2
      state = 0;
    57dc:	4981                	li	s3,0
        i += 2;
    57de:	b569                	j	5668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    57e0:	008b8913          	addi	s2,s7,8
    57e4:	4681                	li	a3,0
    57e6:	4641                	li	a2,16
    57e8:	000be583          	lwu	a1,0(s7)
    57ec:	855a                	mv	a0,s6
    57ee:	d95ff0ef          	jal	5582 <printint>
    57f2:	8bca                	mv	s7,s2
      state = 0;
    57f4:	4981                	li	s3,0
    57f6:	bd8d                	j	5668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    57f8:	008b8913          	addi	s2,s7,8
    57fc:	4681                	li	a3,0
    57fe:	4641                	li	a2,16
    5800:	000bb583          	ld	a1,0(s7)
    5804:	855a                	mv	a0,s6
    5806:	d7dff0ef          	jal	5582 <printint>
        i += 1;
    580a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    580c:	8bca                	mv	s7,s2
      state = 0;
    580e:	4981                	li	s3,0
        i += 1;
    5810:	bda1                	j	5668 <vprintf+0x4a>
    5812:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    5814:	008b8d13          	addi	s10,s7,8
    5818:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    581c:	03000593          	li	a1,48
    5820:	855a                	mv	a0,s6
    5822:	d43ff0ef          	jal	5564 <putc>
  putc(fd, 'x');
    5826:	07800593          	li	a1,120
    582a:	855a                	mv	a0,s6
    582c:	d39ff0ef          	jal	5564 <putc>
    5830:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5832:	00003b97          	auipc	s7,0x3
    5836:	c46b8b93          	addi	s7,s7,-954 # 8478 <digits>
    583a:	03c9d793          	srli	a5,s3,0x3c
    583e:	97de                	add	a5,a5,s7
    5840:	0007c583          	lbu	a1,0(a5)
    5844:	855a                	mv	a0,s6
    5846:	d1fff0ef          	jal	5564 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    584a:	0992                	slli	s3,s3,0x4
    584c:	397d                	addiw	s2,s2,-1
    584e:	fe0916e3          	bnez	s2,583a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
    5852:	8bea                	mv	s7,s10
      state = 0;
    5854:	4981                	li	s3,0
    5856:	6d02                	ld	s10,0(sp)
    5858:	bd01                	j	5668 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
    585a:	008b8913          	addi	s2,s7,8
    585e:	000bc583          	lbu	a1,0(s7)
    5862:	855a                	mv	a0,s6
    5864:	d01ff0ef          	jal	5564 <putc>
    5868:	8bca                	mv	s7,s2
      state = 0;
    586a:	4981                	li	s3,0
    586c:	bbf5                	j	5668 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
    586e:	008b8993          	addi	s3,s7,8
    5872:	000bb903          	ld	s2,0(s7)
    5876:	00090f63          	beqz	s2,5894 <vprintf+0x276>
        for (; *s; s++)
    587a:	00094583          	lbu	a1,0(s2)
    587e:	c195                	beqz	a1,58a2 <vprintf+0x284>
          putc(fd, *s);
    5880:	855a                	mv	a0,s6
    5882:	ce3ff0ef          	jal	5564 <putc>
        for (; *s; s++)
    5886:	0905                	addi	s2,s2,1
    5888:	00094583          	lbu	a1,0(s2)
    588c:	f9f5                	bnez	a1,5880 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
    588e:	8bce                	mv	s7,s3
      state = 0;
    5890:	4981                	li	s3,0
    5892:	bbd9                	j	5668 <vprintf+0x4a>
          s = "(null)";
    5894:	00003917          	auipc	s2,0x3
    5898:	b3490913          	addi	s2,s2,-1228 # 83c8 <malloc+0x2a28>
        for (; *s; s++)
    589c:	02800593          	li	a1,40
    58a0:	b7c5                	j	5880 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
    58a2:	8bce                	mv	s7,s3
      state = 0;
    58a4:	4981                	li	s3,0
    58a6:	b3c9                	j	5668 <vprintf+0x4a>
    58a8:	64a6                	ld	s1,72(sp)
    58aa:	79e2                	ld	s3,56(sp)
    58ac:	7a42                	ld	s4,48(sp)
    58ae:	7aa2                	ld	s5,40(sp)
    58b0:	7b02                	ld	s6,32(sp)
    58b2:	6be2                	ld	s7,24(sp)
    58b4:	6c42                	ld	s8,16(sp)
    58b6:	6ca2                	ld	s9,8(sp)
    }
  }
}
    58b8:	60e6                	ld	ra,88(sp)
    58ba:	6446                	ld	s0,80(sp)
    58bc:	6906                	ld	s2,64(sp)
    58be:	6125                	addi	sp,sp,96
    58c0:	8082                	ret

00000000000058c2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    58c2:	715d                	addi	sp,sp,-80
    58c4:	ec06                	sd	ra,24(sp)
    58c6:	e822                	sd	s0,16(sp)
    58c8:	1000                	addi	s0,sp,32
    58ca:	e010                	sd	a2,0(s0)
    58cc:	e414                	sd	a3,8(s0)
    58ce:	e818                	sd	a4,16(s0)
    58d0:	ec1c                	sd	a5,24(s0)
    58d2:	03043023          	sd	a6,32(s0)
    58d6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    58da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    58de:	8622                	mv	a2,s0
    58e0:	d3fff0ef          	jal	561e <vprintf>
}
    58e4:	60e2                	ld	ra,24(sp)
    58e6:	6442                	ld	s0,16(sp)
    58e8:	6161                	addi	sp,sp,80
    58ea:	8082                	ret

00000000000058ec <printf>:

void
printf(const char *fmt, ...)
{
    58ec:	711d                	addi	sp,sp,-96
    58ee:	ec06                	sd	ra,24(sp)
    58f0:	e822                	sd	s0,16(sp)
    58f2:	1000                	addi	s0,sp,32
    58f4:	e40c                	sd	a1,8(s0)
    58f6:	e810                	sd	a2,16(s0)
    58f8:	ec14                	sd	a3,24(s0)
    58fa:	f018                	sd	a4,32(s0)
    58fc:	f41c                	sd	a5,40(s0)
    58fe:	03043823          	sd	a6,48(s0)
    5902:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5906:	00840613          	addi	a2,s0,8
    590a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    590e:	85aa                	mv	a1,a0
    5910:	4505                	li	a0,1
    5912:	d0dff0ef          	jal	561e <vprintf>
}
    5916:	60e2                	ld	ra,24(sp)
    5918:	6442                	ld	s0,16(sp)
    591a:	6125                	addi	sp,sp,96
    591c:	8082                	ret

000000000000591e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    591e:	1141                	addi	sp,sp,-16
    5920:	e422                	sd	s0,8(sp)
    5922:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
    5924:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5928:	00004797          	auipc	a5,0x4
    592c:	ba87b783          	ld	a5,-1112(a5) # 94d0 <freep>
    5930:	a02d                	j	595a <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
    5932:	4618                	lw	a4,8(a2)
    5934:	9f2d                	addw	a4,a4,a1
    5936:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    593a:	6398                	ld	a4,0(a5)
    593c:	6310                	ld	a2,0(a4)
    593e:	a83d                	j	597c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
    5940:	ff852703          	lw	a4,-8(a0)
    5944:	9f31                	addw	a4,a4,a2
    5946:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    5948:	ff053683          	ld	a3,-16(a0)
    594c:	a091                	j	5990 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    594e:	6398                	ld	a4,0(a5)
    5950:	00e7e463          	bltu	a5,a4,5958 <free+0x3a>
    5954:	00e6ea63          	bltu	a3,a4,5968 <free+0x4a>
{
    5958:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    595a:	fed7fae3          	bgeu	a5,a3,594e <free+0x30>
    595e:	6398                	ld	a4,0(a5)
    5960:	00e6e463          	bltu	a3,a4,5968 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5964:	fee7eae3          	bltu	a5,a4,5958 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
    5968:	ff852583          	lw	a1,-8(a0)
    596c:	6390                	ld	a2,0(a5)
    596e:	02059813          	slli	a6,a1,0x20
    5972:	01c85713          	srli	a4,a6,0x1c
    5976:	9736                	add	a4,a4,a3
    5978:	fae60de3          	beq	a2,a4,5932 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    597c:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
    5980:	4790                	lw	a2,8(a5)
    5982:	02061593          	slli	a1,a2,0x20
    5986:	01c5d713          	srli	a4,a1,0x1c
    598a:	973e                	add	a4,a4,a5
    598c:	fae68ae3          	beq	a3,a4,5940 <free+0x22>
    p->s.ptr = bp->s.ptr;
    5990:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    5992:	00004717          	auipc	a4,0x4
    5996:	b2f73f23          	sd	a5,-1218(a4) # 94d0 <freep>
}
    599a:	6422                	ld	s0,8(sp)
    599c:	0141                	addi	sp,sp,16
    599e:	8082                	ret

00000000000059a0 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
    59a0:	7139                	addi	sp,sp,-64
    59a2:	fc06                	sd	ra,56(sp)
    59a4:	f822                	sd	s0,48(sp)
    59a6:	f426                	sd	s1,40(sp)
    59a8:	ec4e                	sd	s3,24(sp)
    59aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
    59ac:	02051493          	slli	s1,a0,0x20
    59b0:	9081                	srli	s1,s1,0x20
    59b2:	04bd                	addi	s1,s1,15
    59b4:	8091                	srli	s1,s1,0x4
    59b6:	0014899b          	addiw	s3,s1,1
    59ba:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
    59bc:	00004517          	auipc	a0,0x4
    59c0:	b1453503          	ld	a0,-1260(a0) # 94d0 <freep>
    59c4:	c915                	beqz	a0,59f8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    59c6:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    59c8:	4798                	lw	a4,8(a5)
    59ca:	08977a63          	bgeu	a4,s1,5a5e <malloc+0xbe>
    59ce:	f04a                	sd	s2,32(sp)
    59d0:	e852                	sd	s4,16(sp)
    59d2:	e456                	sd	s5,8(sp)
    59d4:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
    59d6:	8a4e                	mv	s4,s3
    59d8:	0009871b          	sext.w	a4,s3
    59dc:	6685                	lui	a3,0x1
    59de:	00d77363          	bgeu	a4,a3,59e4 <malloc+0x44>
    59e2:	6a05                	lui	s4,0x1
    59e4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    59e8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
    59ec:	00004917          	auipc	s2,0x4
    59f0:	ae490913          	addi	s2,s2,-1308 # 94d0 <freep>
  if (p == SBRK_ERROR)
    59f4:	5afd                	li	s5,-1
    59f6:	a081                	j	5a36 <malloc+0x96>
    59f8:	f04a                	sd	s2,32(sp)
    59fa:	e852                	sd	s4,16(sp)
    59fc:	e456                	sd	s5,8(sp)
    59fe:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    5a00:	0000a797          	auipc	a5,0xa
    5a04:	2f878793          	addi	a5,a5,760 # fcf8 <base>
    5a08:	00004717          	auipc	a4,0x4
    5a0c:	acf73423          	sd	a5,-1336(a4) # 94d0 <freep>
    5a10:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5a12:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
    5a16:	b7c1                	j	59d6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    5a18:	6398                	ld	a4,0(a5)
    5a1a:	e118                	sd	a4,0(a0)
    5a1c:	a8a9                	j	5a76 <malloc+0xd6>
  hp->s.size = nu;
    5a1e:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
    5a22:	0541                	addi	a0,a0,16
    5a24:	efbff0ef          	jal	591e <free>
  return freep;
    5a28:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
    5a2c:	c12d                	beqz	a0,5a8e <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
    5a2e:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
    5a30:	4798                	lw	a4,8(a5)
    5a32:	02977263          	bgeu	a4,s1,5a56 <malloc+0xb6>
    if (p == freep)
    5a36:	00093703          	ld	a4,0(s2)
    5a3a:	853e                	mv	a0,a5
    5a3c:	fef719e3          	bne	a4,a5,5a2e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    5a40:	8552                	mv	a0,s4
    5a42:	a47ff0ef          	jal	5488 <sbrk>
  if (p == SBRK_ERROR)
    5a46:	fd551ce3          	bne	a0,s5,5a1e <malloc+0x7e>
        return 0;
    5a4a:	4501                	li	a0,0
    5a4c:	7902                	ld	s2,32(sp)
    5a4e:	6a42                	ld	s4,16(sp)
    5a50:	6aa2                	ld	s5,8(sp)
    5a52:	6b02                	ld	s6,0(sp)
    5a54:	a03d                	j	5a82 <malloc+0xe2>
    5a56:	7902                	ld	s2,32(sp)
    5a58:	6a42                	ld	s4,16(sp)
    5a5a:	6aa2                	ld	s5,8(sp)
    5a5c:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
    5a5e:	fae48de3          	beq	s1,a4,5a18 <malloc+0x78>
        p->s.size -= nunits;
    5a62:	4137073b          	subw	a4,a4,s3
    5a66:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5a68:	02071693          	slli	a3,a4,0x20
    5a6c:	01c6d713          	srli	a4,a3,0x1c
    5a70:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5a72:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5a76:	00004717          	auipc	a4,0x4
    5a7a:	a4a73d23          	sd	a0,-1446(a4) # 94d0 <freep>
      return (void *)(p + 1);
    5a7e:	01078513          	addi	a0,a5,16
  }
}
    5a82:	70e2                	ld	ra,56(sp)
    5a84:	7442                	ld	s0,48(sp)
    5a86:	74a2                	ld	s1,40(sp)
    5a88:	69e2                	ld	s3,24(sp)
    5a8a:	6121                	addi	sp,sp,64
    5a8c:	8082                	ret
    5a8e:	7902                	ld	s2,32(sp)
    5a90:	6a42                	ld	s4,16(sp)
    5a92:	6aa2                	ld	s5,8(sp)
    5a94:	6b02                	ld	s6,0(sp)
    5a96:	b7f5                	j	5a82 <malloc+0xe2>
