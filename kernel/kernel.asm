
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	92010113          	addi	sp,sp,-1760 # 80007920 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	03e000ef          	jal	80000054 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000022:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000026:	577d                	li	a4,-1
    80000028:	177e                	slli	a4,a4,0x3f
    8000002a:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002c:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000030:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000038:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003c:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000040:	000f4737          	lui	a4,0xf4
    80000044:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000048:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004a:	14d79073          	csrw	stimecmp,a5
}
    8000004e:	6422                	ld	s0,8(sp)
    80000050:	0141                	addi	sp,sp,16
    80000052:	8082                	ret

0000000080000054 <start>:
{
    80000054:	1141                	addi	sp,sp,-16
    80000056:	e406                	sd	ra,8(sp)
    80000058:	e022                	sd	s0,0(sp)
    8000005a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    8000005c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000060:	7779                	lui	a4,0xffffe
    80000062:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddbbf>
    80000066:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000068:	6705                	lui	a4,0x1
    8000006a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000006e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000074:	00001797          	auipc	a5,0x1
    80000078:	e3678793          	addi	a5,a5,-458 # 80000eaa <main>
    8000007c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000080:	4781                	li	a5,0
    80000082:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000086:	67c1                	lui	a5,0x10
    80000088:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000008e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000092:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80000096:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009a:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000009e:	57fd                	li	a5,-1
    800000a0:	83a9                	srli	a5,a5,0xa
    800000a2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000a6:	47bd                	li	a5,15
    800000a8:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000ac:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b0:	4705                	li	a4,1
    800000b2:	1776                	slli	a4,a4,0x3d
    800000b4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000b6:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000ba:	f63ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000be:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c2:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c6:	30200073          	mret
}
    800000ca:	60a2                	ld	ra,8(sp)
    800000cc:	6402                	ld	s0,0(sp)
    800000ce:	0141                	addi	sp,sp,16
    800000d0:	8082                	ret

00000000800000d2 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d2:	7119                	addi	sp,sp,-128
    800000d4:	fc86                	sd	ra,120(sp)
    800000d6:	f8a2                	sd	s0,112(sp)
    800000d8:	f4a6                	sd	s1,104(sp)
    800000da:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000dc:	06c05a63          	blez	a2,80000150 <consolewrite+0x7e>
    800000e0:	f0ca                	sd	s2,96(sp)
    800000e2:	ecce                	sd	s3,88(sp)
    800000e4:	e8d2                	sd	s4,80(sp)
    800000e6:	e4d6                	sd	s5,72(sp)
    800000e8:	e0da                	sd	s6,64(sp)
    800000ea:	fc5e                	sd	s7,56(sp)
    800000ec:	f862                	sd	s8,48(sp)
    800000ee:	f466                	sd	s9,40(sp)
    800000f0:	8aaa                	mv	s5,a0
    800000f2:	8b2e                	mv	s6,a1
    800000f4:	8a32                	mv	s4,a2
  int i = 0;
    800000f6:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000f8:	02000c13          	li	s8,32
    800000fc:	02000c93          	li	s9,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000100:	5bfd                	li	s7,-1
    80000102:	a035                	j	8000012e <consolewrite+0x5c>
    if (nn > n - i)
    80000104:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000108:	86ce                	mv	a3,s3
    8000010a:	01648633          	add	a2,s1,s6
    8000010e:	85d6                	mv	a1,s5
    80000110:	f8040513          	addi	a0,s0,-128
    80000114:	248020ef          	jal	8000235c <either_copyin>
    80000118:	03750e63          	beq	a0,s7,80000154 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011c:	85ce                	mv	a1,s3
    8000011e:	f8040513          	addi	a0,s0,-128
    80000122:	786000ef          	jal	800008a8 <uartwrite>
    i += nn;
    80000126:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    8000012a:	0144da63          	bge	s1,s4,8000013e <consolewrite+0x6c>
    if (nn > n - i)
    8000012e:	409a093b          	subw	s2,s4,s1
    80000132:	0009079b          	sext.w	a5,s2
    80000136:	fcfc57e3          	bge	s8,a5,80000104 <consolewrite+0x32>
    8000013a:	8966                	mv	s2,s9
    8000013c:	b7e1                	j	80000104 <consolewrite+0x32>
    8000013e:	7906                	ld	s2,96(sp)
    80000140:	69e6                	ld	s3,88(sp)
    80000142:	6a46                	ld	s4,80(sp)
    80000144:	6aa6                	ld	s5,72(sp)
    80000146:	6b06                	ld	s6,64(sp)
    80000148:	7be2                	ld	s7,56(sp)
    8000014a:	7c42                	ld	s8,48(sp)
    8000014c:	7ca2                	ld	s9,40(sp)
    8000014e:	a819                	j	80000164 <consolewrite+0x92>
  int i = 0;
    80000150:	4481                	li	s1,0
    80000152:	a809                	j	80000164 <consolewrite+0x92>
    80000154:	7906                	ld	s2,96(sp)
    80000156:	69e6                	ld	s3,88(sp)
    80000158:	6a46                	ld	s4,80(sp)
    8000015a:	6aa6                	ld	s5,72(sp)
    8000015c:	6b06                	ld	s6,64(sp)
    8000015e:	7be2                	ld	s7,56(sp)
    80000160:	7c42                	ld	s8,48(sp)
    80000162:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000164:	8526                	mv	a0,s1
    80000166:	70e6                	ld	ra,120(sp)
    80000168:	7446                	ld	s0,112(sp)
    8000016a:	74a6                	ld	s1,104(sp)
    8000016c:	6109                	addi	sp,sp,128
    8000016e:	8082                	ret

0000000080000170 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	711d                	addi	sp,sp,-96
    80000172:	ec86                	sd	ra,88(sp)
    80000174:	e8a2                	sd	s0,80(sp)
    80000176:	e4a6                	sd	s1,72(sp)
    80000178:	e0ca                	sd	s2,64(sp)
    8000017a:	fc4e                	sd	s3,56(sp)
    8000017c:	f852                	sd	s4,48(sp)
    8000017e:	f456                	sd	s5,40(sp)
    80000180:	f05a                	sd	s6,32(sp)
    80000182:	1080                	addi	s0,sp,96
    80000184:	8aaa                	mv	s5,a0
    80000186:	8a2e                	mv	s4,a1
    80000188:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000018a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018e:	0000f517          	auipc	a0,0xf
    80000192:	79250513          	addi	a0,a0,1938 # 8000f920 <cons>
    80000196:	2b7000ef          	jal	80000c4c <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    8000019a:	0000f497          	auipc	s1,0xf
    8000019e:	78648493          	addi	s1,s1,1926 # 8000f920 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a2:	00010917          	auipc	s2,0x10
    800001a6:	81690913          	addi	s2,s2,-2026 # 8000f9b8 <cons+0x98>
  while (n > 0) {
    800001aa:	0d305463          	blez	s3,80000272 <consoleread+0x102>
    while (cons.r == cons.w) {
    800001ae:	0984a783          	lw	a5,152(s1)
    800001b2:	09c4a703          	lw	a4,156(s1)
    800001b6:	0af71963          	bne	a4,a5,80000268 <consoleread+0xf8>
      if (killed(myproc())) {
    800001ba:	7be010ef          	jal	80001978 <myproc>
    800001be:	018020ef          	jal	800021d6 <killed>
    800001c2:	e925                	bnez	a0,80000232 <consoleread+0xc2>
      sleep_prepare(&cons.r);
    800001c4:	854a                	mv	a0,s2
    800001c6:	5b7010ef          	jal	80001f7c <sleep_prepare>
      release(&cons.lock);
    800001ca:	8526                	mv	a0,s1
    800001cc:	30d000ef          	jal	80000cd8 <release>
      sleep();
    800001d0:	5e9010ef          	jal	80001fb8 <sleep>
      acquire(&cons.lock);
    800001d4:	8526                	mv	a0,s1
    800001d6:	277000ef          	jal	80000c4c <acquire>
    while (cons.r == cons.w) {
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70ce3          	beq	a4,a5,800001ba <consoleread+0x4a>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	0000f717          	auipc	a4,0xf
    800001ec:	73870713          	addi	a4,a4,1848 # 8000f920 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if (c == C('D')) { // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8663          	beq	s7,a3,80000254 <consoleread+0xe4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	0f6020ef          	jal	80002310 <either_copyout>
    8000021e:	57fd                	li	a5,-1
    80000220:	04f50863          	beq	a0,a5,80000270 <consoleread+0x100>
      break;

    dst++;
    80000224:	0a05                	addi	s4,s4,1
    --n;
    80000226:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    80000228:	47a9                	li	a5,10
    8000022a:	04fb8d63          	beq	s7,a5,80000284 <consoleread+0x114>
    8000022e:	6be2                	ld	s7,24(sp)
    80000230:	bfad                	j	800001aa <consoleread+0x3a>
        release(&cons.lock);
    80000232:	0000f517          	auipc	a0,0xf
    80000236:	6ee50513          	addi	a0,a0,1774 # 8000f920 <cons>
    8000023a:	29f000ef          	jal	80000cd8 <release>
        return -1;
    8000023e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000240:	60e6                	ld	ra,88(sp)
    80000242:	6446                	ld	s0,80(sp)
    80000244:	64a6                	ld	s1,72(sp)
    80000246:	6906                	ld	s2,64(sp)
    80000248:	79e2                	ld	s3,56(sp)
    8000024a:	7a42                	ld	s4,48(sp)
    8000024c:	7aa2                	ld	s5,40(sp)
    8000024e:	7b02                	ld	s6,32(sp)
    80000250:	6125                	addi	sp,sp,96
    80000252:	8082                	ret
      if (n < target) {
    80000254:	0009871b          	sext.w	a4,s3
    80000258:	01677a63          	bgeu	a4,s6,8000026c <consoleread+0xfc>
        cons.r--;
    8000025c:	0000f717          	auipc	a4,0xf
    80000260:	74f72e23          	sw	a5,1884(a4) # 8000f9b8 <cons+0x98>
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	a031                	j	80000272 <consoleread+0x102>
    80000268:	ec5e                	sd	s7,24(sp)
    8000026a:	bfbd                	j	800001e8 <consoleread+0x78>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a011                	j	80000272 <consoleread+0x102>
    80000270:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000272:	0000f517          	auipc	a0,0xf
    80000276:	6ae50513          	addi	a0,a0,1710 # 8000f920 <cons>
    8000027a:	25f000ef          	jal	80000cd8 <release>
  return target - n;
    8000027e:	413b053b          	subw	a0,s6,s3
    80000282:	bf7d                	j	80000240 <consoleread+0xd0>
    80000284:	6be2                	ld	s7,24(sp)
    80000286:	b7f5                	j	80000272 <consoleread+0x102>

0000000080000288 <consputc>:
{
    80000288:	1141                	addi	sp,sp,-16
    8000028a:	e406                	sd	ra,8(sp)
    8000028c:	e022                	sd	s0,0(sp)
    8000028e:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000290:	10000793          	li	a5,256
    80000294:	00f50863          	beq	a0,a5,800002a4 <consputc+0x1c>
    uartputc_sync(c);
    80000298:	696000ef          	jal	8000092e <uartputc_sync>
}
    8000029c:	60a2                	ld	ra,8(sp)
    8000029e:	6402                	ld	s0,0(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret
    uartputc_sync('\b');
    800002a4:	4521                	li	a0,8
    800002a6:	688000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync(' ');
    800002aa:	02000513          	li	a0,32
    800002ae:	680000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	67a000ef          	jal	8000092e <uartputc_sync>
    800002b8:	b7d5                	j	8000029c <consputc+0x14>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	0000f517          	auipc	a0,0xf
    800002ca:	65a50513          	addi	a0,a0,1626 # 8000f920 <cons>
    800002ce:	17f000ef          	jal	80000c4c <acquire>

  switch (c) {
    800002d2:	47d5                	li	a5,21
    800002d4:	08f48f63          	beq	s1,a5,80000372 <consoleintr+0xb8>
    800002d8:	0297c563          	blt	a5,s1,80000302 <consoleintr+0x48>
    800002dc:	47a1                	li	a5,8
    800002de:	0ef48463          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    800002e2:	47c1                	li	a5,16
    800002e4:	10f49563          	bne	s1,a5,800003ee <consoleintr+0x134>
  case C('P'): // Print process list.
    procdump();
    800002e8:	0c0020ef          	jal	800023a8 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ec:	0000f517          	auipc	a0,0xf
    800002f0:	63450513          	addi	a0,a0,1588 # 8000f920 <cons>
    800002f4:	1e5000ef          	jal	80000cd8 <release>
}
    800002f8:	60e2                	ld	ra,24(sp)
    800002fa:	6442                	ld	s0,16(sp)
    800002fc:	64a2                	ld	s1,8(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch (c) {
    80000302:	07f00793          	li	a5,127
    80000306:	0cf48063          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030a:	0000f717          	auipc	a4,0xf
    8000030e:	61670713          	addi	a4,a4,1558 # 8000f920 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf766e3          	bltu	a4,a5,800002ec <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x13a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	f5dff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000330:	0000f797          	auipc	a5,0xf
    80000334:	5f078793          	addi	a5,a5,1520 # 8000f920 <cons>
    80000338:	0a07a683          	lw	a3,160(a5)
    8000033c:	0016871b          	addiw	a4,a3,1
    80000340:	0007061b          	sext.w	a2,a4
    80000344:	0ae7a023          	sw	a4,160(a5)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	97b6                	add	a5,a5,a3
    8000034e:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	47a9                	li	a5,10
    80000354:	0cf48563          	beq	s1,a5,8000041e <consoleintr+0x164>
    80000358:	4791                	li	a5,4
    8000035a:	0cf48263          	beq	s1,a5,8000041e <consoleintr+0x164>
    8000035e:	0000f797          	auipc	a5,0xf
    80000362:	65a7a783          	lw	a5,1626(a5) # 8000f9b8 <cons+0x98>
    80000366:	9f1d                	subw	a4,a4,a5
    80000368:	08000793          	li	a5,128
    8000036c:	f8f710e3          	bne	a4,a5,800002ec <consoleintr+0x32>
    80000370:	a07d                	j	8000041e <consoleintr+0x164>
    80000372:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000374:	0000f717          	auipc	a4,0xf
    80000378:	5ac70713          	addi	a4,a4,1452 # 8000f920 <cons>
    8000037c:	0a072783          	lw	a5,160(a4)
    80000380:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000384:	0000f497          	auipc	s1,0xf
    80000388:	59c48493          	addi	s1,s1,1436 # 8000f920 <cons>
    while (cons.e != cons.w &&
    8000038c:	4929                	li	s2,10
    8000038e:	02f70863          	beq	a4,a5,800003be <consoleintr+0x104>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	07f7f713          	andi	a4,a5,127
    80000398:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    8000039a:	01874703          	lbu	a4,24(a4)
    8000039e:	03270263          	beq	a4,s2,800003c2 <consoleintr+0x108>
      cons.e--;
    800003a2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a6:	10000513          	li	a0,256
    800003aa:	edfff0ef          	jal	80000288 <consputc>
    while (cons.e != cons.w &&
    800003ae:	0a04a783          	lw	a5,160(s1)
    800003b2:	09c4a703          	lw	a4,156(s1)
    800003b6:	fcf71ee3          	bne	a4,a5,80000392 <consoleintr+0xd8>
    800003ba:	6902                	ld	s2,0(sp)
    800003bc:	bf05                	j	800002ec <consoleintr+0x32>
    800003be:	6902                	ld	s2,0(sp)
    800003c0:	b735                	j	800002ec <consoleintr+0x32>
    800003c2:	6902                	ld	s2,0(sp)
    800003c4:	b725                	j	800002ec <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c6:	0000f717          	auipc	a4,0xf
    800003ca:	55a70713          	addi	a4,a4,1370 # 8000f920 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70be3          	beq	a4,a5,800002ec <consoleintr+0x32>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	0000f717          	auipc	a4,0xf
    800003e0:	5ef72223          	sw	a5,1508(a4) # 8000f9c0 <cons+0xa0>
      consputc(BACKSPACE);
    800003e4:	10000513          	li	a0,256
    800003e8:	ea1ff0ef          	jal	80000288 <consputc>
    800003ec:	b701                	j	800002ec <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ee:	ee048fe3          	beqz	s1,800002ec <consoleintr+0x32>
    800003f2:	bf21                	j	8000030a <consoleintr+0x50>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	e93ff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003fa:	0000f797          	auipc	a5,0xf
    800003fe:	52678793          	addi	a5,a5,1318 # 8000f920 <cons>
    80000402:	0a07a703          	lw	a4,160(a5)
    80000406:	0017069b          	addiw	a3,a4,1
    8000040a:	0006861b          	sext.w	a2,a3
    8000040e:	0ad7a023          	sw	a3,160(a5)
    80000412:	07f77713          	andi	a4,a4,127
    80000416:	97ba                	add	a5,a5,a4
    80000418:	4729                	li	a4,10
    8000041a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041e:	0000f797          	auipc	a5,0xf
    80000422:	58c7af23          	sw	a2,1438(a5) # 8000f9bc <cons+0x9c>
        wakeup(&cons.r);
    80000426:	0000f517          	auipc	a0,0xf
    8000042a:	59250513          	addi	a0,a0,1426 # 8000f9b8 <cons+0x98>
    8000042e:	3bb010ef          	jal	80001fe8 <wakeup>
    80000432:	bd6d                	j	800002ec <consoleintr+0x32>

0000000080000434 <consoleinit>:

void
consoleinit(void)
{
    80000434:	1141                	addi	sp,sp,-16
    80000436:	e406                	sd	ra,8(sp)
    80000438:	e022                	sd	s0,0(sp)
    8000043a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000043c:	00007597          	auipc	a1,0x7
    80000440:	bc458593          	addi	a1,a1,-1084 # 80007000 <etext>
    80000444:	0000f517          	auipc	a0,0xf
    80000448:	4dc50513          	addi	a0,a0,1244 # 8000f920 <cons>
    8000044c:	78a000ef          	jal	80000bd6 <initlock>

  uartinit();
    80000450:	400000ef          	jal	80000850 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000454:	0001f797          	auipc	a5,0x1f
    80000458:	65478793          	addi	a5,a5,1620 # 8001faa8 <devsw>
    8000045c:	00000717          	auipc	a4,0x0
    80000460:	d1470713          	addi	a4,a4,-748 # 80000170 <consoleread>
    80000464:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000466:	00000717          	auipc	a4,0x0
    8000046a:	c6c70713          	addi	a4,a4,-916 # 800000d2 <consolewrite>
    8000046e:	ef98                	sd	a4,24(a5)
}
    80000470:	60a2                	ld	ra,8(sp)
    80000472:	6402                	ld	s0,0(sp)
    80000474:	0141                	addi	sp,sp,16
    80000476:	8082                	ret

0000000080000478 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000478:	7139                	addi	sp,sp,-64
    8000047a:	fc06                	sd	ra,56(sp)
    8000047c:	f822                	sd	s0,48(sp)
    8000047e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000480:	c219                	beqz	a2,80000486 <printint+0xe>
    80000482:	08054063          	bltz	a0,80000502 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000486:	4881                	li	a7,0
    80000488:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000048c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00007617          	auipc	a2,0x7
    80000492:	33a60613          	addi	a2,a2,826 # 800077c8 <digits>
    80000496:	883e                	mv	a6,a5
    80000498:	2785                	addiw	a5,a5,1
    8000049a:	02b57733          	remu	a4,a0,a1
    8000049e:	9732                	add	a4,a4,a2
    800004a0:	00074703          	lbu	a4,0(a4)
    800004a4:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    800004a8:	872a                	mv	a4,a0
    800004aa:	02b55533          	divu	a0,a0,a1
    800004ae:	0685                	addi	a3,a3,1
    800004b0:	feb773e3          	bgeu	a4,a1,80000496 <printint+0x1e>

  if (sign)
    800004b4:	00088a63          	beqz	a7,800004c8 <printint+0x50>
    buf[i++] = '-';
    800004b8:	1781                	addi	a5,a5,-32
    800004ba:	97a2                	add	a5,a5,s0
    800004bc:	02d00713          	li	a4,45
    800004c0:	fee78423          	sb	a4,-24(a5)
    800004c4:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
    800004c8:	02f05963          	blez	a5,800004fa <printint+0x82>
    800004cc:	f426                	sd	s1,40(sp)
    800004ce:	f04a                	sd	s2,32(sp)
    800004d0:	fc840713          	addi	a4,s0,-56
    800004d4:	00f704b3          	add	s1,a4,a5
    800004d8:	fff70913          	addi	s2,a4,-1
    800004dc:	993e                	add	s2,s2,a5
    800004de:	37fd                	addiw	a5,a5,-1
    800004e0:	1782                	slli	a5,a5,0x20
    800004e2:	9381                	srli	a5,a5,0x20
    800004e4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004e8:	fff4c503          	lbu	a0,-1(s1)
    800004ec:	d9dff0ef          	jal	80000288 <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x70>
    800004f6:	74a2                	ld	s1,40(sp)
    800004f8:	7902                	ld	s2,32(sp)
}
    800004fa:	70e2                	ld	ra,56(sp)
    800004fc:	7442                	ld	s0,48(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4885                	li	a7,1
    x = -xx;
    80000508:	b741                	j	80000488 <printint+0x10>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	e8d2                	sd	s4,80(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	8a2a                	mv	s4,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	00007797          	auipc	a5,0x7
    8000052c:	3cc7a783          	lw	a5,972(a5) # 800078f4 <panicking>
    80000530:	c3a1                	beqz	a5,80000570 <printk+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	000a4503          	lbu	a0,0(s4)
    8000053e:	28050763          	beqz	a0,800007cc <printk+0x2c2>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	f0ca                	sd	s2,96(sp)
    80000546:	ecce                	sd	s3,88(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	f862                	sd	s8,48(sp)
    8000054e:	f466                	sd	s9,40(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4981                	li	s3,0
    if (cx != '%') {
    80000556:	02500a93          	li	s5,37
    c1 = c2 = 0;
    if (c0)
      c1 = fmt[i + 1] & 0xff;
    if (c1)
      c2 = fmt[i + 2] & 0xff;
    if (c0 == 'd') {
    8000055a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if (c0 == 'l' && c1 == 'd') {
    8000055e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000562:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000566:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000056a:	07000d93          	li	s11,112
    8000056e:	a01d                	j	80000594 <printk+0x8a>
    acquire(&pr.lock);
    80000570:	0000f517          	auipc	a0,0xf
    80000574:	45850513          	addi	a0,a0,1112 # 8000f9c8 <pr>
    80000578:	6d4000ef          	jal	80000c4c <acquire>
    8000057c:	bf5d                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057e:	d0bff0ef          	jal	80000288 <consputc>
      continue;
    80000582:	84ce                	mv	s1,s3
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000584:	0014899b          	addiw	s3,s1,1
    80000588:	013a07b3          	add	a5,s4,s3
    8000058c:	0007c503          	lbu	a0,0(a5)
    80000590:	20050b63          	beqz	a0,800007a6 <printk+0x29c>
    if (cx != '%') {
    80000594:	ff5515e3          	bne	a0,s5,8000057e <printk+0x74>
    i++;
    80000598:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i + 0] & 0xff;
    8000059c:	009a07b3          	add	a5,s4,s1
    800005a0:	0007c903          	lbu	s2,0(a5)
    if (c0)
    800005a4:	20090b63          	beqz	s2,800007ba <printk+0x2b0>
      c1 = fmt[i + 1] & 0xff;
    800005a8:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800005ac:	86be                	mv	a3,a5
    if (c1)
    800005ae:	c789                	beqz	a5,800005b8 <printk+0xae>
      c2 = fmt[i + 2] & 0xff;
    800005b0:	009a0733          	add	a4,s4,s1
    800005b4:	00274683          	lbu	a3,2(a4)
    if (c0 == 'd') {
    800005b8:	03690963          	beq	s2,s6,800005ea <printk+0xe0>
    } else if (c0 == 'l' && c1 == 'd') {
    800005bc:	05890363          	beq	s2,s8,80000602 <printk+0xf8>
    } else if (c0 == 'u') {
    800005c0:	0d990663          	beq	s2,s9,8000068c <printk+0x182>
    } else if (c0 == 'x') {
    800005c4:	11a90d63          	beq	s2,s10,800006de <printk+0x1d4>
    } else if (c0 == 'p') {
    800005c8:	15b90663          	beq	s2,s11,80000714 <printk+0x20a>
      printptr(va_arg(ap, uint64));
    } else if (c0 == 'c') {
    800005cc:	06300793          	li	a5,99
    800005d0:	18f90563          	beq	s2,a5,8000075a <printk+0x250>
      consputc(va_arg(ap, uint));
    } else if (c0 == 's') {
    800005d4:	07300793          	li	a5,115
    800005d8:	18f90b63          	beq	s2,a5,8000076e <printk+0x264>
      if ((s = va_arg(ap, char *)) == 0)
        s = "(null)";
      for (; *s; s++)
        consputc(*s);
    } else if (c0 == '%') {
    800005dc:	03591b63          	bne	s2,s5,80000612 <printk+0x108>
      consputc('%');
    800005e0:	02500513          	li	a0,37
    800005e4:	ca5ff0ef          	jal	80000288 <consputc>
    800005e8:	bf71                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005ea:	f8843783          	ld	a5,-120(s0)
    800005ee:	00878713          	addi	a4,a5,8
    800005f2:	f8e43423          	sd	a4,-120(s0)
    800005f6:	4605                	li	a2,1
    800005f8:	45a9                	li	a1,10
    800005fa:	4388                	lw	a0,0(a5)
    800005fc:	e7dff0ef          	jal	80000478 <printint>
    80000600:	b751                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'd') {
    80000602:	01678f63          	beq	a5,s6,80000620 <printk+0x116>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000606:	03878b63          	beq	a5,s8,8000063c <printk+0x132>
    } else if (c0 == 'l' && c1 == 'u') {
    8000060a:	09978e63          	beq	a5,s9,800006a6 <printk+0x19c>
    } else if (c0 == 'l' && c1 == 'x') {
    8000060e:	0fa78563          	beq	a5,s10,800006f8 <printk+0x1ee>
    } else if (c0 == 0) {
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000612:	8556                	mv	a0,s5
    80000614:	c75ff0ef          	jal	80000288 <consputc>
      consputc(c0);
    80000618:	854a                	mv	a0,s2
    8000061a:	c6fff0ef          	jal	80000288 <consputc>
    8000061e:	b79d                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000620:	f8843783          	ld	a5,-120(s0)
    80000624:	00878713          	addi	a4,a5,8
    80000628:	f8e43423          	sd	a4,-120(s0)
    8000062c:	4605                	li	a2,1
    8000062e:	45a9                	li	a1,10
    80000630:	6388                	ld	a0,0(a5)
    80000632:	e47ff0ef          	jal	80000478 <printint>
      i += 1;
    80000636:	0029849b          	addiw	s1,s3,2
    8000063a:	b7a9                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    8000063c:	06400793          	li	a5,100
    80000640:	02f68863          	beq	a3,a5,80000670 <printk+0x166>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    80000644:	07500793          	li	a5,117
    80000648:	06f68d63          	beq	a3,a5,800006c2 <printk+0x1b8>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    8000064c:	07800793          	li	a5,120
    80000650:	fcf691e3          	bne	a3,a5,80000612 <printk+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4601                	li	a2,0
    80000662:	45c1                	li	a1,16
    80000664:	6388                	ld	a0,0(a5)
    80000666:	e13ff0ef          	jal	80000478 <printint>
      i += 2;
    8000066a:	0039849b          	addiw	s1,s3,3
    8000066e:	bf19                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000670:	f8843783          	ld	a5,-120(s0)
    80000674:	00878713          	addi	a4,a5,8
    80000678:	f8e43423          	sd	a4,-120(s0)
    8000067c:	4605                	li	a2,1
    8000067e:	45a9                	li	a1,10
    80000680:	6388                	ld	a0,0(a5)
    80000682:	df7ff0ef          	jal	80000478 <printint>
      i += 2;
    80000686:	0039849b          	addiw	s1,s3,3
    8000068a:	bded                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4601                	li	a2,0
    8000069a:	45a9                	li	a1,10
    8000069c:	0007e503          	lwu	a0,0(a5)
    800006a0:	dd9ff0ef          	jal	80000478 <printint>
    800006a4:	b5c5                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006a6:	f8843783          	ld	a5,-120(s0)
    800006aa:	00878713          	addi	a4,a5,8
    800006ae:	f8e43423          	sd	a4,-120(s0)
    800006b2:	4601                	li	a2,0
    800006b4:	45a9                	li	a1,10
    800006b6:	6388                	ld	a0,0(a5)
    800006b8:	dc1ff0ef          	jal	80000478 <printint>
      i += 1;
    800006bc:	0029849b          	addiw	s1,s3,2
    800006c0:	b5d1                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006c2:	f8843783          	ld	a5,-120(s0)
    800006c6:	00878713          	addi	a4,a5,8
    800006ca:	f8e43423          	sd	a4,-120(s0)
    800006ce:	4601                	li	a2,0
    800006d0:	45a9                	li	a1,10
    800006d2:	6388                	ld	a0,0(a5)
    800006d4:	da5ff0ef          	jal	80000478 <printint>
      i += 2;
    800006d8:	0039849b          	addiw	s1,s3,3
    800006dc:	b565                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	4601                	li	a2,0
    800006ec:	45c1                	li	a1,16
    800006ee:	0007e503          	lwu	a0,0(a5)
    800006f2:	d87ff0ef          	jal	80000478 <printint>
    800006f6:	b579                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	4601                	li	a2,0
    80000706:	45c1                	li	a1,16
    80000708:	6388                	ld	a0,0(a5)
    8000070a:	d6fff0ef          	jal	80000478 <printint>
      i += 1;
    8000070e:	0029849b          	addiw	s1,s3,2
    80000712:	bd8d                	j	80000584 <printk+0x7a>
    80000714:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000716:	f8843783          	ld	a5,-120(s0)
    8000071a:	00878713          	addi	a4,a5,8
    8000071e:	f8e43423          	sd	a4,-120(s0)
    80000722:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000726:	03000513          	li	a0,48
    8000072a:	b5fff0ef          	jal	80000288 <consputc>
  consputc('x');
    8000072e:	07800513          	li	a0,120
    80000732:	b57ff0ef          	jal	80000288 <consputc>
    80000736:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000738:	00007b97          	auipc	s7,0x7
    8000073c:	090b8b93          	addi	s7,s7,144 # 800077c8 <digits>
    80000740:	03c9d793          	srli	a5,s3,0x3c
    80000744:	97de                	add	a5,a5,s7
    80000746:	0007c503          	lbu	a0,0(a5)
    8000074a:	b3fff0ef          	jal	80000288 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000074e:	0992                	slli	s3,s3,0x4
    80000750:	397d                	addiw	s2,s2,-1
    80000752:	fe0917e3          	bnez	s2,80000740 <printk+0x236>
    80000756:	7be2                	ld	s7,56(sp)
    80000758:	b535                	j	80000584 <printk+0x7a>
      consputc(va_arg(ap, uint));
    8000075a:	f8843783          	ld	a5,-120(s0)
    8000075e:	00878713          	addi	a4,a5,8
    80000762:	f8e43423          	sd	a4,-120(s0)
    80000766:	4388                	lw	a0,0(a5)
    80000768:	b21ff0ef          	jal	80000288 <consputc>
    8000076c:	bd21                	j	80000584 <printk+0x7a>
      if ((s = va_arg(ap, char *)) == 0)
    8000076e:	f8843783          	ld	a5,-120(s0)
    80000772:	00878713          	addi	a4,a5,8
    80000776:	f8e43423          	sd	a4,-120(s0)
    8000077a:	0007b903          	ld	s2,0(a5)
    8000077e:	00090d63          	beqz	s2,80000798 <printk+0x28e>
      for (; *s; s++)
    80000782:	00094503          	lbu	a0,0(s2)
    80000786:	de050fe3          	beqz	a0,80000584 <printk+0x7a>
        consputc(*s);
    8000078a:	affff0ef          	jal	80000288 <consputc>
      for (; *s; s++)
    8000078e:	0905                	addi	s2,s2,1
    80000790:	00094503          	lbu	a0,0(s2)
    80000794:	f97d                	bnez	a0,8000078a <printk+0x280>
    80000796:	b3fd                	j	80000584 <printk+0x7a>
        s = "(null)";
    80000798:	00007917          	auipc	s2,0x7
    8000079c:	87090913          	addi	s2,s2,-1936 # 80007008 <etext+0x8>
      for (; *s; s++)
    800007a0:	02800513          	li	a0,40
    800007a4:	b7dd                	j	8000078a <printk+0x280>
    800007a6:	74a6                	ld	s1,104(sp)
    800007a8:	7906                	ld	s2,96(sp)
    800007aa:	69e6                	ld	s3,88(sp)
    800007ac:	6aa6                	ld	s5,72(sp)
    800007ae:	6b06                	ld	s6,64(sp)
    800007b0:	7c42                	ld	s8,48(sp)
    800007b2:	7ca2                	ld	s9,40(sp)
    800007b4:	7d02                	ld	s10,32(sp)
    800007b6:	6de2                	ld	s11,24(sp)
    800007b8:	a811                	j	800007cc <printk+0x2c2>
    800007ba:	74a6                	ld	s1,104(sp)
    800007bc:	7906                	ld	s2,96(sp)
    800007be:	69e6                	ld	s3,88(sp)
    800007c0:	6aa6                	ld	s5,72(sp)
    800007c2:	6b06                	ld	s6,64(sp)
    800007c4:	7c42                	ld	s8,48(sp)
    800007c6:	7ca2                	ld	s9,40(sp)
    800007c8:	7d02                	ld	s10,32(sp)
    800007ca:	6de2                	ld	s11,24(sp)
    }
  }
  va_end(ap);

  if (panicking == 0)
    800007cc:	00007797          	auipc	a5,0x7
    800007d0:	1287a783          	lw	a5,296(a5) # 800078f4 <panicking>
    800007d4:	c799                	beqz	a5,800007e2 <printk+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007d6:	4501                	li	a0,0
    800007d8:	70e6                	ld	ra,120(sp)
    800007da:	7446                	ld	s0,112(sp)
    800007dc:	6a46                	ld	s4,80(sp)
    800007de:	6129                	addi	sp,sp,192
    800007e0:	8082                	ret
    release(&pr.lock);
    800007e2:	0000f517          	auipc	a0,0xf
    800007e6:	1e650513          	addi	a0,a0,486 # 8000f9c8 <pr>
    800007ea:	4ee000ef          	jal	80000cd8 <release>
  return 0;
    800007ee:	b7e5                	j	800007d6 <printk+0x2cc>

00000000800007f0 <panic>:

void
panic(char *s)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	e04a                	sd	s2,0(sp)
    800007fa:	1000                	addi	s0,sp,32
    800007fc:	84aa                	mv	s1,a0
  panicking = 1;
    800007fe:	4905                	li	s2,1
    80000800:	00007797          	auipc	a5,0x7
    80000804:	0f27aa23          	sw	s2,244(a5) # 800078f4 <panicking>
  printk("panic: ");
    80000808:	00007517          	auipc	a0,0x7
    8000080c:	81050513          	addi	a0,a0,-2032 # 80007018 <etext+0x18>
    80000810:	cfbff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000814:	85a6                	mv	a1,s1
    80000816:	00007517          	auipc	a0,0x7
    8000081a:	80a50513          	addi	a0,a0,-2038 # 80007020 <etext+0x20>
    8000081e:	cedff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000822:	00007797          	auipc	a5,0x7
    80000826:	0d27a723          	sw	s2,206(a5) # 800078f0 <panicked>
  for (;;)
    8000082a:	a001                	j	8000082a <panic+0x3a>

000000008000082c <printkinit>:
    ;
}

void
printkinit(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e406                	sd	ra,8(sp)
    80000830:	e022                	sd	s0,0(sp)
    80000832:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000834:	00006597          	auipc	a1,0x6
    80000838:	7f458593          	addi	a1,a1,2036 # 80007028 <etext+0x28>
    8000083c:	0000f517          	auipc	a0,0xf
    80000840:	18c50513          	addi	a0,a0,396 # 8000f9c8 <pr>
    80000844:	392000ef          	jal	80000bd6 <initlock>
}
    80000848:	60a2                	ld	ra,8(sp)
    8000084a:	6402                	ld	s0,0(sp)
    8000084c:	0141                	addi	sp,sp,16
    8000084e:	8082                	ret

0000000080000850 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000850:	1141                	addi	sp,sp,-16
    80000852:	e406                	sd	ra,8(sp)
    80000854:	e022                	sd	s0,0(sp)
    80000856:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000858:	100007b7          	lui	a5,0x10000
    8000085c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000860:	10000737          	lui	a4,0x10000
    80000864:	f8000693          	li	a3,-128
    80000868:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000086c:	468d                	li	a3,3
    8000086e:	10000637          	lui	a2,0x10000
    80000872:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000876:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000087a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000087e:	10000737          	lui	a4,0x10000
    80000882:	461d                	li	a2,7
    80000884:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000888:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    8000088c:	00006597          	auipc	a1,0x6
    80000890:	7a458593          	addi	a1,a1,1956 # 80007030 <etext+0x30>
    80000894:	0000f517          	auipc	a0,0xf
    80000898:	14c50513          	addi	a0,a0,332 # 8000f9e0 <tx_lock>
    8000089c:	74e030ef          	jal	80003fea <initsleeplock>
}
    800008a0:	60a2                	ld	ra,8(sp)
    800008a2:	6402                	ld	s0,0(sp)
    800008a4:	0141                	addi	sp,sp,16
    800008a6:	8082                	ret

00000000800008a8 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008a8:	7139                	addi	sp,sp,-64
    800008aa:	fc06                	sd	ra,56(sp)
    800008ac:	f822                	sd	s0,48(sp)
    800008ae:	f04a                	sd	s2,32(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	0080                	addi	s0,sp,64
    800008b4:	8aaa                	mv	s5,a0
    800008b6:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008b8:	0000f517          	auipc	a0,0xf
    800008bc:	12850513          	addi	a0,a0,296 # 8000f9e0 <tx_lock>
    800008c0:	760030ef          	jal	80004020 <acquiresleep>

  int i = 0;
  while (i < n) {
    800008c4:	05205963          	blez	s2,80000916 <uartwrite+0x6e>
    800008c8:	f426                	sd	s1,40(sp)
    800008ca:	ec4e                	sd	s3,24(sp)
    800008cc:	e852                	sd	s4,16(sp)
    800008ce:	e05a                	sd	s6,0(sp)
  int i = 0;
    800008d0:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    800008d2:	00007a17          	auipc	s4,0x7
    800008d6:	026a0a13          	addi	s4,s4,38 # 800078f8 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008da:	100009b7          	lui	s3,0x10000
    800008de:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    800008e0:	10000b37          	lui	s6,0x10000
    800008e4:	a811                	j	800008f8 <uartwrite+0x50>
    800008e6:	009a87b3          	add	a5,s5,s1
    800008ea:	0007c783          	lbu	a5,0(a5)
    800008ee:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    800008f2:	2485                	addiw	s1,s1,1
  while (i < n) {
    800008f4:	0124dd63          	bge	s1,s2,8000090e <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    800008f8:	8552                	mv	a0,s4
    800008fa:	682010ef          	jal	80001f7c <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008fe:	0009c783          	lbu	a5,0(s3)
    80000902:	0207f793          	andi	a5,a5,32
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x3e>
    } else {
      sleep();
    80000908:	6b0010ef          	jal	80001fb8 <sleep>
    8000090c:	b7e5                	j	800008f4 <uartwrite+0x4c>
    8000090e:	74a2                	ld	s1,40(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000916:	0000f517          	auipc	a0,0xf
    8000091a:	0ca50513          	addi	a0,a0,202 # 8000f9e0 <tx_lock>
    8000091e:	756030ef          	jal	80004074 <releasesleep>
}
    80000922:	70e2                	ld	ra,56(sp)
    80000924:	7442                	ld	s0,48(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	6aa2                	ld	s5,8(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret

000000008000092e <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092e:	1101                	addi	sp,sp,-32
    80000930:	ec06                	sd	ra,24(sp)
    80000932:	e822                	sd	s0,16(sp)
    80000934:	e426                	sd	s1,8(sp)
    80000936:	1000                	addi	s0,sp,32
    80000938:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000093a:	00007797          	auipc	a5,0x7
    8000093e:	fba7a783          	lw	a5,-70(a5) # 800078f4 <panicking>
    80000942:	cf95                	beqz	a5,8000097e <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000944:	00007797          	auipc	a5,0x7
    80000948:	fac7a783          	lw	a5,-84(a5) # 800078f0 <panicked>
    8000094c:	ef85                	bnez	a5,80000984 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094e:	10000737          	lui	a4,0x10000
    80000952:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000954:	00074783          	lbu	a5,0(a4)
    80000958:	0207f793          	andi	a5,a5,32
    8000095c:	dfe5                	beqz	a5,80000954 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095e:	0ff4f513          	zext.b	a0,s1
    80000962:	100007b7          	lui	a5,0x10000
    80000966:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	f8a7a783          	lw	a5,-118(a5) # 800078f4 <panicking>
    80000972:	cb91                	beqz	a5,80000986 <uartputc_sync+0x58>
    pop_off();
}
    80000974:	60e2                	ld	ra,24(sp)
    80000976:	6442                	ld	s0,16(sp)
    80000978:	64a2                	ld	s1,8(sp)
    8000097a:	6105                	addi	sp,sp,32
    8000097c:	8082                	ret
    push_off();
    8000097e:	298000ef          	jal	80000c16 <push_off>
    80000982:	b7c9                	j	80000944 <uartputc_sync+0x16>
    for (;;)
    80000984:	a001                	j	80000984 <uartputc_sync+0x56>
    pop_off();
    80000986:	306000ef          	jal	80000c8c <pop_off>
}
    8000098a:	b7ed                	j	80000974 <uartputc_sync+0x46>

000000008000098c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000098c:	1101                	addi	sp,sp,-32
    8000098e:	ec06                	sd	ra,24(sp)
    80000990:	e822                	sd	s0,16(sp)
    80000992:	e426                	sd	s1,8(sp)
    80000994:	e04a                	sd	s2,0(sp)
    80000996:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    8000099e:	0007c783          	lbu	a5,0(a5)

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009a8:	0007c783          	lbu	a5,0(a5)
    800009ac:	0207f793          	andi	a5,a5,32
    800009b0:	ef99                	bnez	a5,800009ce <uartintr+0x42>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009b2:	100004b7          	lui	s1,0x10000
    800009b6:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009b8:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009bc:	0004c783          	lbu	a5,0(s1)
    800009c0:	8b85                	andi	a5,a5,1
    800009c2:	cf89                	beqz	a5,800009dc <uartintr+0x50>
    return ReadReg(RHR);
    800009c4:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    800009c8:	8f3ff0ef          	jal	800002ba <consoleintr>
  while (1) {
    800009cc:	bfc5                	j	800009bc <uartintr+0x30>
    wakeup(&tx_chan);
    800009ce:	00007517          	auipc	a0,0x7
    800009d2:	f2a50513          	addi	a0,a0,-214 # 800078f8 <tx_chan>
    800009d6:	612010ef          	jal	80001fe8 <wakeup>
    800009da:	bfe1                	j	800009b2 <uartintr+0x26>
  }
}
    800009dc:	60e2                	ld	ra,24(sp)
    800009de:	6442                	ld	s0,16(sp)
    800009e0:	64a2                	ld	s1,8(sp)
    800009e2:	6902                	ld	s2,0(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	e7a9                	bnez	a5,80000a42 <kfree+0x5a>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00020797          	auipc	a5,0x20
    80000a00:	24478793          	addi	a5,a5,580 # 80020c40 <end>
    80000a04:	02f56f63          	bltu	a0,a5,80000a42 <kfree+0x5a>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	02f57b63          	bgeu	a0,a5,80000a42 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	2fc000ef          	jal	80000d10 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a18:	0000f917          	auipc	s2,0xf
    80000a1c:	ff890913          	addi	s2,s2,-8 # 8000fa10 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	22a000ef          	jal	80000c4c <acquire>
  r->next = kmem.freelist;
    80000a26:	01893783          	ld	a5,24(s2)
    80000a2a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a30:	854a                	mv	a0,s2
    80000a32:	2a6000ef          	jal	80000cd8 <release>
}
    80000a36:	60e2                	ld	ra,24(sp)
    80000a38:	6442                	ld	s0,16(sp)
    80000a3a:	64a2                	ld	s1,8(sp)
    80000a3c:	6902                	ld	s2,0(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret
    panic("kfree");
    80000a42:	00006517          	auipc	a0,0x6
    80000a46:	5f650513          	addi	a0,a0,1526 # 80007038 <etext+0x38>
    80000a4a:	da7ff0ef          	jal	800007f0 <panic>

0000000080000a4e <freerange>:
{
    80000a4e:	7179                	addi	sp,sp,-48
    80000a50:	f406                	sd	ra,40(sp)
    80000a52:	f022                	sd	s0,32(sp)
    80000a54:	ec26                	sd	s1,24(sp)
    80000a56:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a58:	6785                	lui	a5,0x1
    80000a5a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a5e:	00e504b3          	add	s1,a0,a4
    80000a62:	777d                	lui	a4,0xfffff
    80000a64:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a66:	94be                	add	s1,s1,a5
    80000a68:	0295e263          	bltu	a1,s1,80000a8c <freerange+0x3e>
    80000a6c:	e84a                	sd	s2,16(sp)
    80000a6e:	e44e                	sd	s3,8(sp)
    80000a70:	e052                	sd	s4,0(sp)
    80000a72:	892e                	mv	s2,a1
    kfree(p);
    80000a74:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a76:	6985                	lui	s3,0x1
    kfree(p);
    80000a78:	01448533          	add	a0,s1,s4
    80000a7c:	f6dff0ef          	jal	800009e8 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe997be3          	bgeu	s2,s1,80000a78 <freerange+0x2a>
    80000a86:	6942                	ld	s2,16(sp)
    80000a88:	69a2                	ld	s3,8(sp)
    80000a8a:	6a02                	ld	s4,0(sp)
}
    80000a8c:	70a2                	ld	ra,40(sp)
    80000a8e:	7402                	ld	s0,32(sp)
    80000a90:	64e2                	ld	s1,24(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00006597          	auipc	a1,0x6
    80000aa2:	5a258593          	addi	a1,a1,1442 # 80007040 <etext+0x40>
    80000aa6:	0000f517          	auipc	a0,0xf
    80000aaa:	f6a50513          	addi	a0,a0,-150 # 8000fa10 <kmem>
    80000aae:	128000ef          	jal	80000bd6 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000ab2:	45c5                	li	a1,17
    80000ab4:	05ee                	slli	a1,a1,0x1b
    80000ab6:	00020517          	auipc	a0,0x20
    80000aba:	18a50513          	addi	a0,a0,394 # 80020c40 <end>
    80000abe:	f91ff0ef          	jal	80000a4e <freerange>
}
    80000ac2:	60a2                	ld	ra,8(sp)
    80000ac4:	6402                	ld	s0,0(sp)
    80000ac6:	0141                	addi	sp,sp,16
    80000ac8:	8082                	ret

0000000080000aca <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000aca:	1101                	addi	sp,sp,-32
    80000acc:	ec06                	sd	ra,24(sp)
    80000ace:	e822                	sd	s0,16(sp)
    80000ad0:	e426                	sd	s1,8(sp)
    80000ad2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ad4:	0000f497          	auipc	s1,0xf
    80000ad8:	f3c48493          	addi	s1,s1,-196 # 8000fa10 <kmem>
    80000adc:	8526                	mv	a0,s1
    80000ade:	16e000ef          	jal	80000c4c <acquire>
  r = kmem.freelist;
    80000ae2:	6c84                	ld	s1,24(s1)
  if (r)
    80000ae4:	c485                	beqz	s1,80000b0c <kalloc+0x42>
    kmem.freelist = r->next;
    80000ae6:	609c                	ld	a5,0(s1)
    80000ae8:	0000f517          	auipc	a0,0xf
    80000aec:	f2850513          	addi	a0,a0,-216 # 8000fa10 <kmem>
    80000af0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000af2:	1e6000ef          	jal	80000cd8 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000af6:	6605                	lui	a2,0x1
    80000af8:	4595                	li	a1,5
    80000afa:	8526                	mv	a0,s1
    80000afc:	214000ef          	jal	80000d10 <memset>
  return (void *)r;
}
    80000b00:	8526                	mv	a0,s1
    80000b02:	60e2                	ld	ra,24(sp)
    80000b04:	6442                	ld	s0,16(sp)
    80000b06:	64a2                	ld	s1,8(sp)
    80000b08:	6105                	addi	sp,sp,32
    80000b0a:	8082                	ret
  release(&kmem.lock);
    80000b0c:	0000f517          	auipc	a0,0xf
    80000b10:	f0450513          	addi	a0,a0,-252 # 8000fa10 <kmem>
    80000b14:	1c4000ef          	jal	80000cd8 <release>
  if (r)
    80000b18:	b7e5                	j	80000b00 <kalloc+0x36>

0000000080000b1a <cksum_partial>:
// len > ~128 KB, xa lon hon MTU nen khong can xu ly.
// Cung dung duoc de noi nhieu vung: chi dung neu moi vung tru vung cuoi
// co do dai CHAN (pseudo-header UDP = 12 byte, header = 8 byte -> thoa).
uint32
cksum_partial(uint32 sum, const void *buf, int len)
{
    80000b1a:	1141                	addi	sp,sp,-16
    80000b1c:	e422                	sd	s0,8(sp)
    80000b1e:	0800                	addi	s0,sp,16
  const uint8 *p = (const uint8 *)buf;

  while (len > 1) {
    80000b20:	4785                	li	a5,1
    80000b22:	04c7d363          	bge	a5,a2,80000b68 <cksum_partial+0x4e>
    80000b26:	ffe6081b          	addiw	a6,a2,-2 # ffe <_entry-0x7ffff002>
    80000b2a:	0018581b          	srliw	a6,a6,0x1
    80000b2e:	0018069b          	addiw	a3,a6,1
    80000b32:	02069793          	slli	a5,a3,0x20
    80000b36:	01f7d693          	srli	a3,a5,0x1f
    80000b3a:	96ae                	add	a3,a3,a1
    sum += ((uint32)p[0] << 8) | p[1];
    80000b3c:	0005c783          	lbu	a5,0(a1)
    80000b40:	0087979b          	slliw	a5,a5,0x8
    80000b44:	0015c703          	lbu	a4,1(a1)
    80000b48:	8fd9                	or	a5,a5,a4
    80000b4a:	9d3d                	addw	a0,a0,a5
    p += 2;
    80000b4c:	0589                	addi	a1,a1,2
  while (len > 1) {
    80000b4e:	fed597e3          	bne	a1,a3,80000b3c <cksum_partial+0x22>
    80000b52:	3679                	addiw	a2,a2,-2
    80000b54:	0018181b          	slliw	a6,a6,0x1
    80000b58:	4106063b          	subw	a2,a2,a6
    len -= 2;
  }
  if (len == 1)
    80000b5c:	4785                	li	a5,1
    80000b5e:	00f60763          	beq	a2,a5,80000b6c <cksum_partial+0x52>
    sum += (uint32)p[0] << 8;
  return sum;
}
    80000b62:	6422                	ld	s0,8(sp)
    80000b64:	0141                	addi	sp,sp,16
    80000b66:	8082                	ret
  const uint8 *p = (const uint8 *)buf;
    80000b68:	86ae                	mv	a3,a1
    80000b6a:	bfcd                	j	80000b5c <cksum_partial+0x42>
    sum += (uint32)p[0] << 8;
    80000b6c:	0006c783          	lbu	a5,0(a3)
    80000b70:	0087979b          	slliw	a5,a5,0x8
    80000b74:	9d3d                	addw	a0,a0,a5
    80000b76:	b7f5                	j	80000b62 <cksum_partial+0x48>

0000000080000b78 <cksum_finish>:

uint16
cksum_finish(uint32 sum)
{
    80000b78:	1141                	addi	sp,sp,-16
    80000b7a:	e422                	sd	s0,8(sp)
    80000b7c:	0800                	addi	s0,sp,16
  while (sum >> 16)
    80000b7e:	0105579b          	srliw	a5,a0,0x10
    80000b82:	cb91                	beqz	a5,80000b96 <cksum_finish+0x1e>
    sum = (sum & 0xffff) + (sum >> 16);
    80000b84:	6741                	lui	a4,0x10
    80000b86:	177d                	addi	a4,a4,-1 # ffff <_entry-0x7fff0001>
    80000b88:	8d79                	and	a0,a0,a4
    80000b8a:	9fa9                	addw	a5,a5,a0
    80000b8c:	0007851b          	sext.w	a0,a5
  while (sum >> 16)
    80000b90:	0107d79b          	srliw	a5,a5,0x10
    80000b94:	fbf5                	bnez	a5,80000b88 <cksum_finish+0x10>
  return htons((uint16)~sum);
    80000b96:	fff54513          	not	a0,a0
#define NET_H

#define NET_PACKED __attribute__((packed))

// ---- Byte order (RISC-V little-endian) ----
static inline uint16 bswap16(uint16 x) { return (uint16)((x << 8) | (x >> 8)); }
    80000b9a:	0085179b          	slliw	a5,a0,0x8
    80000b9e:	0105151b          	slliw	a0,a0,0x10
    80000ba2:	0105551b          	srliw	a0,a0,0x10
    80000ba6:	0085551b          	srliw	a0,a0,0x8
    80000baa:	8d5d                	or	a0,a0,a5
}
    80000bac:	1542                	slli	a0,a0,0x30
    80000bae:	9141                	srli	a0,a0,0x30
    80000bb0:	6422                	ld	s0,8(sp)
    80000bb2:	0141                	addi	sp,sp,16
    80000bb4:	8082                	ret

0000000080000bb6 <in_cksum>:

uint16
in_cksum(const void *buf, int len)
{
    80000bb6:	1141                	addi	sp,sp,-16
    80000bb8:	e406                	sd	ra,8(sp)
    80000bba:	e022                	sd	s0,0(sp)
    80000bbc:	0800                	addi	s0,sp,16
    80000bbe:	862e                	mv	a2,a1
  return cksum_finish(cksum_partial(0, buf, len));
    80000bc0:	85aa                	mv	a1,a0
    80000bc2:	4501                	li	a0,0
    80000bc4:	f57ff0ef          	jal	80000b1a <cksum_partial>
    80000bc8:	2501                	sext.w	a0,a0
    80000bca:	fafff0ef          	jal	80000b78 <cksum_finish>
}
    80000bce:	60a2                	ld	ra,8(sp)
    80000bd0:	6402                	ld	s0,0(sp)
    80000bd2:	0141                	addi	sp,sp,16
    80000bd4:	8082                	ret

0000000080000bd6 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bd6:	1141                	addi	sp,sp,-16
    80000bd8:	e422                	sd	s0,8(sp)
    80000bda:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bdc:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bde:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000be2:	00053823          	sd	zero,16(a0)
}
    80000be6:	6422                	ld	s0,8(sp)
    80000be8:	0141                	addi	sp,sp,16
    80000bea:	8082                	ret

0000000080000bec <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bec:	411c                	lw	a5,0(a0)
    80000bee:	e399                	bnez	a5,80000bf4 <holding+0x8>
    80000bf0:	4501                	li	a0,0
  return r;
}
    80000bf2:	8082                	ret
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bfe:	6904                	ld	s1,16(a0)
    80000c00:	55d000ef          	jal	8000195c <mycpu>
    80000c04:	40a48533          	sub	a0,s1,a0
    80000c08:	00153513          	seqz	a0,a0
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret

0000000080000c16 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c16:	1101                	addi	sp,sp,-32
    80000c18:	ec06                	sd	ra,24(sp)
    80000c1a:	e822                	sd	s0,16(sp)
    80000c1c:	e426                	sd	s1,8(sp)
    80000c1e:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000c20:	100174f3          	csrrci	s1,sstatus,2
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000c24:	539000ef          	jal	8000195c <mycpu>
    80000c28:	5d3c                	lw	a5,120(a0)
    80000c2a:	cb99                	beqz	a5,80000c40 <push_off+0x2a>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c2c:	531000ef          	jal	8000195c <mycpu>
    80000c30:	5d3c                	lw	a5,120(a0)
    80000c32:	2785                	addiw	a5,a5,1
    80000c34:	dd3c                	sw	a5,120(a0)
}
    80000c36:	60e2                	ld	ra,24(sp)
    80000c38:	6442                	ld	s0,16(sp)
    80000c3a:	64a2                	ld	s1,8(sp)
    80000c3c:	6105                	addi	sp,sp,32
    80000c3e:	8082                	ret
    mycpu()->intena = old;
    80000c40:	51d000ef          	jal	8000195c <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000c44:	8085                	srli	s1,s1,0x1
    80000c46:	8885                	andi	s1,s1,1
    mycpu()->intena = old;
    80000c48:	dd64                	sw	s1,124(a0)
    80000c4a:	b7cd                	j	80000c2c <push_off+0x16>

0000000080000c4c <acquire>:
{
    80000c4c:	1101                	addi	sp,sp,-32
    80000c4e:	ec06                	sd	ra,24(sp)
    80000c50:	e822                	sd	s0,16(sp)
    80000c52:	e426                	sd	s1,8(sp)
    80000c54:	1000                	addi	s0,sp,32
    80000c56:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c58:	fbfff0ef          	jal	80000c16 <push_off>
  if (holding(lk))
    80000c5c:	8526                	mv	a0,s1
    80000c5e:	f8fff0ef          	jal	80000bec <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c62:	4705                	li	a4,1
  if (holding(lk))
    80000c64:	ed11                	bnez	a0,80000c80 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c66:	87ba                	mv	a5,a4
    80000c68:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c6c:	2781                	sext.w	a5,a5
    80000c6e:	ffe5                	bnez	a5,80000c66 <acquire+0x1a>
  lk->cpu = mycpu();
    80000c70:	4ed000ef          	jal	8000195c <mycpu>
    80000c74:	e888                	sd	a0,16(s1)
}
    80000c76:	60e2                	ld	ra,24(sp)
    80000c78:	6442                	ld	s0,16(sp)
    80000c7a:	64a2                	ld	s1,8(sp)
    80000c7c:	6105                	addi	sp,sp,32
    80000c7e:	8082                	ret
    panic("acquire");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3c850513          	addi	a0,a0,968 # 80007048 <etext+0x48>
    80000c88:	b69ff0ef          	jal	800007f0 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	addi	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	4c9000ef          	jal	8000195c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c98:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c9c:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c9e:	e38d                	bnez	a5,80000cc0 <pop_off+0x34>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000ca0:	5d3c                	lw	a5,120(a0)
    80000ca2:	02f05563          	blez	a5,80000ccc <pop_off+0x40>
    panic("pop_off");
  c->noff -= 1;
    80000ca6:	37fd                	addiw	a5,a5,-1
    80000ca8:	0007871b          	sext.w	a4,a5
    80000cac:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000cae:	e709                	bnez	a4,80000cb8 <pop_off+0x2c>
    80000cb0:	5d7c                	lw	a5,124(a0)
    80000cb2:	c399                	beqz	a5,80000cb8 <pop_off+0x2c>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000cb4:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000cb8:	60a2                	ld	ra,8(sp)
    80000cba:	6402                	ld	s0,0(sp)
    80000cbc:	0141                	addi	sp,sp,16
    80000cbe:	8082                	ret
    panic("pop_off - interruptible");
    80000cc0:	00006517          	auipc	a0,0x6
    80000cc4:	39050513          	addi	a0,a0,912 # 80007050 <etext+0x50>
    80000cc8:	b29ff0ef          	jal	800007f0 <panic>
    panic("pop_off");
    80000ccc:	00006517          	auipc	a0,0x6
    80000cd0:	39c50513          	addi	a0,a0,924 # 80007068 <etext+0x68>
    80000cd4:	b1dff0ef          	jal	800007f0 <panic>

0000000080000cd8 <release>:
{
    80000cd8:	1101                	addi	sp,sp,-32
    80000cda:	ec06                	sd	ra,24(sp)
    80000cdc:	e822                	sd	s0,16(sp)
    80000cde:	e426                	sd	s1,8(sp)
    80000ce0:	1000                	addi	s0,sp,32
    80000ce2:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000ce4:	f09ff0ef          	jal	80000bec <holding>
    80000ce8:	cd11                	beqz	a0,80000d04 <release+0x2c>
  lk->cpu = 0;
    80000cea:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000cee:	0f50000f          	fence	iorw,ow
    80000cf2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cf6:	f97ff0ef          	jal	80000c8c <pop_off>
}
    80000cfa:	60e2                	ld	ra,24(sp)
    80000cfc:	6442                	ld	s0,16(sp)
    80000cfe:	64a2                	ld	s1,8(sp)
    80000d00:	6105                	addi	sp,sp,32
    80000d02:	8082                	ret
    panic("release");
    80000d04:	00006517          	auipc	a0,0x6
    80000d08:	36c50513          	addi	a0,a0,876 # 80007070 <etext+0x70>
    80000d0c:	ae5ff0ef          	jal	800007f0 <panic>

0000000080000d10 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000d10:	1141                	addi	sp,sp,-16
    80000d12:	e422                	sd	s0,8(sp)
    80000d14:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000d16:	ca19                	beqz	a2,80000d2c <memset+0x1c>
    80000d18:	87aa                	mv	a5,a0
    80000d1a:	1602                	slli	a2,a2,0x20
    80000d1c:	9201                	srli	a2,a2,0x20
    80000d1e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d22:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000d26:	0785                	addi	a5,a5,1
    80000d28:	fee79de3          	bne	a5,a4,80000d22 <memset+0x12>
  }
  return dst;
}
    80000d2c:	6422                	ld	s0,8(sp)
    80000d2e:	0141                	addi	sp,sp,16
    80000d30:	8082                	ret

0000000080000d32 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e422                	sd	s0,8(sp)
    80000d36:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000d38:	ca05                	beqz	a2,80000d68 <memcmp+0x36>
    80000d3a:	fff6069b          	addiw	a3,a2,-1
    80000d3e:	1682                	slli	a3,a3,0x20
    80000d40:	9281                	srli	a3,a3,0x20
    80000d42:	0685                	addi	a3,a3,1
    80000d44:	96aa                	add	a3,a3,a0
    if (*s1 != *s2)
    80000d46:	00054783          	lbu	a5,0(a0)
    80000d4a:	0005c703          	lbu	a4,0(a1)
    80000d4e:	00e79863          	bne	a5,a4,80000d5e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d52:	0505                	addi	a0,a0,1
    80000d54:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000d56:	fed518e3          	bne	a0,a3,80000d46 <memcmp+0x14>
  }

  return 0;
    80000d5a:	4501                	li	a0,0
    80000d5c:	a019                	j	80000d62 <memcmp+0x30>
      return *s1 - *s2;
    80000d5e:	40e7853b          	subw	a0,a5,a4
}
    80000d62:	6422                	ld	s0,8(sp)
    80000d64:	0141                	addi	sp,sp,16
    80000d66:	8082                	ret
  return 0;
    80000d68:	4501                	li	a0,0
    80000d6a:	bfe5                	j	80000d62 <memcmp+0x30>

0000000080000d6c <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000d6c:	1141                	addi	sp,sp,-16
    80000d6e:	e422                	sd	s0,8(sp)
    80000d70:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000d72:	c205                	beqz	a2,80000d92 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000d74:	02a5e263          	bltu	a1,a0,80000d98 <memmove+0x2c>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000d78:	1602                	slli	a2,a2,0x20
    80000d7a:	9201                	srli	a2,a2,0x20
    80000d7c:	00c587b3          	add	a5,a1,a2
{
    80000d80:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d82:	0585                	addi	a1,a1,1
    80000d84:	0705                	addi	a4,a4,1
    80000d86:	fff5c683          	lbu	a3,-1(a1)
    80000d8a:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d8e:	feb79ae3          	bne	a5,a1,80000d82 <memmove+0x16>

  return dst;
}
    80000d92:	6422                	ld	s0,8(sp)
    80000d94:	0141                	addi	sp,sp,16
    80000d96:	8082                	ret
  if (s < d && s + n > d) {
    80000d98:	02061693          	slli	a3,a2,0x20
    80000d9c:	9281                	srli	a3,a3,0x20
    80000d9e:	00d58733          	add	a4,a1,a3
    80000da2:	fce57be3          	bgeu	a0,a4,80000d78 <memmove+0xc>
    d += n;
    80000da6:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000da8:	fff6079b          	addiw	a5,a2,-1
    80000dac:	1782                	slli	a5,a5,0x20
    80000dae:	9381                	srli	a5,a5,0x20
    80000db0:	fff7c793          	not	a5,a5
    80000db4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000db6:	177d                	addi	a4,a4,-1
    80000db8:	16fd                	addi	a3,a3,-1
    80000dba:	00074603          	lbu	a2,0(a4)
    80000dbe:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000dc2:	fef71ae3          	bne	a4,a5,80000db6 <memmove+0x4a>
    80000dc6:	b7f1                	j	80000d92 <memmove+0x26>

0000000080000dc8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000dc8:	1141                	addi	sp,sp,-16
    80000dca:	e406                	sd	ra,8(sp)
    80000dcc:	e022                	sd	s0,0(sp)
    80000dce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd0:	f9dff0ef          	jal	80000d6c <memmove>
}
    80000dd4:	60a2                	ld	ra,8(sp)
    80000dd6:	6402                	ld	s0,0(sp)
    80000dd8:	0141                	addi	sp,sp,16
    80000dda:	8082                	ret

0000000080000ddc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ddc:	1141                	addi	sp,sp,-16
    80000dde:	e422                	sd	s0,8(sp)
    80000de0:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000de2:	ce11                	beqz	a2,80000dfe <strncmp+0x22>
    80000de4:	00054783          	lbu	a5,0(a0)
    80000de8:	cf89                	beqz	a5,80000e02 <strncmp+0x26>
    80000dea:	0005c703          	lbu	a4,0(a1)
    80000dee:	00f71a63          	bne	a4,a5,80000e02 <strncmp+0x26>
    n--, p++, q++;
    80000df2:	367d                	addiw	a2,a2,-1
    80000df4:	0505                	addi	a0,a0,1
    80000df6:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000df8:	f675                	bnez	a2,80000de4 <strncmp+0x8>
  if (n == 0)
    return 0;
    80000dfa:	4501                	li	a0,0
    80000dfc:	a801                	j	80000e0c <strncmp+0x30>
    80000dfe:	4501                	li	a0,0
    80000e00:	a031                	j	80000e0c <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e02:	00054503          	lbu	a0,0(a0)
    80000e06:	0005c783          	lbu	a5,0(a1)
    80000e0a:	9d1d                	subw	a0,a0,a5
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000e18:	87aa                	mv	a5,a0
    80000e1a:	86b2                	mv	a3,a2
    80000e1c:	367d                	addiw	a2,a2,-1
    80000e1e:	02d05563          	blez	a3,80000e48 <strncpy+0x36>
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	0005c703          	lbu	a4,0(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	0585                	addi	a1,a1,1
    80000e2e:	f775                	bnez	a4,80000e1a <strncpy+0x8>
    ;
  while (n-- > 0)
    80000e30:	873e                	mv	a4,a5
    80000e32:	9fb5                	addw	a5,a5,a3
    80000e34:	37fd                	addiw	a5,a5,-1
    80000e36:	00c05963          	blez	a2,80000e48 <strncpy+0x36>
    *s++ = 0;
    80000e3a:	0705                	addi	a4,a4,1
    80000e3c:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000e40:	40e786bb          	subw	a3,a5,a4
    80000e44:	fed04be3          	bgtz	a3,80000e3a <strncpy+0x28>
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2c>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x28>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	6422                	ld	s0,8(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret

0000000080000e80 <strlen>:

int
strlen(const char *s)
{
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e422                	sd	s0,8(sp)
    80000e84:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e86:	00054783          	lbu	a5,0(a0)
    80000e8a:	cf91                	beqz	a5,80000ea6 <strlen+0x26>
    80000e8c:	0505                	addi	a0,a0,1
    80000e8e:	87aa                	mv	a5,a0
    80000e90:	86be                	mv	a3,a5
    80000e92:	0785                	addi	a5,a5,1
    80000e94:	fff7c703          	lbu	a4,-1(a5)
    80000e98:	ff65                	bnez	a4,80000e90 <strlen+0x10>
    80000e9a:	40a6853b          	subw	a0,a3,a0
    80000e9e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ea0:	6422                	ld	s0,8(sp)
    80000ea2:	0141                	addi	sp,sp,16
    80000ea4:	8082                	ret
  for (n = 0; s[n]; n++)
    80000ea6:	4501                	li	a0,0
    80000ea8:	bfe5                	j	80000ea0 <strlen+0x20>

0000000080000eaa <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eaa:	1141                	addi	sp,sp,-16
    80000eac:	e406                	sd	ra,8(sp)
    80000eae:	e022                	sd	s0,0(sp)
    80000eb0:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000eb2:	29b000ef          	jal	8000194c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000eb6:	00007717          	auipc	a4,0x7
    80000eba:	a4670713          	addi	a4,a4,-1466 # 800078fc <started>
  if (cpuid() == 0) {
    80000ebe:	c51d                	beqz	a0,80000eec <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000ec0:	431c                	lw	a5,0(a4)
    80000ec2:	0ff0000f          	fence
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dfe5                	beqz	a5,80000ec0 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000eca:	283000ef          	jal	8000194c <cpuid>
    80000ece:	85aa                	mv	a1,a0
    80000ed0:	00006517          	auipc	a0,0x6
    80000ed4:	1c850513          	addi	a0,a0,456 # 80007098 <etext+0x98>
    80000ed8:	e32ff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000edc:	088000ef          	jal	80000f64 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ee0:	5fa010ef          	jal	800024da <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ee4:	794040ef          	jal	80005678 <plicinithart>
  }

  scheduler();
    80000ee8:	6fb000ef          	jal	80001de2 <scheduler>
    consoleinit();
    80000eec:	d48ff0ef          	jal	80000434 <consoleinit>
    printkinit();
    80000ef0:	93dff0ef          	jal	8000082c <printkinit>
    printk("\n");
    80000ef4:	00006517          	auipc	a0,0x6
    80000ef8:	18450513          	addi	a0,a0,388 # 80007078 <etext+0x78>
    80000efc:	e0eff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000f00:	00006517          	auipc	a0,0x6
    80000f04:	18050513          	addi	a0,a0,384 # 80007080 <etext+0x80>
    80000f08:	e02ff0ef          	jal	8000050a <printk>
    printk("\n");
    80000f0c:	00006517          	auipc	a0,0x6
    80000f10:	16c50513          	addi	a0,a0,364 # 80007078 <etext+0x78>
    80000f14:	df6ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000f18:	b7fff0ef          	jal	80000a96 <kinit>
    kvminit();          // create kernel page table
    80000f1c:	2e6000ef          	jal	80001202 <kvminit>
    kvminithart();      // turn on paging
    80000f20:	044000ef          	jal	80000f64 <kvminithart>
    pci_init();
    80000f24:	51d040ef          	jal	80005c40 <pci_init>
    procinit();         // process table
    80000f28:	16f000ef          	jal	80001896 <procinit>
    trapinit();         // trap vectors
    80000f2c:	58a010ef          	jal	800024b6 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f30:	5aa010ef          	jal	800024da <trapinithart>
    plicinit();         // set up interrupt controller
    80000f34:	72a040ef          	jal	8000565e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f38:	740040ef          	jal	80005678 <plicinithart>
    binit();            // buffer cache
    80000f3c:	43b010ef          	jal	80002b76 <binit>
    iinit();            // inode table
    80000f40:	1c0020ef          	jal	80003100 <iinit>
    fileinit();         // file table
    80000f44:	1b2030ef          	jal	800040f6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	029040ef          	jal	80005770 <virtio_disk_init>
    userinit();         // first user process
    80000f4c:	4eb000ef          	jal	80001c36 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f50:	00007797          	auipc	a5,0x7
    80000f54:	9ac78793          	addi	a5,a5,-1620 # 800078fc <started>
    80000f58:	4705                	li	a4,1
    80000f5a:	0f50000f          	fence	iorw,ow
    80000f5e:	08e7a02f          	amoswap.w	zero,a4,(a5)
    80000f62:	b759                	j	80000ee8 <main+0x3e>

0000000080000f64 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f64:	1141                	addi	sp,sp,-16
    80000f66:	e422                	sd	s0,8(sp)
    80000f68:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f6a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6e:	00007797          	auipc	a5,0x7
    80000f72:	9927b783          	ld	a5,-1646(a5) # 80007900 <kernel_pagetable>
    80000f76:	83b1                	srli	a5,a5,0xc
    80000f78:	577d                	li	a4,-1
    80000f7a:	177e                	slli	a4,a4,0x3f
    80000f7c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f7e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f82:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f86:	6422                	ld	s0,8(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000fac:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000fae:	02b7fc63          	bgeu	a5,a1,80000fe6 <walk+0x5a>
    panic("walk");
    80000fb2:	00006517          	auipc	a0,0x6
    80000fb6:	0fe50513          	addi	a0,a0,254 # 800070b0 <etext+0xb0>
    80000fba:	837ff0ef          	jal	800007f0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if (*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000fbe:	060a8263          	beqz	s5,80001022 <walk+0x96>
    80000fc2:	b09ff0ef          	jal	80000aca <kalloc>
    80000fc6:	84aa                	mv	s1,a0
    80000fc8:	c139                	beqz	a0,8000100e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fca:	6605                	lui	a2,0x1
    80000fcc:	4581                	li	a1,0
    80000fce:	d43ff0ef          	jal	80000d10 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fd2:	00c4d793          	srli	a5,s1,0xc
    80000fd6:	07aa                	slli	a5,a5,0xa
    80000fd8:	0017e793          	ori	a5,a5,1
    80000fdc:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--) {
    80000fe0:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde3b7>
    80000fe2:	036a0063          	beq	s4,s6,80001002 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fe6:	0149d933          	srl	s2,s3,s4
    80000fea:	1ff97913          	andi	s2,s2,511
    80000fee:	090e                	slli	s2,s2,0x3
    80000ff0:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000ff2:	00093483          	ld	s1,0(s2)
    80000ff6:	0014f793          	andi	a5,s1,1
    80000ffa:	d3f1                	beqz	a5,80000fbe <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000ffc:	80a9                	srli	s1,s1,0xa
    80000ffe:	04b2                	slli	s1,s1,0xc
    80001000:	b7c5                	j	80000fe0 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001002:	00c9d513          	srli	a0,s3,0xc
    80001006:	1ff57513          	andi	a0,a0,511
    8000100a:	050e                	slli	a0,a0,0x3
    8000100c:	9526                	add	a0,a0,s1
}
    8000100e:	70e2                	ld	ra,56(sp)
    80001010:	7442                	ld	s0,48(sp)
    80001012:	74a2                	ld	s1,40(sp)
    80001014:	7902                	ld	s2,32(sp)
    80001016:	69e2                	ld	s3,24(sp)
    80001018:	6a42                	ld	s4,16(sp)
    8000101a:	6aa2                	ld	s5,8(sp)
    8000101c:	6b02                	ld	s6,0(sp)
    8000101e:	6121                	addi	sp,sp,64
    80001020:	8082                	ret
        return 0;
    80001022:	4501                	li	a0,0
    80001024:	b7ed                	j	8000100e <walk+0x82>

0000000080001026 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	00b7f463          	bgeu	a5,a1,80001032 <walkaddr+0xc>
    return 0;
    8000102e:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001030:	8082                	ret
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e406                	sd	ra,8(sp)
    80001036:	e022                	sd	s0,0(sp)
    80001038:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103a:	4601                	li	a2,0
    8000103c:	f51ff0ef          	jal	80000f8c <walk>
  if (pte == 0)
    80001040:	c105                	beqz	a0,80001060 <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    80001042:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80001044:	0117f693          	andi	a3,a5,17
    80001048:	4745                	li	a4,17
    return 0;
    8000104a:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    8000104c:	00e68663          	beq	a3,a4,80001058 <walkaddr+0x32>
}
    80001050:	60a2                	ld	ra,8(sp)
    80001052:	6402                	ld	s0,0(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret
  pa = PTE2PA(*pte);
    80001058:	83a9                	srli	a5,a5,0xa
    8000105a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000105e:	bfcd                	j	80001050 <walkaddr+0x2a>
    return 0;
    80001060:	4501                	li	a0,0
    80001062:	b7fd                	j	80001050 <walkaddr+0x2a>

0000000080001064 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001064:	715d                	addi	sp,sp,-80
    80001066:	e486                	sd	ra,72(sp)
    80001068:	e0a2                	sd	s0,64(sp)
    8000106a:	fc26                	sd	s1,56(sp)
    8000106c:	f84a                	sd	s2,48(sp)
    8000106e:	f44e                	sd	s3,40(sp)
    80001070:	f052                	sd	s4,32(sp)
    80001072:	ec56                	sd	s5,24(sp)
    80001074:	e85a                	sd	s6,16(sp)
    80001076:	e45e                	sd	s7,8(sp)
    80001078:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    8000107a:	03459793          	slli	a5,a1,0x34
    8000107e:	e7a9                	bnez	a5,800010c8 <mappages+0x64>
    80001080:	8aaa                	mv	s5,a0
    80001082:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001084:	03461793          	slli	a5,a2,0x34
    80001088:	e7b1                	bnez	a5,800010d4 <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    8000108a:	ca39                	beqz	a2,800010e0 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000108c:	77fd                	lui	a5,0xfffff
    8000108e:	963e                	add	a2,a2,a5
    80001090:	00b609b3          	add	s3,a2,a1
  a = va;
    80001094:	892e                	mv	s2,a1
    80001096:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    8000109a:	6b85                	lui	s7,0x1
    8000109c:	014904b3          	add	s1,s2,s4
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010a0:	4605                	li	a2,1
    800010a2:	85ca                	mv	a1,s2
    800010a4:	8556                	mv	a0,s5
    800010a6:	ee7ff0ef          	jal	80000f8c <walk>
    800010aa:	c539                	beqz	a0,800010f8 <mappages+0x94>
    if (*pte & PTE_V)
    800010ac:	611c                	ld	a5,0(a0)
    800010ae:	8b85                	andi	a5,a5,1
    800010b0:	ef95                	bnez	a5,800010ec <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b2:	80b1                	srli	s1,s1,0xc
    800010b4:	04aa                	slli	s1,s1,0xa
    800010b6:	0164e4b3          	or	s1,s1,s6
    800010ba:	0014e493          	ori	s1,s1,1
    800010be:	e104                	sd	s1,0(a0)
    if (a == last)
    800010c0:	05390863          	beq	s2,s3,80001110 <mappages+0xac>
    a += PGSIZE;
    800010c4:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010c6:	bfd9                	j	8000109c <mappages+0x38>
    panic("mappages: va not aligned");
    800010c8:	00006517          	auipc	a0,0x6
    800010cc:	ff050513          	addi	a0,a0,-16 # 800070b8 <etext+0xb8>
    800010d0:	f20ff0ef          	jal	800007f0 <panic>
    panic("mappages: size not aligned");
    800010d4:	00006517          	auipc	a0,0x6
    800010d8:	00450513          	addi	a0,a0,4 # 800070d8 <etext+0xd8>
    800010dc:	f14ff0ef          	jal	800007f0 <panic>
    panic("mappages: size");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	01850513          	addi	a0,a0,24 # 800070f8 <etext+0xf8>
    800010e8:	f08ff0ef          	jal	800007f0 <panic>
      panic("mappages: remap");
    800010ec:	00006517          	auipc	a0,0x6
    800010f0:	01c50513          	addi	a0,a0,28 # 80007108 <etext+0x108>
    800010f4:	efcff0ef          	jal	800007f0 <panic>
      return -1;
    800010f8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010fa:	60a6                	ld	ra,72(sp)
    800010fc:	6406                	ld	s0,64(sp)
    800010fe:	74e2                	ld	s1,56(sp)
    80001100:	7942                	ld	s2,48(sp)
    80001102:	79a2                	ld	s3,40(sp)
    80001104:	7a02                	ld	s4,32(sp)
    80001106:	6ae2                	ld	s5,24(sp)
    80001108:	6b42                	ld	s6,16(sp)
    8000110a:	6ba2                	ld	s7,8(sp)
    8000110c:	6161                	addi	sp,sp,80
    8000110e:	8082                	ret
  return 0;
    80001110:	4501                	li	a0,0
    80001112:	b7e5                	j	800010fa <mappages+0x96>

0000000080001114 <kvmmap>:
{
    80001114:	1141                	addi	sp,sp,-16
    80001116:	e406                	sd	ra,8(sp)
    80001118:	e022                	sd	s0,0(sp)
    8000111a:	0800                	addi	s0,sp,16
    8000111c:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000111e:	86b2                	mv	a3,a2
    80001120:	863e                	mv	a2,a5
    80001122:	f43ff0ef          	jal	80001064 <mappages>
    80001126:	e509                	bnez	a0,80001130 <kvmmap+0x1c>
}
    80001128:	60a2                	ld	ra,8(sp)
    8000112a:	6402                	ld	s0,0(sp)
    8000112c:	0141                	addi	sp,sp,16
    8000112e:	8082                	ret
    panic("kvmmap");
    80001130:	00006517          	auipc	a0,0x6
    80001134:	fe850513          	addi	a0,a0,-24 # 80007118 <etext+0x118>
    80001138:	eb8ff0ef          	jal	800007f0 <panic>

000000008000113c <kvmmake>:
{
    8000113c:	1101                	addi	sp,sp,-32
    8000113e:	ec06                	sd	ra,24(sp)
    80001140:	e822                	sd	s0,16(sp)
    80001142:	e426                	sd	s1,8(sp)
    80001144:	e04a                	sd	s2,0(sp)
    80001146:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80001148:	983ff0ef          	jal	80000aca <kalloc>
    8000114c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000114e:	6605                	lui	a2,0x1
    80001150:	4581                	li	a1,0
    80001152:	bbfff0ef          	jal	80000d10 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001156:	4719                	li	a4,6
    80001158:	6685                	lui	a3,0x1
    8000115a:	10000637          	lui	a2,0x10000
    8000115e:	100005b7          	lui	a1,0x10000
    80001162:	8526                	mv	a0,s1
    80001164:	fb1ff0ef          	jal	80001114 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001168:	4719                	li	a4,6
    8000116a:	6685                	lui	a3,0x1
    8000116c:	10001637          	lui	a2,0x10001
    80001170:	100015b7          	lui	a1,0x10001
    80001174:	8526                	mv	a0,s1
    80001176:	f9fff0ef          	jal	80001114 <kvmmap>
kvmmap(kpgtbl, PCI_ECAM, PCI_ECAM, PCI_ECAM_SIZE,
    8000117a:	4719                	li	a4,6
    8000117c:	001006b7          	lui	a3,0x100
    80001180:	30000637          	lui	a2,0x30000
    80001184:	300005b7          	lui	a1,0x30000
    80001188:	8526                	mv	a0,s1
    8000118a:	f8bff0ef          	jal	80001114 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000118e:	4719                	li	a4,6
    80001190:	040006b7          	lui	a3,0x4000
    80001194:	0c000637          	lui	a2,0xc000
    80001198:	0c0005b7          	lui	a1,0xc000
    8000119c:	8526                	mv	a0,s1
    8000119e:	f77ff0ef          	jal	80001114 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800011a2:	00006917          	auipc	s2,0x6
    800011a6:	e5e90913          	addi	s2,s2,-418 # 80007000 <etext>
    800011aa:	4729                	li	a4,10
    800011ac:	80006697          	auipc	a3,0x80006
    800011b0:	e5468693          	addi	a3,a3,-428 # 7000 <_entry-0x7fff9000>
    800011b4:	4605                	li	a2,1
    800011b6:	067e                	slli	a2,a2,0x1f
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f59ff0ef          	jal	80001114 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    800011c0:	46c5                	li	a3,17
    800011c2:	06ee                	slli	a3,a3,0x1b
    800011c4:	4719                	li	a4,6
    800011c6:	412686b3          	sub	a3,a3,s2
    800011ca:	864a                	mv	a2,s2
    800011cc:	85ca                	mv	a1,s2
    800011ce:	8526                	mv	a0,s1
    800011d0:	f45ff0ef          	jal	80001114 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011d4:	4729                	li	a4,10
    800011d6:	6685                	lui	a3,0x1
    800011d8:	00005617          	auipc	a2,0x5
    800011dc:	e2860613          	addi	a2,a2,-472 # 80006000 <_trampoline>
    800011e0:	040005b7          	lui	a1,0x4000
    800011e4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011e6:	05b2                	slli	a1,a1,0xc
    800011e8:	8526                	mv	a0,s1
    800011ea:	f2bff0ef          	jal	80001114 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011ee:	8526                	mv	a0,s1
    800011f0:	60e000ef          	jal	800017fe <proc_mapstacks>
}
    800011f4:	8526                	mv	a0,s1
    800011f6:	60e2                	ld	ra,24(sp)
    800011f8:	6442                	ld	s0,16(sp)
    800011fa:	64a2                	ld	s1,8(sp)
    800011fc:	6902                	ld	s2,0(sp)
    800011fe:	6105                	addi	sp,sp,32
    80001200:	8082                	ret

0000000080001202 <kvminit>:
{
    80001202:	1141                	addi	sp,sp,-16
    80001204:	e406                	sd	ra,8(sp)
    80001206:	e022                	sd	s0,0(sp)
    80001208:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000120a:	f33ff0ef          	jal	8000113c <kvmmake>
    8000120e:	00006797          	auipc	a5,0x6
    80001212:	6ea7b923          	sd	a0,1778(a5) # 80007900 <kernel_pagetable>
}
    80001216:	60a2                	ld	ra,8(sp)
    80001218:	6402                	ld	s0,0(sp)
    8000121a:	0141                	addi	sp,sp,16
    8000121c:	8082                	ret

000000008000121e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000121e:	1101                	addi	sp,sp,-32
    80001220:	ec06                	sd	ra,24(sp)
    80001222:	e822                	sd	s0,16(sp)
    80001224:	e426                	sd	s1,8(sp)
    80001226:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001228:	8a3ff0ef          	jal	80000aca <kalloc>
    8000122c:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000122e:	c509                	beqz	a0,80001238 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001230:	6605                	lui	a2,0x1
    80001232:	4581                	li	a1,0
    80001234:	addff0ef          	jal	80000d10 <memset>
  return pagetable;
}
    80001238:	8526                	mv	a0,s1
    8000123a:	60e2                	ld	ra,24(sp)
    8000123c:	6442                	ld	s0,16(sp)
    8000123e:	64a2                	ld	s1,8(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001244:	7139                	addi	sp,sp,-64
    80001246:	fc06                	sd	ra,56(sp)
    80001248:	f822                	sd	s0,48(sp)
    8000124a:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    8000124c:	03459793          	slli	a5,a1,0x34
    80001250:	e38d                	bnez	a5,80001272 <uvmunmap+0x2e>
    80001252:	f04a                	sd	s2,32(sp)
    80001254:	ec4e                	sd	s3,24(sp)
    80001256:	e852                	sd	s4,16(sp)
    80001258:	e456                	sd	s5,8(sp)
    8000125a:	e05a                	sd	s6,0(sp)
    8000125c:	8a2a                	mv	s4,a0
    8000125e:	892e                	mv	s2,a1
    80001260:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    80001262:	0632                	slli	a2,a2,0xc
    80001264:	00b609b3          	add	s3,a2,a1
    80001268:	6b05                	lui	s6,0x1
    8000126a:	0535f963          	bgeu	a1,s3,800012bc <uvmunmap+0x78>
    8000126e:	f426                	sd	s1,40(sp)
    80001270:	a015                	j	80001294 <uvmunmap+0x50>
    80001272:	f426                	sd	s1,40(sp)
    80001274:	f04a                	sd	s2,32(sp)
    80001276:	ec4e                	sd	s3,24(sp)
    80001278:	e852                	sd	s4,16(sp)
    8000127a:	e456                	sd	s5,8(sp)
    8000127c:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000127e:	00006517          	auipc	a0,0x6
    80001282:	ea250513          	addi	a0,a0,-350 # 80007120 <etext+0x120>
    80001286:	d6aff0ef          	jal	800007f0 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    8000128a:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000128e:	995a                	add	s2,s2,s6
    80001290:	03397563          	bgeu	s2,s3,800012ba <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001294:	4601                	li	a2,0
    80001296:	85ca                	mv	a1,s2
    80001298:	8552                	mv	a0,s4
    8000129a:	cf3ff0ef          	jal	80000f8c <walk>
    8000129e:	84aa                	mv	s1,a0
    800012a0:	d57d                	beqz	a0,8000128e <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    800012a2:	611c                	ld	a5,0(a0)
    800012a4:	0017f713          	andi	a4,a5,1
    800012a8:	d37d                	beqz	a4,8000128e <uvmunmap+0x4a>
    if (do_free) {
    800012aa:	fe0a80e3          	beqz	s5,8000128a <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800012ae:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    800012b0:	00c79513          	slli	a0,a5,0xc
    800012b4:	f34ff0ef          	jal	800009e8 <kfree>
    800012b8:	bfc9                	j	8000128a <uvmunmap+0x46>
    800012ba:	74a2                	ld	s1,40(sp)
    800012bc:	7902                	ld	s2,32(sp)
    800012be:	69e2                	ld	s3,24(sp)
    800012c0:	6a42                	ld	s4,16(sp)
    800012c2:	6aa2                	ld	s5,8(sp)
    800012c4:	6b02                	ld	s6,0(sp)
  }
}
    800012c6:	70e2                	ld	ra,56(sp)
    800012c8:	7442                	ld	s0,48(sp)
    800012ca:	6121                	addi	sp,sp,64
    800012cc:	8082                	ret

00000000800012ce <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012ce:	1101                	addi	sp,sp,-32
    800012d0:	ec06                	sd	ra,24(sp)
    800012d2:	e822                	sd	s0,16(sp)
    800012d4:	e426                	sd	s1,8(sp)
    800012d6:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800012d8:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800012da:	00b67d63          	bgeu	a2,a1,800012f4 <uvmdealloc+0x26>
    800012de:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    800012e0:	6785                	lui	a5,0x1
    800012e2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012e4:	00f60733          	add	a4,a2,a5
    800012e8:	76fd                	lui	a3,0xfffff
    800012ea:	8f75                	and	a4,a4,a3
    800012ec:	97ae                	add	a5,a5,a1
    800012ee:	8ff5                	and	a5,a5,a3
    800012f0:	00f76863          	bltu	a4,a5,80001300 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012f4:	8526                	mv	a0,s1
    800012f6:	60e2                	ld	ra,24(sp)
    800012f8:	6442                	ld	s0,16(sp)
    800012fa:	64a2                	ld	s1,8(sp)
    800012fc:	6105                	addi	sp,sp,32
    800012fe:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001300:	8f99                	sub	a5,a5,a4
    80001302:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001304:	4685                	li	a3,1
    80001306:	0007861b          	sext.w	a2,a5
    8000130a:	85ba                	mv	a1,a4
    8000130c:	f39ff0ef          	jal	80001244 <uvmunmap>
    80001310:	b7d5                	j	800012f4 <uvmdealloc+0x26>

0000000080001312 <uvmalloc>:
  if (newsz < oldsz)
    80001312:	08b66f63          	bltu	a2,a1,800013b0 <uvmalloc+0x9e>
{
    80001316:	7139                	addi	sp,sp,-64
    80001318:	fc06                	sd	ra,56(sp)
    8000131a:	f822                	sd	s0,48(sp)
    8000131c:	ec4e                	sd	s3,24(sp)
    8000131e:	e852                	sd	s4,16(sp)
    80001320:	e456                	sd	s5,8(sp)
    80001322:	0080                	addi	s0,sp,64
    80001324:	8aaa                	mv	s5,a0
    80001326:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001328:	6785                	lui	a5,0x1
    8000132a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000132c:	95be                	add	a1,a1,a5
    8000132e:	77fd                	lui	a5,0xfffff
    80001330:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001334:	08c9f063          	bgeu	s3,a2,800013b4 <uvmalloc+0xa2>
    80001338:	f426                	sd	s1,40(sp)
    8000133a:	f04a                	sd	s2,32(sp)
    8000133c:	e05a                	sd	s6,0(sp)
    8000133e:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001340:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001344:	f86ff0ef          	jal	80000aca <kalloc>
    80001348:	84aa                	mv	s1,a0
    if (mem == 0) {
    8000134a:	c515                	beqz	a0,80001376 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000134c:	6605                	lui	a2,0x1
    8000134e:	4581                	li	a1,0
    80001350:	9c1ff0ef          	jal	80000d10 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001354:	875a                	mv	a4,s6
    80001356:	86a6                	mv	a3,s1
    80001358:	6605                	lui	a2,0x1
    8000135a:	85ca                	mv	a1,s2
    8000135c:	8556                	mv	a0,s5
    8000135e:	d07ff0ef          	jal	80001064 <mappages>
    80001362:	e915                	bnez	a0,80001396 <uvmalloc+0x84>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001364:	6785                	lui	a5,0x1
    80001366:	993e                	add	s2,s2,a5
    80001368:	fd496ee3          	bltu	s2,s4,80001344 <uvmalloc+0x32>
  return newsz;
    8000136c:	8552                	mv	a0,s4
    8000136e:	74a2                	ld	s1,40(sp)
    80001370:	7902                	ld	s2,32(sp)
    80001372:	6b02                	ld	s6,0(sp)
    80001374:	a811                	j	80001388 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    80001376:	864e                	mv	a2,s3
    80001378:	85ca                	mv	a1,s2
    8000137a:	8556                	mv	a0,s5
    8000137c:	f53ff0ef          	jal	800012ce <uvmdealloc>
      return 0;
    80001380:	4501                	li	a0,0
    80001382:	74a2                	ld	s1,40(sp)
    80001384:	7902                	ld	s2,32(sp)
    80001386:	6b02                	ld	s6,0(sp)
}
    80001388:	70e2                	ld	ra,56(sp)
    8000138a:	7442                	ld	s0,48(sp)
    8000138c:	69e2                	ld	s3,24(sp)
    8000138e:	6a42                	ld	s4,16(sp)
    80001390:	6aa2                	ld	s5,8(sp)
    80001392:	6121                	addi	sp,sp,64
    80001394:	8082                	ret
      kfree(mem);
    80001396:	8526                	mv	a0,s1
    80001398:	e50ff0ef          	jal	800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000139c:	864e                	mv	a2,s3
    8000139e:	85ca                	mv	a1,s2
    800013a0:	8556                	mv	a0,s5
    800013a2:	f2dff0ef          	jal	800012ce <uvmdealloc>
      return 0;
    800013a6:	4501                	li	a0,0
    800013a8:	74a2                	ld	s1,40(sp)
    800013aa:	7902                	ld	s2,32(sp)
    800013ac:	6b02                	ld	s6,0(sp)
    800013ae:	bfe9                	j	80001388 <uvmalloc+0x76>
    return oldsz;
    800013b0:	852e                	mv	a0,a1
}
    800013b2:	8082                	ret
  return newsz;
    800013b4:	8532                	mv	a0,a2
    800013b6:	bfc9                	j	80001388 <uvmalloc+0x76>

00000000800013b8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013b8:	7179                	addi	sp,sp,-48
    800013ba:	f406                	sd	ra,40(sp)
    800013bc:	f022                	sd	s0,32(sp)
    800013be:	ec26                	sd	s1,24(sp)
    800013c0:	e84a                	sd	s2,16(sp)
    800013c2:	e44e                	sd	s3,8(sp)
    800013c4:	e052                	sd	s4,0(sp)
    800013c6:	1800                	addi	s0,sp,48
    800013c8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    800013ca:	84aa                	mv	s1,a0
    800013cc:	6905                	lui	s2,0x1
    800013ce:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013d0:	4985                	li	s3,1
    800013d2:	a819                	j	800013e8 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800013d4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013d6:	00c79513          	slli	a0,a5,0xc
    800013da:	fdfff0ef          	jal	800013b8 <freewalk>
      pagetable[i] = 0;
    800013de:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++) {
    800013e2:	04a1                	addi	s1,s1,8
    800013e4:	01248f63          	beq	s1,s2,80001402 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800013e8:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013ea:	00f7f713          	andi	a4,a5,15
    800013ee:	ff3703e3          	beq	a4,s3,800013d4 <freewalk+0x1c>
    } else if (pte & PTE_V) {
    800013f2:	8b85                	andi	a5,a5,1
    800013f4:	d7fd                	beqz	a5,800013e2 <freewalk+0x2a>
      panic("freewalk: leaf");
    800013f6:	00006517          	auipc	a0,0x6
    800013fa:	d4250513          	addi	a0,a0,-702 # 80007138 <etext+0x138>
    800013fe:	bf2ff0ef          	jal	800007f0 <panic>
    }
  }
  kfree((void *)pagetable);
    80001402:	8552                	mv	a0,s4
    80001404:	de4ff0ef          	jal	800009e8 <kfree>
}
    80001408:	70a2                	ld	ra,40(sp)
    8000140a:	7402                	ld	s0,32(sp)
    8000140c:	64e2                	ld	s1,24(sp)
    8000140e:	6942                	ld	s2,16(sp)
    80001410:	69a2                	ld	s3,8(sp)
    80001412:	6a02                	ld	s4,0(sp)
    80001414:	6145                	addi	sp,sp,48
    80001416:	8082                	ret

0000000080001418 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001418:	1101                	addi	sp,sp,-32
    8000141a:	ec06                	sd	ra,24(sp)
    8000141c:	e822                	sd	s0,16(sp)
    8000141e:	e426                	sd	s1,8(sp)
    80001420:	1000                	addi	s0,sp,32
    80001422:	84aa                	mv	s1,a0
  if (sz > 0)
    80001424:	e989                	bnez	a1,80001436 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001426:	8526                	mv	a0,s1
    80001428:	f91ff0ef          	jal	800013b8 <freewalk>
}
    8000142c:	60e2                	ld	ra,24(sp)
    8000142e:	6442                	ld	s0,16(sp)
    80001430:	64a2                	ld	s1,8(sp)
    80001432:	6105                	addi	sp,sp,32
    80001434:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001436:	6785                	lui	a5,0x1
    80001438:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000143a:	95be                	add	a1,a1,a5
    8000143c:	4685                	li	a3,1
    8000143e:	00c5d613          	srli	a2,a1,0xc
    80001442:	4581                	li	a1,0
    80001444:	e01ff0ef          	jal	80001244 <uvmunmap>
    80001448:	bff9                	j	80001426 <uvmfree+0xe>

000000008000144a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    8000144a:	ce49                	beqz	a2,800014e4 <uvmcopy+0x9a>
{
    8000144c:	715d                	addi	sp,sp,-80
    8000144e:	e486                	sd	ra,72(sp)
    80001450:	e0a2                	sd	s0,64(sp)
    80001452:	fc26                	sd	s1,56(sp)
    80001454:	f84a                	sd	s2,48(sp)
    80001456:	f44e                	sd	s3,40(sp)
    80001458:	f052                	sd	s4,32(sp)
    8000145a:	ec56                	sd	s5,24(sp)
    8000145c:	e85a                	sd	s6,16(sp)
    8000145e:	e45e                	sd	s7,8(sp)
    80001460:	0880                	addi	s0,sp,80
    80001462:	8aaa                	mv	s5,a0
    80001464:	8b2e                	mv	s6,a1
    80001466:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001468:	4481                	li	s1,0
    8000146a:	a029                	j	80001474 <uvmcopy+0x2a>
    8000146c:	6785                	lui	a5,0x1
    8000146e:	94be                	add	s1,s1,a5
    80001470:	0544fe63          	bgeu	s1,s4,800014cc <uvmcopy+0x82>
    if ((pte = walk(old, i, 0)) == 0)
    80001474:	4601                	li	a2,0
    80001476:	85a6                	mv	a1,s1
    80001478:	8556                	mv	a0,s5
    8000147a:	b13ff0ef          	jal	80000f8c <walk>
    8000147e:	d57d                	beqz	a0,8000146c <uvmcopy+0x22>
      continue; // page table entry hasn't been allocated
    if ((*pte & PTE_V) == 0)
    80001480:	6118                	ld	a4,0(a0)
    80001482:	00177793          	andi	a5,a4,1
    80001486:	d3fd                	beqz	a5,8000146c <uvmcopy+0x22>
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001488:	00a75593          	srli	a1,a4,0xa
    8000148c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001490:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    80001494:	e36ff0ef          	jal	80000aca <kalloc>
    80001498:	89aa                	mv	s3,a0
    8000149a:	c105                	beqz	a0,800014ba <uvmcopy+0x70>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    8000149c:	6605                	lui	a2,0x1
    8000149e:	85de                	mv	a1,s7
    800014a0:	8cdff0ef          	jal	80000d6c <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    800014a4:	874a                	mv	a4,s2
    800014a6:	86ce                	mv	a3,s3
    800014a8:	6605                	lui	a2,0x1
    800014aa:	85a6                	mv	a1,s1
    800014ac:	855a                	mv	a0,s6
    800014ae:	bb7ff0ef          	jal	80001064 <mappages>
    800014b2:	dd4d                	beqz	a0,8000146c <uvmcopy+0x22>
      kfree(mem);
    800014b4:	854e                	mv	a0,s3
    800014b6:	d32ff0ef          	jal	800009e8 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014ba:	4685                	li	a3,1
    800014bc:	00c4d613          	srli	a2,s1,0xc
    800014c0:	4581                	li	a1,0
    800014c2:	855a                	mv	a0,s6
    800014c4:	d81ff0ef          	jal	80001244 <uvmunmap>
  return -1;
    800014c8:	557d                	li	a0,-1
    800014ca:	a011                	j	800014ce <uvmcopy+0x84>
  return 0;
    800014cc:	4501                	li	a0,0
}
    800014ce:	60a6                	ld	ra,72(sp)
    800014d0:	6406                	ld	s0,64(sp)
    800014d2:	74e2                	ld	s1,56(sp)
    800014d4:	7942                	ld	s2,48(sp)
    800014d6:	79a2                	ld	s3,40(sp)
    800014d8:	7a02                	ld	s4,32(sp)
    800014da:	6ae2                	ld	s5,24(sp)
    800014dc:	6b42                	ld	s6,16(sp)
    800014de:	6ba2                	ld	s7,8(sp)
    800014e0:	6161                	addi	sp,sp,80
    800014e2:	8082                	ret
  return 0;
    800014e4:	4501                	li	a0,0
}
    800014e6:	8082                	ret

00000000800014e8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014e8:	1141                	addi	sp,sp,-16
    800014ea:	e406                	sd	ra,8(sp)
    800014ec:	e022                	sd	s0,0(sp)
    800014ee:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800014f0:	4601                	li	a2,0
    800014f2:	a9bff0ef          	jal	80000f8c <walk>
  if (pte == 0)
    800014f6:	c901                	beqz	a0,80001506 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014f8:	611c                	ld	a5,0(a0)
    800014fa:	9bbd                	andi	a5,a5,-17
    800014fc:	e11c                	sd	a5,0(a0)
}
    800014fe:	60a2                	ld	ra,8(sp)
    80001500:	6402                	ld	s0,0(sp)
    80001502:	0141                	addi	sp,sp,16
    80001504:	8082                	ret
    panic("uvmclear");
    80001506:	00006517          	auipc	a0,0x6
    8000150a:	c4250513          	addi	a0,a0,-958 # 80007148 <etext+0x148>
    8000150e:	ae2ff0ef          	jal	800007f0 <panic>

0000000080001512 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001512:	1141                	addi	sp,sp,-16
    80001514:	e406                	sd	ra,8(sp)
    80001516:	e022                	sd	s0,0(sp)
    80001518:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    8000151a:	4601                	li	a2,0
    8000151c:	a71ff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    80001520:	c519                	beqz	a0,8000152e <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V) {
    80001522:	6108                	ld	a0,0(a0)
    80001524:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001526:	60a2                	ld	ra,8(sp)
    80001528:	6402                	ld	s0,0(sp)
    8000152a:	0141                	addi	sp,sp,16
    8000152c:	8082                	ret
    return 0;
    8000152e:	4501                	li	a0,0
    80001530:	bfdd                	j	80001526 <ismapped+0x14>

0000000080001532 <vmfault>:
{
    80001532:	7179                	addi	sp,sp,-48
    80001534:	f406                	sd	ra,40(sp)
    80001536:	f022                	sd	s0,32(sp)
    80001538:	e44e                	sd	s3,8(sp)
    8000153a:	1800                	addi	s0,sp,48
    return 0;
    8000153c:	4981                	li	s3,0
  if (va >= psz)
    8000153e:	00b66863          	bltu	a2,a1,8000154e <vmfault+0x1c>
}
    80001542:	854e                	mv	a0,s3
    80001544:	70a2                	ld	ra,40(sp)
    80001546:	7402                	ld	s0,32(sp)
    80001548:	69a2                	ld	s3,8(sp)
    8000154a:	6145                	addi	sp,sp,48
    8000154c:	8082                	ret
    8000154e:	ec26                	sd	s1,24(sp)
    80001550:	e84a                	sd	s2,16(sp)
    80001552:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001554:	77fd                	lui	a5,0xfffff
    80001556:	00f674b3          	and	s1,a2,a5
  if (ismapped(pagetable, va)) {
    8000155a:	85a6                	mv	a1,s1
    8000155c:	fb7ff0ef          	jal	80001512 <ismapped>
    return 0;
    80001560:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    80001562:	c501                	beqz	a0,8000156a <vmfault+0x38>
    80001564:	64e2                	ld	s1,24(sp)
    80001566:	6942                	ld	s2,16(sp)
    80001568:	bfe9                	j	80001542 <vmfault+0x10>
    8000156a:	e052                	sd	s4,0(sp)
  mem = (uint64)kalloc();
    8000156c:	d5eff0ef          	jal	80000aca <kalloc>
    80001570:	8a2a                	mv	s4,a0
  if (mem == 0)
    80001572:	c915                	beqz	a0,800015a6 <vmfault+0x74>
  mem = (uint64)kalloc();
    80001574:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    80001576:	6605                	lui	a2,0x1
    80001578:	4581                	li	a1,0
    8000157a:	f96ff0ef          	jal	80000d10 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    8000157e:	4759                	li	a4,22
    80001580:	86d2                	mv	a3,s4
    80001582:	6605                	lui	a2,0x1
    80001584:	85a6                	mv	a1,s1
    80001586:	854a                	mv	a0,s2
    80001588:	addff0ef          	jal	80001064 <mappages>
    8000158c:	e509                	bnez	a0,80001596 <vmfault+0x64>
    8000158e:	64e2                	ld	s1,24(sp)
    80001590:	6942                	ld	s2,16(sp)
    80001592:	6a02                	ld	s4,0(sp)
    80001594:	b77d                	j	80001542 <vmfault+0x10>
    kfree((void *)mem);
    80001596:	8552                	mv	a0,s4
    80001598:	c50ff0ef          	jal	800009e8 <kfree>
    return 0;
    8000159c:	4981                	li	s3,0
    8000159e:	64e2                	ld	s1,24(sp)
    800015a0:	6942                	ld	s2,16(sp)
    800015a2:	6a02                	ld	s4,0(sp)
    800015a4:	bf79                	j	80001542 <vmfault+0x10>
    800015a6:	64e2                	ld	s1,24(sp)
    800015a8:	6942                	ld	s2,16(sp)
    800015aa:	6a02                	ld	s4,0(sp)
    800015ac:	bf59                	j	80001542 <vmfault+0x10>

00000000800015ae <copyout>:
  while (len > 0) {
    800015ae:	c745                	beqz	a4,80001656 <copyout+0xa8>
{
    800015b0:	7159                	addi	sp,sp,-112
    800015b2:	f486                	sd	ra,104(sp)
    800015b4:	f0a2                	sd	s0,96(sp)
    800015b6:	eca6                	sd	s1,88(sp)
    800015b8:	e0d2                	sd	s4,64(sp)
    800015ba:	f85a                	sd	s6,48(sp)
    800015bc:	f45e                	sd	s7,40(sp)
    800015be:	f062                	sd	s8,32(sp)
    800015c0:	e46e                	sd	s11,8(sp)
    800015c2:	1880                	addi	s0,sp,112
    800015c4:	8c2a                	mv	s8,a0
    800015c6:	8dae                	mv	s11,a1
    800015c8:	8b32                	mv	s6,a2
    800015ca:	8bb6                	mv	s7,a3
    800015cc:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(dstva);
    800015ce:	74fd                	lui	s1,0xfffff
    800015d0:	8cf1                	and	s1,s1,a2
    if (va0 >= MAXVA)
    800015d2:	57fd                	li	a5,-1
    800015d4:	83e9                	srli	a5,a5,0x1a
    800015d6:	0897e263          	bltu	a5,s1,8000165a <copyout+0xac>
    800015da:	e8ca                	sd	s2,80(sp)
    800015dc:	e4ce                	sd	s3,72(sp)
    800015de:	fc56                	sd	s5,56(sp)
    800015e0:	ec66                	sd	s9,24(sp)
    800015e2:	e86a                	sd	s10,16(sp)
    800015e4:	6d05                	lui	s10,0x1
    800015e6:	8cbe                	mv	s9,a5
    800015e8:	a015                	j	8000160c <copyout+0x5e>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015ea:	409b0533          	sub	a0,s6,s1
    800015ee:	0009861b          	sext.w	a2,s3
    800015f2:	85de                	mv	a1,s7
    800015f4:	954a                	add	a0,a0,s2
    800015f6:	f76ff0ef          	jal	80000d6c <memmove>
    len -= n;
    800015fa:	413a0a33          	sub	s4,s4,s3
    src += n;
    800015fe:	9bce                	add	s7,s7,s3
  while (len > 0) {
    80001600:	040a0463          	beqz	s4,80001648 <copyout+0x9a>
    if (va0 >= MAXVA)
    80001604:	055ced63          	bltu	s9,s5,8000165e <copyout+0xb0>
    80001608:	84d6                	mv	s1,s5
    8000160a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000160c:	85a6                	mv	a1,s1
    8000160e:	8562                	mv	a0,s8
    80001610:	a17ff0ef          	jal	80001026 <walkaddr>
    80001614:	892a                	mv	s2,a0
    if (pa0 == 0) {
    80001616:	e909                	bnez	a0,80001628 <copyout+0x7a>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    80001618:	4681                	li	a3,0
    8000161a:	8626                	mv	a2,s1
    8000161c:	85ee                	mv	a1,s11
    8000161e:	8562                	mv	a0,s8
    80001620:	f13ff0ef          	jal	80001532 <vmfault>
    80001624:	892a                	mv	s2,a0
    80001626:	c139                	beqz	a0,8000166c <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    80001628:	4601                	li	a2,0
    8000162a:	85a6                	mv	a1,s1
    8000162c:	8562                	mv	a0,s8
    8000162e:	95fff0ef          	jal	80000f8c <walk>
    if ((*pte & PTE_W) == 0)
    80001632:	611c                	ld	a5,0(a0)
    80001634:	8b91                	andi	a5,a5,4
    80001636:	c3b1                	beqz	a5,8000167a <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    80001638:	01a48ab3          	add	s5,s1,s10
    8000163c:	416a89b3          	sub	s3,s5,s6
    if (n > len)
    80001640:	fb3a75e3          	bgeu	s4,s3,800015ea <copyout+0x3c>
    80001644:	89d2                	mv	s3,s4
    80001646:	b755                	j	800015ea <copyout+0x3c>
  return 0;
    80001648:	4501                	li	a0,0
    8000164a:	6946                	ld	s2,80(sp)
    8000164c:	69a6                	ld	s3,72(sp)
    8000164e:	7ae2                	ld	s5,56(sp)
    80001650:	6ce2                	ld	s9,24(sp)
    80001652:	6d42                	ld	s10,16(sp)
    80001654:	a80d                	j	80001686 <copyout+0xd8>
    80001656:	4501                	li	a0,0
}
    80001658:	8082                	ret
      return -1;
    8000165a:	557d                	li	a0,-1
    8000165c:	a02d                	j	80001686 <copyout+0xd8>
    8000165e:	557d                	li	a0,-1
    80001660:	6946                	ld	s2,80(sp)
    80001662:	69a6                	ld	s3,72(sp)
    80001664:	7ae2                	ld	s5,56(sp)
    80001666:	6ce2                	ld	s9,24(sp)
    80001668:	6d42                	ld	s10,16(sp)
    8000166a:	a831                	j	80001686 <copyout+0xd8>
        return -1;
    8000166c:	557d                	li	a0,-1
    8000166e:	6946                	ld	s2,80(sp)
    80001670:	69a6                	ld	s3,72(sp)
    80001672:	7ae2                	ld	s5,56(sp)
    80001674:	6ce2                	ld	s9,24(sp)
    80001676:	6d42                	ld	s10,16(sp)
    80001678:	a039                	j	80001686 <copyout+0xd8>
      return -1;
    8000167a:	557d                	li	a0,-1
    8000167c:	6946                	ld	s2,80(sp)
    8000167e:	69a6                	ld	s3,72(sp)
    80001680:	7ae2                	ld	s5,56(sp)
    80001682:	6ce2                	ld	s9,24(sp)
    80001684:	6d42                	ld	s10,16(sp)
}
    80001686:	70a6                	ld	ra,104(sp)
    80001688:	7406                	ld	s0,96(sp)
    8000168a:	64e6                	ld	s1,88(sp)
    8000168c:	6a06                	ld	s4,64(sp)
    8000168e:	7b42                	ld	s6,48(sp)
    80001690:	7ba2                	ld	s7,40(sp)
    80001692:	7c02                	ld	s8,32(sp)
    80001694:	6da2                	ld	s11,8(sp)
    80001696:	6165                	addi	sp,sp,112
    80001698:	8082                	ret

000000008000169a <copyin>:
  while (len > 0) {
    8000169a:	cb49                	beqz	a4,8000172c <copyin+0x92>
{
    8000169c:	711d                	addi	sp,sp,-96
    8000169e:	ec86                	sd	ra,88(sp)
    800016a0:	e8a2                	sd	s0,80(sp)
    800016a2:	e4a6                	sd	s1,72(sp)
    800016a4:	e0ca                	sd	s2,64(sp)
    800016a6:	fc4e                	sd	s3,56(sp)
    800016a8:	f852                	sd	s4,48(sp)
    800016aa:	f456                	sd	s5,40(sp)
    800016ac:	f05a                	sd	s6,32(sp)
    800016ae:	ec5e                	sd	s7,24(sp)
    800016b0:	e862                	sd	s8,16(sp)
    800016b2:	e466                	sd	s9,8(sp)
    800016b4:	1080                	addi	s0,sp,96
    800016b6:	8baa                	mv	s7,a0
    800016b8:	8cae                	mv	s9,a1
    800016ba:	8ab2                	mv	s5,a2
    800016bc:	8936                	mv	s2,a3
    800016be:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800016c0:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016c2:	6b05                	lui	s6,0x1
    800016c4:	a035                	j	800016f0 <copyin+0x56>
    800016c6:	412984b3          	sub	s1,s3,s2
    800016ca:	94da                	add	s1,s1,s6
    if (n > len)
    800016cc:	009a7363          	bgeu	s4,s1,800016d2 <copyin+0x38>
    800016d0:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016d2:	413905b3          	sub	a1,s2,s3
    800016d6:	0004861b          	sext.w	a2,s1
    800016da:	95aa                	add	a1,a1,a0
    800016dc:	8556                	mv	a0,s5
    800016de:	e8eff0ef          	jal	80000d6c <memmove>
    len -= n;
    800016e2:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800016e6:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800016e8:	01698933          	add	s2,s3,s6
  while (len > 0) {
    800016ec:	020a0263          	beqz	s4,80001710 <copyin+0x76>
    va0 = PGROUNDDOWN(srcva);
    800016f0:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800016f4:	85ce                	mv	a1,s3
    800016f6:	855e                	mv	a0,s7
    800016f8:	92fff0ef          	jal	80001026 <walkaddr>
    if (pa0 == 0) {
    800016fc:	f569                	bnez	a0,800016c6 <copyin+0x2c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016fe:	4685                	li	a3,1
    80001700:	864e                	mv	a2,s3
    80001702:	85e6                	mv	a1,s9
    80001704:	855e                	mv	a0,s7
    80001706:	e2dff0ef          	jal	80001532 <vmfault>
    8000170a:	fd55                	bnez	a0,800016c6 <copyin+0x2c>
        return -1;
    8000170c:	557d                	li	a0,-1
    8000170e:	a011                	j	80001712 <copyin+0x78>
  return 0;
    80001710:	4501                	li	a0,0
}
    80001712:	60e6                	ld	ra,88(sp)
    80001714:	6446                	ld	s0,80(sp)
    80001716:	64a6                	ld	s1,72(sp)
    80001718:	6906                	ld	s2,64(sp)
    8000171a:	79e2                	ld	s3,56(sp)
    8000171c:	7a42                	ld	s4,48(sp)
    8000171e:	7aa2                	ld	s5,40(sp)
    80001720:	7b02                	ld	s6,32(sp)
    80001722:	6be2                	ld	s7,24(sp)
    80001724:	6c42                	ld	s8,16(sp)
    80001726:	6ca2                	ld	s9,8(sp)
    80001728:	6125                	addi	sp,sp,96
    8000172a:	8082                	ret
  return 0;
    8000172c:	4501                	li	a0,0
}
    8000172e:	8082                	ret

0000000080001730 <copyinstr>:
  while (got_null == 0 && max > 0) {
    80001730:	c371                	beqz	a4,800017f4 <copyinstr+0xc4>
{
    80001732:	715d                	addi	sp,sp,-80
    80001734:	e486                	sd	ra,72(sp)
    80001736:	e0a2                	sd	s0,64(sp)
    80001738:	fc26                	sd	s1,56(sp)
    8000173a:	f84a                	sd	s2,48(sp)
    8000173c:	f44e                	sd	s3,40(sp)
    8000173e:	f052                	sd	s4,32(sp)
    80001740:	ec56                	sd	s5,24(sp)
    80001742:	e85a                	sd	s6,16(sp)
    80001744:	e45e                	sd	s7,8(sp)
    80001746:	e062                	sd	s8,0(sp)
    80001748:	0880                	addi	s0,sp,80
    8000174a:	8a2a                	mv	s4,a0
    8000174c:	8b2e                	mv	s6,a1
    8000174e:	8bb2                	mv	s7,a2
    80001750:	8c36                	mv	s8,a3
    80001752:	893a                	mv	s2,a4
    va0 = PGROUNDDOWN(srcva);
    80001754:	7afd                	lui	s5,0xfffff
    n = PGSIZE - (srcva - va0);
    80001756:	6985                	lui	s3,0x1
    80001758:	a0b1                	j	800017a4 <copyinstr+0x74>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000175a:	4685                	li	a3,1
    8000175c:	8626                	mv	a2,s1
    8000175e:	85da                	mv	a1,s6
    80001760:	8552                	mv	a0,s4
    80001762:	dd1ff0ef          	jal	80001532 <vmfault>
    80001766:	e531                	bnez	a0,800017b2 <copyinstr+0x82>
        return -1;
    80001768:	557d                	li	a0,-1
    8000176a:	a039                	j	80001778 <copyinstr+0x48>
        *dst = '\0';
    8000176c:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffde3c0>
    80001770:	4785                	li	a5,1
  if (got_null) {
    80001772:	37fd                	addiw	a5,a5,-1
    80001774:	0007851b          	sext.w	a0,a5
}
    80001778:	60a6                	ld	ra,72(sp)
    8000177a:	6406                	ld	s0,64(sp)
    8000177c:	74e2                	ld	s1,56(sp)
    8000177e:	7942                	ld	s2,48(sp)
    80001780:	79a2                	ld	s3,40(sp)
    80001782:	7a02                	ld	s4,32(sp)
    80001784:	6ae2                	ld	s5,24(sp)
    80001786:	6b42                	ld	s6,16(sp)
    80001788:	6ba2                	ld	s7,8(sp)
    8000178a:	6c02                	ld	s8,0(sp)
    8000178c:	6161                	addi	sp,sp,80
    8000178e:	8082                	ret
    80001790:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001794:	972a                	add	a4,a4,a0
      --max;
    80001796:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000179a:	01348c33          	add	s8,s1,s3
  while (got_null == 0 && max > 0) {
    8000179e:	04e58563          	beq	a1,a4,800017e8 <copyinstr+0xb8>
{
    800017a2:	8bbe                	mv	s7,a5
    va0 = PGROUNDDOWN(srcva);
    800017a4:	015c74b3          	and	s1,s8,s5
    pa0 = walkaddr(pagetable, va0);
    800017a8:	85a6                	mv	a1,s1
    800017aa:	8552                	mv	a0,s4
    800017ac:	87bff0ef          	jal	80001026 <walkaddr>
    if (pa0 == 0) {
    800017b0:	d54d                	beqz	a0,8000175a <copyinstr+0x2a>
    n = PGSIZE - (srcva - va0);
    800017b2:	41848633          	sub	a2,s1,s8
    800017b6:	964e                	add	a2,a2,s3
    if (n > max)
    800017b8:	00c97363          	bgeu	s2,a2,800017be <copyinstr+0x8e>
    800017bc:	864a                	mv	a2,s2
    char *p = (char *)(pa0 + (srcva - va0));
    800017be:	409c0c33          	sub	s8,s8,s1
    800017c2:	9c2a                	add	s8,s8,a0
    while (n > 0) {
    800017c4:	c605                	beqz	a2,800017ec <copyinstr+0xbc>
    800017c6:	87de                	mv	a5,s7
    800017c8:	855e                	mv	a0,s7
      if (*p == '\0') {
    800017ca:	417c0733          	sub	a4,s8,s7
    while (n > 0) {
    800017ce:	965e                	add	a2,a2,s7
    800017d0:	85be                	mv	a1,a5
      if (*p == '\0') {
    800017d2:	00f706b3          	add	a3,a4,a5
    800017d6:	0006c683          	lbu	a3,0(a3) # fffffffffffff000 <end+0xffffffff7ffde3c0>
    800017da:	dac9                	beqz	a3,8000176c <copyinstr+0x3c>
        *dst = *p;
    800017dc:	00d78023          	sb	a3,0(a5)
      dst++;
    800017e0:	0785                	addi	a5,a5,1
    while (n > 0) {
    800017e2:	fec797e3          	bne	a5,a2,800017d0 <copyinstr+0xa0>
    800017e6:	b76d                	j	80001790 <copyinstr+0x60>
    800017e8:	4781                	li	a5,0
    800017ea:	b761                	j	80001772 <copyinstr+0x42>
    srcva = va0 + PGSIZE;
    800017ec:	6c05                	lui	s8,0x1
    800017ee:	9c26                	add	s8,s8,s1
    800017f0:	87de                	mv	a5,s7
    800017f2:	bf45                	j	800017a2 <copyinstr+0x72>
  int got_null = 0;
    800017f4:	4781                	li	a5,0
  if (got_null) {
    800017f6:	37fd                	addiw	a5,a5,-1
    800017f8:	0007851b          	sext.w	a0,a5
}
    800017fc:	8082                	ret

00000000800017fe <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
    80001812:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001814:	0000e497          	auipc	s1,0xe
    80001818:	64c48493          	addi	s1,s1,1612 # 8000fe60 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000181c:	8b26                	mv	s6,s1
    8000181e:	04fa5937          	lui	s2,0x4fa5
    80001822:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001826:	0932                	slli	s2,s2,0xc
    80001828:	fa590913          	addi	s2,s2,-91
    8000182c:	0932                	slli	s2,s2,0xc
    8000182e:	fa590913          	addi	s2,s2,-91
    80001832:	0932                	slli	s2,s2,0xc
    80001834:	fa590913          	addi	s2,s2,-91
    80001838:	040009b7          	lui	s3,0x4000
    8000183c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000183e:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001840:	00014a97          	auipc	s5,0x14
    80001844:	020a8a93          	addi	s5,s5,32 # 80015860 <tickslock>
    char *pa = kalloc();
    80001848:	a82ff0ef          	jal	80000aca <kalloc>
    8000184c:	862a                	mv	a2,a0
    if (pa == 0)
    8000184e:	cd15                	beqz	a0,8000188a <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    80001850:	416485b3          	sub	a1,s1,s6
    80001854:	858d                	srai	a1,a1,0x3
    80001856:	032585b3          	mul	a1,a1,s2
    8000185a:	2585                	addiw	a1,a1,1
    8000185c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001860:	4719                	li	a4,6
    80001862:	6685                	lui	a3,0x1
    80001864:	40b985b3          	sub	a1,s3,a1
    80001868:	8552                	mv	a0,s4
    8000186a:	8abff0ef          	jal	80001114 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000186e:	16848493          	addi	s1,s1,360
    80001872:	fd549be3          	bne	s1,s5,80001848 <proc_mapstacks+0x4a>
  }
}
    80001876:	70e2                	ld	ra,56(sp)
    80001878:	7442                	ld	s0,48(sp)
    8000187a:	74a2                	ld	s1,40(sp)
    8000187c:	7902                	ld	s2,32(sp)
    8000187e:	69e2                	ld	s3,24(sp)
    80001880:	6a42                	ld	s4,16(sp)
    80001882:	6aa2                	ld	s5,8(sp)
    80001884:	6b02                	ld	s6,0(sp)
    80001886:	6121                	addi	sp,sp,64
    80001888:	8082                	ret
      panic("kalloc");
    8000188a:	00006517          	auipc	a0,0x6
    8000188e:	8ce50513          	addi	a0,a0,-1842 # 80007158 <etext+0x158>
    80001892:	f5ffe0ef          	jal	800007f0 <panic>

0000000080001896 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001896:	7139                	addi	sp,sp,-64
    80001898:	fc06                	sd	ra,56(sp)
    8000189a:	f822                	sd	s0,48(sp)
    8000189c:	f426                	sd	s1,40(sp)
    8000189e:	f04a                	sd	s2,32(sp)
    800018a0:	ec4e                	sd	s3,24(sp)
    800018a2:	e852                	sd	s4,16(sp)
    800018a4:	e456                	sd	s5,8(sp)
    800018a6:	e05a                	sd	s6,0(sp)
    800018a8:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018aa:	00006597          	auipc	a1,0x6
    800018ae:	8b658593          	addi	a1,a1,-1866 # 80007160 <etext+0x160>
    800018b2:	0000e517          	auipc	a0,0xe
    800018b6:	17e50513          	addi	a0,a0,382 # 8000fa30 <pid_lock>
    800018ba:	b1cff0ef          	jal	80000bd6 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018be:	00006597          	auipc	a1,0x6
    800018c2:	8aa58593          	addi	a1,a1,-1878 # 80007168 <etext+0x168>
    800018c6:	0000e517          	auipc	a0,0xe
    800018ca:	18250513          	addi	a0,a0,386 # 8000fa48 <wait_lock>
    800018ce:	b08ff0ef          	jal	80000bd6 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018d2:	0000e497          	auipc	s1,0xe
    800018d6:	58e48493          	addi	s1,s1,1422 # 8000fe60 <proc>
    initlock(&p->lock, "proc");
    800018da:	00006b17          	auipc	s6,0x6
    800018de:	89eb0b13          	addi	s6,s6,-1890 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018e2:	8aa6                	mv	s5,s1
    800018e4:	04fa5937          	lui	s2,0x4fa5
    800018e8:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800018ec:	0932                	slli	s2,s2,0xc
    800018ee:	fa590913          	addi	s2,s2,-91
    800018f2:	0932                	slli	s2,s2,0xc
    800018f4:	fa590913          	addi	s2,s2,-91
    800018f8:	0932                	slli	s2,s2,0xc
    800018fa:	fa590913          	addi	s2,s2,-91
    800018fe:	040009b7          	lui	s3,0x4000
    80001902:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001904:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001906:	00014a17          	auipc	s4,0x14
    8000190a:	f5aa0a13          	addi	s4,s4,-166 # 80015860 <tickslock>
    initlock(&p->lock, "proc");
    8000190e:	85da                	mv	a1,s6
    80001910:	8526                	mv	a0,s1
    80001912:	ac4ff0ef          	jal	80000bd6 <initlock>
    p->state = UNUSED;
    80001916:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000191a:	415487b3          	sub	a5,s1,s5
    8000191e:	878d                	srai	a5,a5,0x3
    80001920:	032787b3          	mul	a5,a5,s2
    80001924:	2785                	addiw	a5,a5,1
    80001926:	00d7979b          	slliw	a5,a5,0xd
    8000192a:	40f987b3          	sub	a5,s3,a5
    8000192e:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001930:	16848493          	addi	s1,s1,360
    80001934:	fd449de3          	bne	s1,s4,8000190e <procinit+0x78>
  }
}
    80001938:	70e2                	ld	ra,56(sp)
    8000193a:	7442                	ld	s0,48(sp)
    8000193c:	74a2                	ld	s1,40(sp)
    8000193e:	7902                	ld	s2,32(sp)
    80001940:	69e2                	ld	s3,24(sp)
    80001942:	6a42                	ld	s4,16(sp)
    80001944:	6aa2                	ld	s5,8(sp)
    80001946:	6b02                	ld	s6,0(sp)
    80001948:	6121                	addi	sp,sp,64
    8000194a:	8082                	ret

000000008000194c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000194c:	1141                	addi	sp,sp,-16
    8000194e:	e422                	sd	s0,8(sp)
    80001950:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001952:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001954:	2501                	sext.w	a0,a0
    80001956:	6422                	ld	s0,8(sp)
    80001958:	0141                	addi	sp,sp,16
    8000195a:	8082                	ret

000000008000195c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    8000195c:	1141                	addi	sp,sp,-16
    8000195e:	e422                	sd	s0,8(sp)
    80001960:	0800                	addi	s0,sp,16
    80001962:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001964:	2781                	sext.w	a5,a5
    80001966:	079e                	slli	a5,a5,0x7
  return c;
}
    80001968:	0000e517          	auipc	a0,0xe
    8000196c:	0f850513          	addi	a0,a0,248 # 8000fa60 <cpus>
    80001970:	953e                	add	a0,a0,a5
    80001972:	6422                	ld	s0,8(sp)
    80001974:	0141                	addi	sp,sp,16
    80001976:	8082                	ret

0000000080001978 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001978:	1101                	addi	sp,sp,-32
    8000197a:	ec06                	sd	ra,24(sp)
    8000197c:	e822                	sd	s0,16(sp)
    8000197e:	e426                	sd	s1,8(sp)
    80001980:	1000                	addi	s0,sp,32
  push_off();
    80001982:	a94ff0ef          	jal	80000c16 <push_off>
    80001986:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001988:	2781                	sext.w	a5,a5
    8000198a:	079e                	slli	a5,a5,0x7
    8000198c:	0000e717          	auipc	a4,0xe
    80001990:	0a470713          	addi	a4,a4,164 # 8000fa30 <pid_lock>
    80001994:	97ba                	add	a5,a5,a4
    80001996:	7b84                	ld	s1,48(a5)
  pop_off();
    80001998:	af4ff0ef          	jal	80000c8c <pop_off>
  return p;
}
    8000199c:	8526                	mv	a0,s1
    8000199e:	60e2                	ld	ra,24(sp)
    800019a0:	6442                	ld	s0,16(sp)
    800019a2:	64a2                	ld	s1,8(sp)
    800019a4:	6105                	addi	sp,sp,32
    800019a6:	8082                	ret

00000000800019a8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019a8:	7179                	addi	sp,sp,-48
    800019aa:	f406                	sd	ra,40(sp)
    800019ac:	f022                	sd	s0,32(sp)
    800019ae:	ec26                	sd	s1,24(sp)
    800019b0:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019b2:	fc7ff0ef          	jal	80001978 <myproc>
    800019b6:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019b8:	b20ff0ef          	jal	80000cd8 <release>

  if (first) {
    800019bc:	00006797          	auipc	a5,0x6
    800019c0:	f247a783          	lw	a5,-220(a5) # 800078e0 <first.1>
    800019c4:	cb9d                	beqz	a5,800019fa <forkret+0x52>
    first = 0;
    800019c6:	00006797          	auipc	a5,0x6
    800019ca:	f007ad23          	sw	zero,-230(a5) # 800078e0 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019ce:	4505                	li	a0,1
    800019d0:	435010ef          	jal	80003604 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019d4:	00005517          	auipc	a0,0x5
    800019d8:	7ac50513          	addi	a0,a0,1964 # 80007180 <etext+0x180>
    800019dc:	fca43823          	sd	a0,-48(s0)
    800019e0:	fc043c23          	sd	zero,-40(s0)
    800019e4:	fd040593          	addi	a1,s0,-48
    800019e8:	627020ef          	jal	8000480e <kexec>
    800019ec:	6cbc                	ld	a5,88(s1)
    800019ee:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019f0:	6cbc                	ld	a5,88(s1)
    800019f2:	7bb8                	ld	a4,112(a5)
    800019f4:	57fd                	li	a5,-1
    800019f6:	02f70d63          	beq	a4,a5,80001a30 <forkret+0x88>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019fa:	2f9000ef          	jal	800024f2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019fe:	68a8                	ld	a0,80(s1)
    80001a00:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a02:	04000737          	lui	a4,0x4000
    80001a06:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a08:	0732                	slli	a4,a4,0xc
    80001a0a:	00004797          	auipc	a5,0x4
    80001a0e:	69278793          	addi	a5,a5,1682 # 8000609c <userret>
    80001a12:	00004697          	auipc	a3,0x4
    80001a16:	5ee68693          	addi	a3,a3,1518 # 80006000 <_trampoline>
    80001a1a:	8f95                	sub	a5,a5,a3
    80001a1c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a1e:	577d                	li	a4,-1
    80001a20:	177e                	slli	a4,a4,0x3f
    80001a22:	8d59                	or	a0,a0,a4
    80001a24:	9782                	jalr	a5
}
    80001a26:	70a2                	ld	ra,40(sp)
    80001a28:	7402                	ld	s0,32(sp)
    80001a2a:	64e2                	ld	s1,24(sp)
    80001a2c:	6145                	addi	sp,sp,48
    80001a2e:	8082                	ret
      panic("exec");
    80001a30:	00005517          	auipc	a0,0x5
    80001a34:	75850513          	addi	a0,a0,1880 # 80007188 <etext+0x188>
    80001a38:	db9fe0ef          	jal	800007f0 <panic>

0000000080001a3c <allocpid>:
{
    80001a3c:	1101                	addi	sp,sp,-32
    80001a3e:	ec06                	sd	ra,24(sp)
    80001a40:	e822                	sd	s0,16(sp)
    80001a42:	e426                	sd	s1,8(sp)
    80001a44:	e04a                	sd	s2,0(sp)
    80001a46:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a48:	0000e917          	auipc	s2,0xe
    80001a4c:	fe890913          	addi	s2,s2,-24 # 8000fa30 <pid_lock>
    80001a50:	854a                	mv	a0,s2
    80001a52:	9faff0ef          	jal	80000c4c <acquire>
  pid = nextpid;
    80001a56:	00006797          	auipc	a5,0x6
    80001a5a:	e8e78793          	addi	a5,a5,-370 # 800078e4 <nextpid>
    80001a5e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a60:	0014871b          	addiw	a4,s1,1
    80001a64:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a66:	854a                	mv	a0,s2
    80001a68:	a70ff0ef          	jal	80000cd8 <release>
}
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	60e2                	ld	ra,24(sp)
    80001a70:	6442                	ld	s0,16(sp)
    80001a72:	64a2                	ld	s1,8(sp)
    80001a74:	6902                	ld	s2,0(sp)
    80001a76:	6105                	addi	sp,sp,32
    80001a78:	8082                	ret

0000000080001a7a <proc_pagetable>:
{
    80001a7a:	1101                	addi	sp,sp,-32
    80001a7c:	ec06                	sd	ra,24(sp)
    80001a7e:	e822                	sd	s0,16(sp)
    80001a80:	e426                	sd	s1,8(sp)
    80001a82:	e04a                	sd	s2,0(sp)
    80001a84:	1000                	addi	s0,sp,32
    80001a86:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a88:	f96ff0ef          	jal	8000121e <uvmcreate>
    80001a8c:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a8e:	cd05                	beqz	a0,80001ac6 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a90:	4729                	li	a4,10
    80001a92:	00004697          	auipc	a3,0x4
    80001a96:	56e68693          	addi	a3,a3,1390 # 80006000 <_trampoline>
    80001a9a:	6605                	lui	a2,0x1
    80001a9c:	040005b7          	lui	a1,0x4000
    80001aa0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa2:	05b2                	slli	a1,a1,0xc
    80001aa4:	dc0ff0ef          	jal	80001064 <mappages>
    80001aa8:	02054663          	bltz	a0,80001ad4 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001aac:	4719                	li	a4,6
    80001aae:	05893683          	ld	a3,88(s2)
    80001ab2:	6605                	lui	a2,0x1
    80001ab4:	020005b7          	lui	a1,0x2000
    80001ab8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aba:	05b6                	slli	a1,a1,0xd
    80001abc:	8526                	mv	a0,s1
    80001abe:	da6ff0ef          	jal	80001064 <mappages>
    80001ac2:	00054f63          	bltz	a0,80001ae0 <proc_pagetable+0x66>
}
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	60e2                	ld	ra,24(sp)
    80001aca:	6442                	ld	s0,16(sp)
    80001acc:	64a2                	ld	s1,8(sp)
    80001ace:	6902                	ld	s2,0(sp)
    80001ad0:	6105                	addi	sp,sp,32
    80001ad2:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad4:	4581                	li	a1,0
    80001ad6:	8526                	mv	a0,s1
    80001ad8:	941ff0ef          	jal	80001418 <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	b7e5                	j	80001ac6 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae0:	4681                	li	a3,0
    80001ae2:	4605                	li	a2,1
    80001ae4:	040005b7          	lui	a1,0x4000
    80001ae8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aea:	05b2                	slli	a1,a1,0xc
    80001aec:	8526                	mv	a0,s1
    80001aee:	f56ff0ef          	jal	80001244 <uvmunmap>
    uvmfree(pagetable, 0);
    80001af2:	4581                	li	a1,0
    80001af4:	8526                	mv	a0,s1
    80001af6:	923ff0ef          	jal	80001418 <uvmfree>
    return 0;
    80001afa:	4481                	li	s1,0
    80001afc:	b7e9                	j	80001ac6 <proc_pagetable+0x4c>

0000000080001afe <proc_freepagetable>:
{
    80001afe:	1101                	addi	sp,sp,-32
    80001b00:	ec06                	sd	ra,24(sp)
    80001b02:	e822                	sd	s0,16(sp)
    80001b04:	e426                	sd	s1,8(sp)
    80001b06:	e04a                	sd	s2,0(sp)
    80001b08:	1000                	addi	s0,sp,32
    80001b0a:	84aa                	mv	s1,a0
    80001b0c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b0e:	4681                	li	a3,0
    80001b10:	4605                	li	a2,1
    80001b12:	040005b7          	lui	a1,0x4000
    80001b16:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b18:	05b2                	slli	a1,a1,0xc
    80001b1a:	f2aff0ef          	jal	80001244 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b1e:	4681                	li	a3,0
    80001b20:	4605                	li	a2,1
    80001b22:	020005b7          	lui	a1,0x2000
    80001b26:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b28:	05b6                	slli	a1,a1,0xd
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	f18ff0ef          	jal	80001244 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b30:	85ca                	mv	a1,s2
    80001b32:	8526                	mv	a0,s1
    80001b34:	8e5ff0ef          	jal	80001418 <uvmfree>
}
    80001b38:	60e2                	ld	ra,24(sp)
    80001b3a:	6442                	ld	s0,16(sp)
    80001b3c:	64a2                	ld	s1,8(sp)
    80001b3e:	6902                	ld	s2,0(sp)
    80001b40:	6105                	addi	sp,sp,32
    80001b42:	8082                	ret

0000000080001b44 <freeproc>:
{
    80001b44:	1101                	addi	sp,sp,-32
    80001b46:	ec06                	sd	ra,24(sp)
    80001b48:	e822                	sd	s0,16(sp)
    80001b4a:	e426                	sd	s1,8(sp)
    80001b4c:	1000                	addi	s0,sp,32
    80001b4e:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b50:	6d28                	ld	a0,88(a0)
    80001b52:	c119                	beqz	a0,80001b58 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b54:	e95fe0ef          	jal	800009e8 <kfree>
  p->trapframe = 0;
    80001b58:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b5c:	68a8                	ld	a0,80(s1)
    80001b5e:	c501                	beqz	a0,80001b66 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b60:	64ac                	ld	a1,72(s1)
    80001b62:	f9dff0ef          	jal	80001afe <proc_freepagetable>
  p->pagetable = 0;
    80001b66:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b6a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b6e:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001b72:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b76:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b7a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b7e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b82:	0004ac23          	sw	zero,24(s1)
}
    80001b86:	60e2                	ld	ra,24(sp)
    80001b88:	6442                	ld	s0,16(sp)
    80001b8a:	64a2                	ld	s1,8(sp)
    80001b8c:	6105                	addi	sp,sp,32
    80001b8e:	8082                	ret

0000000080001b90 <allocproc>:
{
    80001b90:	1101                	addi	sp,sp,-32
    80001b92:	ec06                	sd	ra,24(sp)
    80001b94:	e822                	sd	s0,16(sp)
    80001b96:	e426                	sd	s1,8(sp)
    80001b98:	e04a                	sd	s2,0(sp)
    80001b9a:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b9c:	0000e497          	auipc	s1,0xe
    80001ba0:	2c448493          	addi	s1,s1,708 # 8000fe60 <proc>
    80001ba4:	00014917          	auipc	s2,0x14
    80001ba8:	cbc90913          	addi	s2,s2,-836 # 80015860 <tickslock>
    acquire(&p->lock);
    80001bac:	8526                	mv	a0,s1
    80001bae:	89eff0ef          	jal	80000c4c <acquire>
    if (p->state == UNUSED) {
    80001bb2:	4c9c                	lw	a5,24(s1)
    80001bb4:	cb91                	beqz	a5,80001bc8 <allocproc+0x38>
      release(&p->lock);
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	920ff0ef          	jal	80000cd8 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bbc:	16848493          	addi	s1,s1,360
    80001bc0:	ff2496e3          	bne	s1,s2,80001bac <allocproc+0x1c>
  return 0;
    80001bc4:	4481                	li	s1,0
    80001bc6:	a089                	j	80001c08 <allocproc+0x78>
  p->pid = allocpid();
    80001bc8:	e75ff0ef          	jal	80001a3c <allocpid>
    80001bcc:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bce:	4785                	li	a5,1
    80001bd0:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bd2:	ef9fe0ef          	jal	80000aca <kalloc>
    80001bd6:	892a                	mv	s2,a0
    80001bd8:	eca8                	sd	a0,88(s1)
    80001bda:	cd15                	beqz	a0,80001c16 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	e9dff0ef          	jal	80001a7a <proc_pagetable>
    80001be2:	892a                	mv	s2,a0
    80001be4:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001be6:	c121                	beqz	a0,80001c26 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001be8:	07000613          	li	a2,112
    80001bec:	4581                	li	a1,0
    80001bee:	06048513          	addi	a0,s1,96
    80001bf2:	91eff0ef          	jal	80000d10 <memset>
  p->context.ra = (uint64)forkret;
    80001bf6:	00000797          	auipc	a5,0x0
    80001bfa:	db278793          	addi	a5,a5,-590 # 800019a8 <forkret>
    80001bfe:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c00:	60bc                	ld	a5,64(s1)
    80001c02:	6705                	lui	a4,0x1
    80001c04:	97ba                	add	a5,a5,a4
    80001c06:	f4bc                	sd	a5,104(s1)
}
    80001c08:	8526                	mv	a0,s1
    80001c0a:	60e2                	ld	ra,24(sp)
    80001c0c:	6442                	ld	s0,16(sp)
    80001c0e:	64a2                	ld	s1,8(sp)
    80001c10:	6902                	ld	s2,0(sp)
    80001c12:	6105                	addi	sp,sp,32
    80001c14:	8082                	ret
    freeproc(p);
    80001c16:	8526                	mv	a0,s1
    80001c18:	f2dff0ef          	jal	80001b44 <freeproc>
    release(&p->lock);
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	8baff0ef          	jal	80000cd8 <release>
    return 0;
    80001c22:	84ca                	mv	s1,s2
    80001c24:	b7d5                	j	80001c08 <allocproc+0x78>
    freeproc(p);
    80001c26:	8526                	mv	a0,s1
    80001c28:	f1dff0ef          	jal	80001b44 <freeproc>
    release(&p->lock);
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	8aaff0ef          	jal	80000cd8 <release>
    return 0;
    80001c32:	84ca                	mv	s1,s2
    80001c34:	bfd1                	j	80001c08 <allocproc+0x78>

0000000080001c36 <userinit>:
{
    80001c36:	1101                	addi	sp,sp,-32
    80001c38:	ec06                	sd	ra,24(sp)
    80001c3a:	e822                	sd	s0,16(sp)
    80001c3c:	e426                	sd	s1,8(sp)
    80001c3e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c40:	f51ff0ef          	jal	80001b90 <allocproc>
    80001c44:	84aa                	mv	s1,a0
  initproc = p;
    80001c46:	00006797          	auipc	a5,0x6
    80001c4a:	cca7b123          	sd	a0,-830(a5) # 80007908 <initproc>
  p->cwd = namei("/");
    80001c4e:	00005517          	auipc	a0,0x5
    80001c52:	54250513          	addi	a0,a0,1346 # 80007190 <etext+0x190>
    80001c56:	6e9010ef          	jal	80003b3e <namei>
    80001c5a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c5e:	478d                	li	a5,3
    80001c60:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c62:	8526                	mv	a0,s1
    80001c64:	874ff0ef          	jal	80000cd8 <release>
}
    80001c68:	60e2                	ld	ra,24(sp)
    80001c6a:	6442                	ld	s0,16(sp)
    80001c6c:	64a2                	ld	s1,8(sp)
    80001c6e:	6105                	addi	sp,sp,32
    80001c70:	8082                	ret

0000000080001c72 <growproc>:
{
    80001c72:	1101                	addi	sp,sp,-32
    80001c74:	ec06                	sd	ra,24(sp)
    80001c76:	e822                	sd	s0,16(sp)
    80001c78:	e426                	sd	s1,8(sp)
    80001c7a:	e04a                	sd	s2,0(sp)
    80001c7c:	1000                	addi	s0,sp,32
    80001c7e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c80:	cf9ff0ef          	jal	80001978 <myproc>
    80001c84:	892a                	mv	s2,a0
  sz = p->sz;
    80001c86:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c88:	02905963          	blez	s1,80001cba <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c8c:	00b48633          	add	a2,s1,a1
    80001c90:	020007b7          	lui	a5,0x2000
    80001c94:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c96:	07b6                	slli	a5,a5,0xd
    80001c98:	02c7ea63          	bltu	a5,a2,80001ccc <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c9c:	4691                	li	a3,4
    80001c9e:	6928                	ld	a0,80(a0)
    80001ca0:	e72ff0ef          	jal	80001312 <uvmalloc>
    80001ca4:	85aa                	mv	a1,a0
    80001ca6:	c50d                	beqz	a0,80001cd0 <growproc+0x5e>
  p->sz = sz;
    80001ca8:	04b93423          	sd	a1,72(s2)
  return 0;
    80001cac:	4501                	li	a0,0
}
    80001cae:	60e2                	ld	ra,24(sp)
    80001cb0:	6442                	ld	s0,16(sp)
    80001cb2:	64a2                	ld	s1,8(sp)
    80001cb4:	6902                	ld	s2,0(sp)
    80001cb6:	6105                	addi	sp,sp,32
    80001cb8:	8082                	ret
  } else if (n < 0) {
    80001cba:	fe04d7e3          	bgez	s1,80001ca8 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cbe:	00b48633          	add	a2,s1,a1
    80001cc2:	6928                	ld	a0,80(a0)
    80001cc4:	e0aff0ef          	jal	800012ce <uvmdealloc>
    80001cc8:	85aa                	mv	a1,a0
    80001cca:	bff9                	j	80001ca8 <growproc+0x36>
      return -1;
    80001ccc:	557d                	li	a0,-1
    80001cce:	b7c5                	j	80001cae <growproc+0x3c>
      return -1;
    80001cd0:	557d                	li	a0,-1
    80001cd2:	bff1                	j	80001cae <growproc+0x3c>

0000000080001cd4 <kfork>:
{
    80001cd4:	7139                	addi	sp,sp,-64
    80001cd6:	fc06                	sd	ra,56(sp)
    80001cd8:	f822                	sd	s0,48(sp)
    80001cda:	f04a                	sd	s2,32(sp)
    80001cdc:	e456                	sd	s5,8(sp)
    80001cde:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ce0:	c99ff0ef          	jal	80001978 <myproc>
    80001ce4:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001ce6:	eabff0ef          	jal	80001b90 <allocproc>
    80001cea:	0e050a63          	beqz	a0,80001dde <kfork+0x10a>
    80001cee:	e852                	sd	s4,16(sp)
    80001cf0:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cf2:	048ab603          	ld	a2,72(s5)
    80001cf6:	692c                	ld	a1,80(a0)
    80001cf8:	050ab503          	ld	a0,80(s5)
    80001cfc:	f4eff0ef          	jal	8000144a <uvmcopy>
    80001d00:	04054a63          	bltz	a0,80001d54 <kfork+0x80>
    80001d04:	f426                	sd	s1,40(sp)
    80001d06:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d08:	048ab783          	ld	a5,72(s5)
    80001d0c:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d10:	058ab683          	ld	a3,88(s5)
    80001d14:	87b6                	mv	a5,a3
    80001d16:	058a3703          	ld	a4,88(s4)
    80001d1a:	12068693          	addi	a3,a3,288
    80001d1e:	0007b803          	ld	a6,0(a5)
    80001d22:	6788                	ld	a0,8(a5)
    80001d24:	6b8c                	ld	a1,16(a5)
    80001d26:	6f90                	ld	a2,24(a5)
    80001d28:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001d2c:	e708                	sd	a0,8(a4)
    80001d2e:	eb0c                	sd	a1,16(a4)
    80001d30:	ef10                	sd	a2,24(a4)
    80001d32:	02078793          	addi	a5,a5,32
    80001d36:	02070713          	addi	a4,a4,32
    80001d3a:	fed792e3          	bne	a5,a3,80001d1e <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d3e:	058a3783          	ld	a5,88(s4)
    80001d42:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d46:	0d0a8493          	addi	s1,s5,208
    80001d4a:	0d0a0913          	addi	s2,s4,208
    80001d4e:	150a8993          	addi	s3,s5,336
    80001d52:	a831                	j	80001d6e <kfork+0x9a>
    freeproc(np);
    80001d54:	8552                	mv	a0,s4
    80001d56:	defff0ef          	jal	80001b44 <freeproc>
    release(&np->lock);
    80001d5a:	8552                	mv	a0,s4
    80001d5c:	f7dfe0ef          	jal	80000cd8 <release>
    return -1;
    80001d60:	597d                	li	s2,-1
    80001d62:	6a42                	ld	s4,16(sp)
    80001d64:	a0b5                	j	80001dd0 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d66:	04a1                	addi	s1,s1,8
    80001d68:	0921                	addi	s2,s2,8
    80001d6a:	01348963          	beq	s1,s3,80001d7c <kfork+0xa8>
    if (p->ofile[i])
    80001d6e:	6088                	ld	a0,0(s1)
    80001d70:	d97d                	beqz	a0,80001d66 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d72:	406020ef          	jal	80004178 <filedup>
    80001d76:	00a93023          	sd	a0,0(s2)
    80001d7a:	b7f5                	j	80001d66 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d7c:	150ab503          	ld	a0,336(s5)
    80001d80:	512010ef          	jal	80003292 <idup>
    80001d84:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d88:	4641                	li	a2,16
    80001d8a:	158a8593          	addi	a1,s5,344
    80001d8e:	158a0513          	addi	a0,s4,344
    80001d92:	8bcff0ef          	jal	80000e4e <safestrcpy>
  pid = np->pid;
    80001d96:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d9a:	8552                	mv	a0,s4
    80001d9c:	f3dfe0ef          	jal	80000cd8 <release>
  acquire(&wait_lock);
    80001da0:	0000e497          	auipc	s1,0xe
    80001da4:	ca848493          	addi	s1,s1,-856 # 8000fa48 <wait_lock>
    80001da8:	8526                	mv	a0,s1
    80001daa:	ea3fe0ef          	jal	80000c4c <acquire>
  np->parent = p;
    80001dae:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001db2:	8526                	mv	a0,s1
    80001db4:	f25fe0ef          	jal	80000cd8 <release>
  acquire(&np->lock);
    80001db8:	8552                	mv	a0,s4
    80001dba:	e93fe0ef          	jal	80000c4c <acquire>
  np->state = RUNNABLE;
    80001dbe:	478d                	li	a5,3
    80001dc0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dc4:	8552                	mv	a0,s4
    80001dc6:	f13fe0ef          	jal	80000cd8 <release>
  return pid;
    80001dca:	74a2                	ld	s1,40(sp)
    80001dcc:	69e2                	ld	s3,24(sp)
    80001dce:	6a42                	ld	s4,16(sp)
}
    80001dd0:	854a                	mv	a0,s2
    80001dd2:	70e2                	ld	ra,56(sp)
    80001dd4:	7442                	ld	s0,48(sp)
    80001dd6:	7902                	ld	s2,32(sp)
    80001dd8:	6aa2                	ld	s5,8(sp)
    80001dda:	6121                	addi	sp,sp,64
    80001ddc:	8082                	ret
    return -1;
    80001dde:	597d                	li	s2,-1
    80001de0:	bfc5                	j	80001dd0 <kfork+0xfc>

0000000080001de2 <scheduler>:
{
    80001de2:	711d                	addi	sp,sp,-96
    80001de4:	ec86                	sd	ra,88(sp)
    80001de6:	e8a2                	sd	s0,80(sp)
    80001de8:	e4a6                	sd	s1,72(sp)
    80001dea:	e0ca                	sd	s2,64(sp)
    80001dec:	fc4e                	sd	s3,56(sp)
    80001dee:	f852                	sd	s4,48(sp)
    80001df0:	f456                	sd	s5,40(sp)
    80001df2:	f05a                	sd	s6,32(sp)
    80001df4:	ec5e                	sd	s7,24(sp)
    80001df6:	e862                	sd	s8,16(sp)
    80001df8:	e466                	sd	s9,8(sp)
    80001dfa:	1080                	addi	s0,sp,96
    80001dfc:	8792                	mv	a5,tp
  int id = r_tp();
    80001dfe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e00:	00779a93          	slli	s5,a5,0x7
    80001e04:	0000e717          	auipc	a4,0xe
    80001e08:	c2c70713          	addi	a4,a4,-980 # 8000fa30 <pid_lock>
    80001e0c:	9756                	add	a4,a4,s5
    80001e0e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e12:	0000e717          	auipc	a4,0xe
    80001e16:	c5670713          	addi	a4,a4,-938 # 8000fa68 <cpus+0x8>
    80001e1a:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001e1c:	4c11                	li	s8,4
        c->proc = p;
    80001e1e:	0000eb17          	auipc	s6,0xe
    80001e22:	c12b0b13          	addi	s6,s6,-1006 # 8000fa30 <pid_lock>
    80001e26:	079e                	slli	a5,a5,0x7
    80001e28:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001e2c:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e2e:	00014997          	auipc	s3,0x14
    80001e32:	a3298993          	addi	s3,s3,-1486 # 80015860 <tickslock>
    80001e36:	a0a9                	j	80001e80 <scheduler+0x9e>
      release(&p->lock);
    80001e38:	8526                	mv	a0,s1
    80001e3a:	e9ffe0ef          	jal	80000cd8 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e3e:	16848493          	addi	s1,s1,360
    80001e42:	03348b63          	beq	s1,s3,80001e78 <scheduler+0x96>
      acquire(&p->lock);
    80001e46:	8526                	mv	a0,s1
    80001e48:	e05fe0ef          	jal	80000c4c <acquire>
      if (p->state == RUNNABLE) {
    80001e4c:	4c9c                	lw	a5,24(s1)
    80001e4e:	ff2795e3          	bne	a5,s2,80001e38 <scheduler+0x56>
        p->state = RUNNING;
    80001e52:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e56:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e5a:	06048593          	addi	a1,s1,96
    80001e5e:	8556                	mv	a0,s5
    80001e60:	5ec000ef          	jal	8000244c <swtch>
    80001e64:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001e66:	2781                	sext.w	a5,a5
    80001e68:	079e                	slli	a5,a5,0x7
    80001e6a:	97da                	add	a5,a5,s6
    80001e6c:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001e70:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e74:	8cde                	mv	s9,s7
    80001e76:	b7c9                	j	80001e38 <scheduler+0x56>
    if (found == 0) {
    80001e78:	000c9463          	bnez	s9,80001e80 <scheduler+0x9e>
      asm volatile("wfi");
    80001e7c:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e80:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e84:	10017073          	csrci	sstatus,2
    int found = 0;
    80001e88:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e8a:	0000e497          	auipc	s1,0xe
    80001e8e:	fd648493          	addi	s1,s1,-42 # 8000fe60 <proc>
      if (p->state == RUNNABLE) {
    80001e92:	490d                	li	s2,3
    80001e94:	bf4d                	j	80001e46 <scheduler+0x64>

0000000080001e96 <sched>:
{
    80001e96:	7179                	addi	sp,sp,-48
    80001e98:	f406                	sd	ra,40(sp)
    80001e9a:	f022                	sd	s0,32(sp)
    80001e9c:	ec26                	sd	s1,24(sp)
    80001e9e:	e84a                	sd	s2,16(sp)
    80001ea0:	e44e                	sd	s3,8(sp)
    80001ea2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ea4:	ad5ff0ef          	jal	80001978 <myproc>
    80001ea8:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001eaa:	d43fe0ef          	jal	80000bec <holding>
    80001eae:	c92d                	beqz	a0,80001f20 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001eb0:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001eb2:	2781                	sext.w	a5,a5
    80001eb4:	079e                	slli	a5,a5,0x7
    80001eb6:	0000e717          	auipc	a4,0xe
    80001eba:	b7a70713          	addi	a4,a4,-1158 # 8000fa30 <pid_lock>
    80001ebe:	97ba                	add	a5,a5,a4
    80001ec0:	0a87a703          	lw	a4,168(a5)
    80001ec4:	4785                	li	a5,1
    80001ec6:	06f71363          	bne	a4,a5,80001f2c <sched+0x96>
  if (p->state == RUNNING)
    80001eca:	4c98                	lw	a4,24(s1)
    80001ecc:	4791                	li	a5,4
    80001ece:	06f70563          	beq	a4,a5,80001f38 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001ed2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ed6:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001ed8:	e7b5                	bnez	a5,80001f44 <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001eda:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001edc:	0000e917          	auipc	s2,0xe
    80001ee0:	b5490913          	addi	s2,s2,-1196 # 8000fa30 <pid_lock>
    80001ee4:	2781                	sext.w	a5,a5
    80001ee6:	079e                	slli	a5,a5,0x7
    80001ee8:	97ca                	add	a5,a5,s2
    80001eea:	0ac7a983          	lw	s3,172(a5)
    80001eee:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ef0:	2781                	sext.w	a5,a5
    80001ef2:	079e                	slli	a5,a5,0x7
    80001ef4:	0000e597          	auipc	a1,0xe
    80001ef8:	b7458593          	addi	a1,a1,-1164 # 8000fa68 <cpus+0x8>
    80001efc:	95be                	add	a1,a1,a5
    80001efe:	06048513          	addi	a0,s1,96
    80001f02:	54a000ef          	jal	8000244c <swtch>
    80001f06:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f08:	2781                	sext.w	a5,a5
    80001f0a:	079e                	slli	a5,a5,0x7
    80001f0c:	993e                	add	s2,s2,a5
    80001f0e:	0b392623          	sw	s3,172(s2)
}
    80001f12:	70a2                	ld	ra,40(sp)
    80001f14:	7402                	ld	s0,32(sp)
    80001f16:	64e2                	ld	s1,24(sp)
    80001f18:	6942                	ld	s2,16(sp)
    80001f1a:	69a2                	ld	s3,8(sp)
    80001f1c:	6145                	addi	sp,sp,48
    80001f1e:	8082                	ret
    panic("sched p->lock");
    80001f20:	00005517          	auipc	a0,0x5
    80001f24:	27850513          	addi	a0,a0,632 # 80007198 <etext+0x198>
    80001f28:	8c9fe0ef          	jal	800007f0 <panic>
    panic("sched locks");
    80001f2c:	00005517          	auipc	a0,0x5
    80001f30:	27c50513          	addi	a0,a0,636 # 800071a8 <etext+0x1a8>
    80001f34:	8bdfe0ef          	jal	800007f0 <panic>
    panic("sched RUNNING");
    80001f38:	00005517          	auipc	a0,0x5
    80001f3c:	28050513          	addi	a0,a0,640 # 800071b8 <etext+0x1b8>
    80001f40:	8b1fe0ef          	jal	800007f0 <panic>
    panic("sched interruptible");
    80001f44:	00005517          	auipc	a0,0x5
    80001f48:	28450513          	addi	a0,a0,644 # 800071c8 <etext+0x1c8>
    80001f4c:	8a5fe0ef          	jal	800007f0 <panic>

0000000080001f50 <yield>:
{
    80001f50:	1101                	addi	sp,sp,-32
    80001f52:	ec06                	sd	ra,24(sp)
    80001f54:	e822                	sd	s0,16(sp)
    80001f56:	e426                	sd	s1,8(sp)
    80001f58:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f5a:	a1fff0ef          	jal	80001978 <myproc>
    80001f5e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f60:	cedfe0ef          	jal	80000c4c <acquire>
  p->state = RUNNABLE;
    80001f64:	478d                	li	a5,3
    80001f66:	cc9c                	sw	a5,24(s1)
  sched();
    80001f68:	f2fff0ef          	jal	80001e96 <sched>
  release(&p->lock);
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	d6bfe0ef          	jal	80000cd8 <release>
}
    80001f72:	60e2                	ld	ra,24(sp)
    80001f74:	6442                	ld	s0,16(sp)
    80001f76:	64a2                	ld	s1,8(sp)
    80001f78:	6105                	addi	sp,sp,32
    80001f7a:	8082                	ret

0000000080001f7c <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001f7c:	1101                	addi	sp,sp,-32
    80001f7e:	ec06                	sd	ra,24(sp)
    80001f80:	e822                	sd	s0,16(sp)
    80001f82:	e426                	sd	s1,8(sp)
    80001f84:	e04a                	sd	s2,0(sp)
    80001f86:	1000                	addi	s0,sp,32
    80001f88:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f8a:	9efff0ef          	jal	80001978 <myproc>
    80001f8e:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001f90:	cbdfe0ef          	jal	80000c4c <acquire>
  if (chan == 0)
    80001f94:	cc81                	beqz	s1,80001fac <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001f96:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001f9a:	854a                	mv	a0,s2
    80001f9c:	d3dfe0ef          	jal	80000cd8 <release>
}
    80001fa0:	60e2                	ld	ra,24(sp)
    80001fa2:	6442                	ld	s0,16(sp)
    80001fa4:	64a2                	ld	s1,8(sp)
    80001fa6:	6902                	ld	s2,0(sp)
    80001fa8:	6105                	addi	sp,sp,32
    80001faa:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001fac:	00005517          	auipc	a0,0x5
    80001fb0:	23450513          	addi	a0,a0,564 # 800071e0 <etext+0x1e0>
    80001fb4:	83dfe0ef          	jal	800007f0 <panic>

0000000080001fb8 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001fb8:	1101                	addi	sp,sp,-32
    80001fba:	ec06                	sd	ra,24(sp)
    80001fbc:	e822                	sd	s0,16(sp)
    80001fbe:	e426                	sd	s1,8(sp)
    80001fc0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fc2:	9b7ff0ef          	jal	80001978 <myproc>
    80001fc6:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001fc8:	c85fe0ef          	jal	80000c4c <acquire>
  if (p->chan != 0) {
    80001fcc:	709c                	ld	a5,32(s1)
    80001fce:	c789                	beqz	a5,80001fd8 <sleep+0x20>
    p->state = SLEEPING;
    80001fd0:	4789                	li	a5,2
    80001fd2:	cc9c                	sw	a5,24(s1)
    sched();
    80001fd4:	ec3ff0ef          	jal	80001e96 <sched>
  }
  release(&p->lock);
    80001fd8:	8526                	mv	a0,s1
    80001fda:	cfffe0ef          	jal	80000cd8 <release>
}
    80001fde:	60e2                	ld	ra,24(sp)
    80001fe0:	6442                	ld	s0,16(sp)
    80001fe2:	64a2                	ld	s1,8(sp)
    80001fe4:	6105                	addi	sp,sp,32
    80001fe6:	8082                	ret

0000000080001fe8 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001fe8:	7139                	addi	sp,sp,-64
    80001fea:	fc06                	sd	ra,56(sp)
    80001fec:	f822                	sd	s0,48(sp)
    80001fee:	f426                	sd	s1,40(sp)
    80001ff0:	f04a                	sd	s2,32(sp)
    80001ff2:	ec4e                	sd	s3,24(sp)
    80001ff4:	e852                	sd	s4,16(sp)
    80001ff6:	e456                	sd	s5,8(sp)
    80001ff8:	0080                	addi	s0,sp,64
    80001ffa:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001ffc:	0000e497          	auipc	s1,0xe
    80002000:	e6448493          	addi	s1,s1,-412 # 8000fe60 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002004:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002006:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002008:	00014997          	auipc	s3,0x14
    8000200c:	85898993          	addi	s3,s3,-1960 # 80015860 <tickslock>
    80002010:	a801                	j	80002020 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002012:	8526                	mv	a0,s1
    80002014:	cc5fe0ef          	jal	80000cd8 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002018:	16848493          	addi	s1,s1,360
    8000201c:	03348063          	beq	s1,s3,8000203c <wakeup+0x54>
    acquire(&p->lock);
    80002020:	8526                	mv	a0,s1
    80002022:	c2bfe0ef          	jal	80000c4c <acquire>
    if (p->chan == chan) {
    80002026:	709c                	ld	a5,32(s1)
    80002028:	ff2795e3          	bne	a5,s2,80002012 <wakeup+0x2a>
      p->chan = 0;
    8000202c:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002030:	4c9c                	lw	a5,24(s1)
    80002032:	ff4790e3          	bne	a5,s4,80002012 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002036:	0154ac23          	sw	s5,24(s1)
    8000203a:	bfe1                	j	80002012 <wakeup+0x2a>
  }
}
    8000203c:	70e2                	ld	ra,56(sp)
    8000203e:	7442                	ld	s0,48(sp)
    80002040:	74a2                	ld	s1,40(sp)
    80002042:	7902                	ld	s2,32(sp)
    80002044:	69e2                	ld	s3,24(sp)
    80002046:	6a42                	ld	s4,16(sp)
    80002048:	6aa2                	ld	s5,8(sp)
    8000204a:	6121                	addi	sp,sp,64
    8000204c:	8082                	ret

000000008000204e <reparent>:
{
    8000204e:	7179                	addi	sp,sp,-48
    80002050:	f406                	sd	ra,40(sp)
    80002052:	f022                	sd	s0,32(sp)
    80002054:	ec26                	sd	s1,24(sp)
    80002056:	e84a                	sd	s2,16(sp)
    80002058:	e44e                	sd	s3,8(sp)
    8000205a:	e052                	sd	s4,0(sp)
    8000205c:	1800                	addi	s0,sp,48
    8000205e:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002060:	0000e497          	auipc	s1,0xe
    80002064:	e0048493          	addi	s1,s1,-512 # 8000fe60 <proc>
      pp->parent = initproc;
    80002068:	00006a17          	auipc	s4,0x6
    8000206c:	8a0a0a13          	addi	s4,s4,-1888 # 80007908 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002070:	00013997          	auipc	s3,0x13
    80002074:	7f098993          	addi	s3,s3,2032 # 80015860 <tickslock>
    80002078:	a029                	j	80002082 <reparent+0x34>
    8000207a:	16848493          	addi	s1,s1,360
    8000207e:	01348b63          	beq	s1,s3,80002094 <reparent+0x46>
    if (pp->parent == p) {
    80002082:	7c9c                	ld	a5,56(s1)
    80002084:	ff279be3          	bne	a5,s2,8000207a <reparent+0x2c>
      pp->parent = initproc;
    80002088:	000a3503          	ld	a0,0(s4)
    8000208c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000208e:	f5bff0ef          	jal	80001fe8 <wakeup>
    80002092:	b7e5                	j	8000207a <reparent+0x2c>
}
    80002094:	70a2                	ld	ra,40(sp)
    80002096:	7402                	ld	s0,32(sp)
    80002098:	64e2                	ld	s1,24(sp)
    8000209a:	6942                	ld	s2,16(sp)
    8000209c:	69a2                	ld	s3,8(sp)
    8000209e:	6a02                	ld	s4,0(sp)
    800020a0:	6145                	addi	sp,sp,48
    800020a2:	8082                	ret

00000000800020a4 <kexit>:
{
    800020a4:	7179                	addi	sp,sp,-48
    800020a6:	f406                	sd	ra,40(sp)
    800020a8:	f022                	sd	s0,32(sp)
    800020aa:	ec26                	sd	s1,24(sp)
    800020ac:	e84a                	sd	s2,16(sp)
    800020ae:	e44e                	sd	s3,8(sp)
    800020b0:	e052                	sd	s4,0(sp)
    800020b2:	1800                	addi	s0,sp,48
    800020b4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020b6:	8c3ff0ef          	jal	80001978 <myproc>
    800020ba:	89aa                	mv	s3,a0
  if (p == initproc)
    800020bc:	00006797          	auipc	a5,0x6
    800020c0:	84c7b783          	ld	a5,-1972(a5) # 80007908 <initproc>
    800020c4:	0d050493          	addi	s1,a0,208
    800020c8:	15050913          	addi	s2,a0,336
    800020cc:	00a79f63          	bne	a5,a0,800020ea <kexit+0x46>
    panic("init exiting");
    800020d0:	00005517          	auipc	a0,0x5
    800020d4:	13050513          	addi	a0,a0,304 # 80007200 <etext+0x200>
    800020d8:	f18fe0ef          	jal	800007f0 <panic>
      fileclose(f);
    800020dc:	0e2020ef          	jal	800041be <fileclose>
      p->ofile[fd] = 0;
    800020e0:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    800020e4:	04a1                	addi	s1,s1,8
    800020e6:	01248563          	beq	s1,s2,800020f0 <kexit+0x4c>
    if (p->ofile[fd]) {
    800020ea:	6088                	ld	a0,0(s1)
    800020ec:	f965                	bnez	a0,800020dc <kexit+0x38>
    800020ee:	bfdd                	j	800020e4 <kexit+0x40>
  begin_op();
    800020f0:	423010ef          	jal	80003d12 <begin_op>
  iput(p->cwd);
    800020f4:	1509b503          	ld	a0,336(s3)
    800020f8:	352010ef          	jal	8000344a <iput>
  end_op();
    800020fc:	49d010ef          	jal	80003d98 <end_op>
  p->cwd = 0;
    80002100:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002104:	0000e497          	auipc	s1,0xe
    80002108:	94448493          	addi	s1,s1,-1724 # 8000fa48 <wait_lock>
    8000210c:	8526                	mv	a0,s1
    8000210e:	b3ffe0ef          	jal	80000c4c <acquire>
  reparent(p);
    80002112:	854e                	mv	a0,s3
    80002114:	f3bff0ef          	jal	8000204e <reparent>
  wakeup(p->parent);
    80002118:	0389b503          	ld	a0,56(s3)
    8000211c:	ecdff0ef          	jal	80001fe8 <wakeup>
  acquire(&p->lock);
    80002120:	854e                	mv	a0,s3
    80002122:	b2bfe0ef          	jal	80000c4c <acquire>
  p->xstate = status;
    80002126:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000212a:	4795                	li	a5,5
    8000212c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002130:	8526                	mv	a0,s1
    80002132:	ba7fe0ef          	jal	80000cd8 <release>
  sched();
    80002136:	d61ff0ef          	jal	80001e96 <sched>
  panic("zombie exit");
    8000213a:	00005517          	auipc	a0,0x5
    8000213e:	0d650513          	addi	a0,a0,214 # 80007210 <etext+0x210>
    80002142:	eaefe0ef          	jal	800007f0 <panic>

0000000080002146 <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    80002146:	c525                	beqz	a0,800021ae <kkill+0x68>
{
    80002148:	7179                	addi	sp,sp,-48
    8000214a:	f406                	sd	ra,40(sp)
    8000214c:	f022                	sd	s0,32(sp)
    8000214e:	ec26                	sd	s1,24(sp)
    80002150:	e84a                	sd	s2,16(sp)
    80002152:	e44e                	sd	s3,8(sp)
    80002154:	1800                	addi	s0,sp,48
    80002156:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002158:	0000e497          	auipc	s1,0xe
    8000215c:	d0848493          	addi	s1,s1,-760 # 8000fe60 <proc>
    80002160:	00013997          	auipc	s3,0x13
    80002164:	70098993          	addi	s3,s3,1792 # 80015860 <tickslock>
    acquire(&p->lock);
    80002168:	8526                	mv	a0,s1
    8000216a:	ae3fe0ef          	jal	80000c4c <acquire>
    if (p->pid == pid) {
    8000216e:	589c                	lw	a5,48(s1)
    80002170:	01278b63          	beq	a5,s2,80002186 <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002174:	8526                	mv	a0,s1
    80002176:	b63fe0ef          	jal	80000cd8 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000217a:	16848493          	addi	s1,s1,360
    8000217e:	ff3495e3          	bne	s1,s3,80002168 <kkill+0x22>
  }
  return -1;
    80002182:	557d                	li	a0,-1
    80002184:	a819                	j	8000219a <kkill+0x54>
      p->killed = 1;
    80002186:	4785                	li	a5,1
    80002188:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    8000218a:	4c98                	lw	a4,24(s1)
    8000218c:	4789                	li	a5,2
    8000218e:	00f70d63          	beq	a4,a5,800021a8 <kkill+0x62>
      release(&p->lock);
    80002192:	8526                	mv	a0,s1
    80002194:	b45fe0ef          	jal	80000cd8 <release>
      return 0;
    80002198:	4501                	li	a0,0
}
    8000219a:	70a2                	ld	ra,40(sp)
    8000219c:	7402                	ld	s0,32(sp)
    8000219e:	64e2                	ld	s1,24(sp)
    800021a0:	6942                	ld	s2,16(sp)
    800021a2:	69a2                	ld	s3,8(sp)
    800021a4:	6145                	addi	sp,sp,48
    800021a6:	8082                	ret
        p->state = RUNNABLE;
    800021a8:	478d                	li	a5,3
    800021aa:	cc9c                	sw	a5,24(s1)
    800021ac:	b7dd                	j	80002192 <kkill+0x4c>
    return -1;
    800021ae:	557d                	li	a0,-1
}
    800021b0:	8082                	ret

00000000800021b2 <setkilled>:

void
setkilled(struct proc *p)
{
    800021b2:	1101                	addi	sp,sp,-32
    800021b4:	ec06                	sd	ra,24(sp)
    800021b6:	e822                	sd	s0,16(sp)
    800021b8:	e426                	sd	s1,8(sp)
    800021ba:	1000                	addi	s0,sp,32
    800021bc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021be:	a8ffe0ef          	jal	80000c4c <acquire>
  p->killed = 1;
    800021c2:	4785                	li	a5,1
    800021c4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	b11fe0ef          	jal	80000cd8 <release>
}
    800021cc:	60e2                	ld	ra,24(sp)
    800021ce:	6442                	ld	s0,16(sp)
    800021d0:	64a2                	ld	s1,8(sp)
    800021d2:	6105                	addi	sp,sp,32
    800021d4:	8082                	ret

00000000800021d6 <killed>:

int
killed(struct proc *p)
{
    800021d6:	1101                	addi	sp,sp,-32
    800021d8:	ec06                	sd	ra,24(sp)
    800021da:	e822                	sd	s0,16(sp)
    800021dc:	e426                	sd	s1,8(sp)
    800021de:	e04a                	sd	s2,0(sp)
    800021e0:	1000                	addi	s0,sp,32
    800021e2:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800021e4:	a69fe0ef          	jal	80000c4c <acquire>
  k = p->killed;
    800021e8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800021ec:	8526                	mv	a0,s1
    800021ee:	aebfe0ef          	jal	80000cd8 <release>
  return k;
}
    800021f2:	854a                	mv	a0,s2
    800021f4:	60e2                	ld	ra,24(sp)
    800021f6:	6442                	ld	s0,16(sp)
    800021f8:	64a2                	ld	s1,8(sp)
    800021fa:	6902                	ld	s2,0(sp)
    800021fc:	6105                	addi	sp,sp,32
    800021fe:	8082                	ret

0000000080002200 <kwait>:
{
    80002200:	715d                	addi	sp,sp,-80
    80002202:	e486                	sd	ra,72(sp)
    80002204:	e0a2                	sd	s0,64(sp)
    80002206:	fc26                	sd	s1,56(sp)
    80002208:	f84a                	sd	s2,48(sp)
    8000220a:	f44e                	sd	s3,40(sp)
    8000220c:	f052                	sd	s4,32(sp)
    8000220e:	ec56                	sd	s5,24(sp)
    80002210:	e85a                	sd	s6,16(sp)
    80002212:	e45e                	sd	s7,8(sp)
    80002214:	e062                	sd	s8,0(sp)
    80002216:	0880                	addi	s0,sp,80
    80002218:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000221a:	f5eff0ef          	jal	80001978 <myproc>
    8000221e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002220:	0000e517          	auipc	a0,0xe
    80002224:	82850513          	addi	a0,a0,-2008 # 8000fa48 <wait_lock>
    80002228:	a25fe0ef          	jal	80000c4c <acquire>
    havekids = 0;
    8000222c:	4c01                	li	s8,0
        if (pp->state == ZOMBIE) {
    8000222e:	4a15                	li	s4,5
        havekids = 1;
    80002230:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002232:	00013997          	auipc	s3,0x13
    80002236:	62e98993          	addi	s3,s3,1582 # 80015860 <tickslock>
    release(&wait_lock);
    8000223a:	0000eb97          	auipc	s7,0xe
    8000223e:	80eb8b93          	addi	s7,s7,-2034 # 8000fa48 <wait_lock>
    80002242:	a84d                	j	800022f4 <kwait+0xf4>
          pid = pp->pid;
    80002244:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002248:	000b0e63          	beqz	s6,80002264 <kwait+0x64>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    8000224c:	4711                	li	a4,4
    8000224e:	02c48693          	addi	a3,s1,44
    80002252:	865a                	mv	a2,s6
    80002254:	04893583          	ld	a1,72(s2)
    80002258:	05093503          	ld	a0,80(s2)
    8000225c:	b52ff0ef          	jal	800015ae <copyout>
          if (addr != 0 &&
    80002260:	02054d63          	bltz	a0,8000229a <kwait+0x9a>
          pp->parent = 0;
    80002264:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002268:	8526                	mv	a0,s1
    8000226a:	8dbff0ef          	jal	80001b44 <freeproc>
          release(&pp->lock);
    8000226e:	8526                	mv	a0,s1
    80002270:	a69fe0ef          	jal	80000cd8 <release>
          release(&wait_lock);
    80002274:	0000d517          	auipc	a0,0xd
    80002278:	7d450513          	addi	a0,a0,2004 # 8000fa48 <wait_lock>
    8000227c:	a5dfe0ef          	jal	80000cd8 <release>
}
    80002280:	854e                	mv	a0,s3
    80002282:	60a6                	ld	ra,72(sp)
    80002284:	6406                	ld	s0,64(sp)
    80002286:	74e2                	ld	s1,56(sp)
    80002288:	7942                	ld	s2,48(sp)
    8000228a:	79a2                	ld	s3,40(sp)
    8000228c:	7a02                	ld	s4,32(sp)
    8000228e:	6ae2                	ld	s5,24(sp)
    80002290:	6b42                	ld	s6,16(sp)
    80002292:	6ba2                	ld	s7,8(sp)
    80002294:	6c02                	ld	s8,0(sp)
    80002296:	6161                	addi	sp,sp,80
    80002298:	8082                	ret
            release(&pp->lock);
    8000229a:	8526                	mv	a0,s1
    8000229c:	a3dfe0ef          	jal	80000cd8 <release>
            release(&wait_lock);
    800022a0:	0000d517          	auipc	a0,0xd
    800022a4:	7a850513          	addi	a0,a0,1960 # 8000fa48 <wait_lock>
    800022a8:	a31fe0ef          	jal	80000cd8 <release>
            return -1;
    800022ac:	59fd                	li	s3,-1
    800022ae:	bfc9                	j	80002280 <kwait+0x80>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022b0:	16848493          	addi	s1,s1,360
    800022b4:	03348063          	beq	s1,s3,800022d4 <kwait+0xd4>
      if (pp->parent == p) {
    800022b8:	7c9c                	ld	a5,56(s1)
    800022ba:	ff279be3          	bne	a5,s2,800022b0 <kwait+0xb0>
        acquire(&pp->lock);
    800022be:	8526                	mv	a0,s1
    800022c0:	98dfe0ef          	jal	80000c4c <acquire>
        if (pp->state == ZOMBIE) {
    800022c4:	4c9c                	lw	a5,24(s1)
    800022c6:	f7478fe3          	beq	a5,s4,80002244 <kwait+0x44>
        release(&pp->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	a0dfe0ef          	jal	80000cd8 <release>
        havekids = 1;
    800022d0:	8756                	mv	a4,s5
    800022d2:	bff9                	j	800022b0 <kwait+0xb0>
    if (!havekids || killed(p)) {
    800022d4:	c715                	beqz	a4,80002300 <kwait+0x100>
    800022d6:	854a                	mv	a0,s2
    800022d8:	effff0ef          	jal	800021d6 <killed>
    800022dc:	e115                	bnez	a0,80002300 <kwait+0x100>
    sleep_prepare(p); //DOC: wait-sleep
    800022de:	854a                	mv	a0,s2
    800022e0:	c9dff0ef          	jal	80001f7c <sleep_prepare>
    release(&wait_lock);
    800022e4:	855e                	mv	a0,s7
    800022e6:	9f3fe0ef          	jal	80000cd8 <release>
    sleep();
    800022ea:	ccfff0ef          	jal	80001fb8 <sleep>
    acquire(&wait_lock);
    800022ee:	855e                	mv	a0,s7
    800022f0:	95dfe0ef          	jal	80000c4c <acquire>
    havekids = 0;
    800022f4:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022f6:	0000e497          	auipc	s1,0xe
    800022fa:	b6a48493          	addi	s1,s1,-1174 # 8000fe60 <proc>
    800022fe:	bf6d                	j	800022b8 <kwait+0xb8>
      release(&wait_lock);
    80002300:	0000d517          	auipc	a0,0xd
    80002304:	74850513          	addi	a0,a0,1864 # 8000fa48 <wait_lock>
    80002308:	9d1fe0ef          	jal	80000cd8 <release>
      return -1;
    8000230c:	59fd                	li	s3,-1
    8000230e:	bf8d                	j	80002280 <kwait+0x80>

0000000080002310 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002310:	7179                	addi	sp,sp,-48
    80002312:	f406                	sd	ra,40(sp)
    80002314:	f022                	sd	s0,32(sp)
    80002316:	ec26                	sd	s1,24(sp)
    80002318:	e84a                	sd	s2,16(sp)
    8000231a:	e44e                	sd	s3,8(sp)
    8000231c:	e052                	sd	s4,0(sp)
    8000231e:	1800                	addi	s0,sp,48
    80002320:	84aa                	mv	s1,a0
    80002322:	892e                	mv	s2,a1
    80002324:	89b2                	mv	s3,a2
    80002326:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002328:	e50ff0ef          	jal	80001978 <myproc>
  if (user_dst) {
    8000232c:	c085                	beqz	s1,8000234c <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    8000232e:	8752                	mv	a4,s4
    80002330:	86ce                	mv	a3,s3
    80002332:	864a                	mv	a2,s2
    80002334:	652c                	ld	a1,72(a0)
    80002336:	6928                	ld	a0,80(a0)
    80002338:	a76ff0ef          	jal	800015ae <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000233c:	70a2                	ld	ra,40(sp)
    8000233e:	7402                	ld	s0,32(sp)
    80002340:	64e2                	ld	s1,24(sp)
    80002342:	6942                	ld	s2,16(sp)
    80002344:	69a2                	ld	s3,8(sp)
    80002346:	6a02                	ld	s4,0(sp)
    80002348:	6145                	addi	sp,sp,48
    8000234a:	8082                	ret
    memmove((char *)dst, src, len);
    8000234c:	000a061b          	sext.w	a2,s4
    80002350:	85ce                	mv	a1,s3
    80002352:	854a                	mv	a0,s2
    80002354:	a19fe0ef          	jal	80000d6c <memmove>
    return 0;
    80002358:	8526                	mv	a0,s1
    8000235a:	b7cd                	j	8000233c <either_copyout+0x2c>

000000008000235c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000235c:	7179                	addi	sp,sp,-48
    8000235e:	f406                	sd	ra,40(sp)
    80002360:	f022                	sd	s0,32(sp)
    80002362:	ec26                	sd	s1,24(sp)
    80002364:	e84a                	sd	s2,16(sp)
    80002366:	e44e                	sd	s3,8(sp)
    80002368:	e052                	sd	s4,0(sp)
    8000236a:	1800                	addi	s0,sp,48
    8000236c:	892a                	mv	s2,a0
    8000236e:	84ae                	mv	s1,a1
    80002370:	89b2                	mv	s3,a2
    80002372:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002374:	e04ff0ef          	jal	80001978 <myproc>
  if (user_src) {
    80002378:	c085                	beqz	s1,80002398 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000237a:	8752                	mv	a4,s4
    8000237c:	86ce                	mv	a3,s3
    8000237e:	864a                	mv	a2,s2
    80002380:	652c                	ld	a1,72(a0)
    80002382:	6928                	ld	a0,80(a0)
    80002384:	b16ff0ef          	jal	8000169a <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002388:	70a2                	ld	ra,40(sp)
    8000238a:	7402                	ld	s0,32(sp)
    8000238c:	64e2                	ld	s1,24(sp)
    8000238e:	6942                	ld	s2,16(sp)
    80002390:	69a2                	ld	s3,8(sp)
    80002392:	6a02                	ld	s4,0(sp)
    80002394:	6145                	addi	sp,sp,48
    80002396:	8082                	ret
    memmove(dst, (char *)src, len);
    80002398:	000a061b          	sext.w	a2,s4
    8000239c:	85ce                	mv	a1,s3
    8000239e:	854a                	mv	a0,s2
    800023a0:	9cdfe0ef          	jal	80000d6c <memmove>
    return 0;
    800023a4:	8526                	mv	a0,s1
    800023a6:	b7cd                	j	80002388 <either_copyin+0x2c>

00000000800023a8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023a8:	715d                	addi	sp,sp,-80
    800023aa:	e486                	sd	ra,72(sp)
    800023ac:	e0a2                	sd	s0,64(sp)
    800023ae:	fc26                	sd	s1,56(sp)
    800023b0:	f84a                	sd	s2,48(sp)
    800023b2:	f44e                	sd	s3,40(sp)
    800023b4:	f052                	sd	s4,32(sp)
    800023b6:	ec56                	sd	s5,24(sp)
    800023b8:	e85a                	sd	s6,16(sp)
    800023ba:	e45e                	sd	s7,8(sp)
    800023bc:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800023be:	00005517          	auipc	a0,0x5
    800023c2:	cba50513          	addi	a0,a0,-838 # 80007078 <etext+0x78>
    800023c6:	944fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023ca:	0000e497          	auipc	s1,0xe
    800023ce:	bee48493          	addi	s1,s1,-1042 # 8000ffb8 <proc+0x158>
    800023d2:	00013917          	auipc	s2,0x13
    800023d6:	5e690913          	addi	s2,s2,1510 # 800159b8 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023da:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023dc:	00005997          	auipc	s3,0x5
    800023e0:	e4498993          	addi	s3,s3,-444 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    800023e4:	00005a97          	auipc	s5,0x5
    800023e8:	e44a8a93          	addi	s5,s5,-444 # 80007228 <etext+0x228>
    printk("\n");
    800023ec:	00005a17          	auipc	s4,0x5
    800023f0:	c8ca0a13          	addi	s4,s4,-884 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023f4:	00005b97          	auipc	s7,0x5
    800023f8:	3ecb8b93          	addi	s7,s7,1004 # 800077e0 <states.0>
    800023fc:	a829                	j	80002416 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800023fe:	ed86a583          	lw	a1,-296(a3)
    80002402:	8556                	mv	a0,s5
    80002404:	906fe0ef          	jal	8000050a <printk>
    printk("\n");
    80002408:	8552                	mv	a0,s4
    8000240a:	900fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000240e:	16848493          	addi	s1,s1,360
    80002412:	03248263          	beq	s1,s2,80002436 <procdump+0x8e>
    if (p->state == UNUSED)
    80002416:	86a6                	mv	a3,s1
    80002418:	ec04a783          	lw	a5,-320(s1)
    8000241c:	dbed                	beqz	a5,8000240e <procdump+0x66>
      state = "???";
    8000241e:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002420:	fcfb6fe3          	bltu	s6,a5,800023fe <procdump+0x56>
    80002424:	02079713          	slli	a4,a5,0x20
    80002428:	01d75793          	srli	a5,a4,0x1d
    8000242c:	97de                	add	a5,a5,s7
    8000242e:	6390                	ld	a2,0(a5)
    80002430:	f679                	bnez	a2,800023fe <procdump+0x56>
      state = "???";
    80002432:	864e                	mv	a2,s3
    80002434:	b7e9                	j	800023fe <procdump+0x56>
  }
}
    80002436:	60a6                	ld	ra,72(sp)
    80002438:	6406                	ld	s0,64(sp)
    8000243a:	74e2                	ld	s1,56(sp)
    8000243c:	7942                	ld	s2,48(sp)
    8000243e:	79a2                	ld	s3,40(sp)
    80002440:	7a02                	ld	s4,32(sp)
    80002442:	6ae2                	ld	s5,24(sp)
    80002444:	6b42                	ld	s6,16(sp)
    80002446:	6ba2                	ld	s7,8(sp)
    80002448:	6161                	addi	sp,sp,80
    8000244a:	8082                	ret

000000008000244c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000244c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002450:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002454:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002456:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002458:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000245c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002460:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002464:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002468:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000246c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002470:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002474:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002478:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000247c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002480:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002484:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002488:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000248a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000248c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002490:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002494:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002498:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000249c:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024a0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024a4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024a8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024ac:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024b0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024b4:	8082                	ret

00000000800024b6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024b6:	1141                	addi	sp,sp,-16
    800024b8:	e406                	sd	ra,8(sp)
    800024ba:	e022                	sd	s0,0(sp)
    800024bc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024be:	00005597          	auipc	a1,0x5
    800024c2:	daa58593          	addi	a1,a1,-598 # 80007268 <etext+0x268>
    800024c6:	00013517          	auipc	a0,0x13
    800024ca:	39a50513          	addi	a0,a0,922 # 80015860 <tickslock>
    800024ce:	f08fe0ef          	jal	80000bd6 <initlock>
}
    800024d2:	60a2                	ld	ra,8(sp)
    800024d4:	6402                	ld	s0,0(sp)
    800024d6:	0141                	addi	sp,sp,16
    800024d8:	8082                	ret

00000000800024da <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024da:	1141                	addi	sp,sp,-16
    800024dc:	e422                	sd	s0,8(sp)
    800024de:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800024e0:	00003797          	auipc	a5,0x3
    800024e4:	12078793          	addi	a5,a5,288 # 80005600 <kernelvec>
    800024e8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024ec:	6422                	ld	s0,8(sp)
    800024ee:	0141                	addi	sp,sp,16
    800024f0:	8082                	ret

00000000800024f2 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024f2:	1141                	addi	sp,sp,-16
    800024f4:	e406                	sd	ra,8(sp)
    800024f6:	e022                	sd	s0,0(sp)
    800024f8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024fa:	c7eff0ef          	jal	80001978 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    800024fe:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002502:	04000737          	lui	a4,0x4000
    80002506:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002508:	0732                	slli	a4,a4,0xc
    8000250a:	00004797          	auipc	a5,0x4
    8000250e:	af678793          	addi	a5,a5,-1290 # 80006000 <_trampoline>
    80002512:	00004697          	auipc	a3,0x4
    80002516:	aee68693          	addi	a3,a3,-1298 # 80006000 <_trampoline>
    8000251a:	8f95                	sub	a5,a5,a3
    8000251c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000251e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002522:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002524:	18002773          	csrr	a4,satp
    80002528:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000252a:	6d38                	ld	a4,88(a0)
    8000252c:	613c                	ld	a5,64(a0)
    8000252e:	6685                	lui	a3,0x1
    80002530:	97b6                	add	a5,a5,a3
    80002532:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002534:	6d3c                	ld	a5,88(a0)
    80002536:	00000717          	auipc	a4,0x0
    8000253a:	0f870713          	addi	a4,a4,248 # 8000262e <usertrap>
    8000253e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002540:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002542:	8712                	mv	a4,tp
    80002544:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002546:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000254a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000254e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002552:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002556:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002558:	6f9c                	ld	a5,24(a5)
    8000255a:	14179073          	csrw	sepc,a5
}
    8000255e:	60a2                	ld	ra,8(sp)
    80002560:	6402                	ld	s0,0(sp)
    80002562:	0141                	addi	sp,sp,16
    80002564:	8082                	ret

0000000080002566 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002566:	1101                	addi	sp,sp,-32
    80002568:	ec06                	sd	ra,24(sp)
    8000256a:	e822                	sd	s0,16(sp)
    8000256c:	1000                	addi	s0,sp,32
  if (cpuid() == 0) {
    8000256e:	bdeff0ef          	jal	8000194c <cpuid>
    80002572:	cd11                	beqz	a0,8000258e <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002574:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002578:	000f4737          	lui	a4,0xf4
    8000257c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002580:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    80002582:	14d79073          	csrw	stimecmp,a5
}
    80002586:	60e2                	ld	ra,24(sp)
    80002588:	6442                	ld	s0,16(sp)
    8000258a:	6105                	addi	sp,sp,32
    8000258c:	8082                	ret
    8000258e:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002590:	00013497          	auipc	s1,0x13
    80002594:	2d048493          	addi	s1,s1,720 # 80015860 <tickslock>
    80002598:	8526                	mv	a0,s1
    8000259a:	eb2fe0ef          	jal	80000c4c <acquire>
    ticks++;
    8000259e:	00005517          	auipc	a0,0x5
    800025a2:	37250513          	addi	a0,a0,882 # 80007910 <ticks>
    800025a6:	411c                	lw	a5,0(a0)
    800025a8:	2785                	addiw	a5,a5,1
    800025aa:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800025ac:	a3dff0ef          	jal	80001fe8 <wakeup>
    release(&tickslock);
    800025b0:	8526                	mv	a0,s1
    800025b2:	f26fe0ef          	jal	80000cd8 <release>
    800025b6:	64a2                	ld	s1,8(sp)
    800025b8:	bf75                	j	80002574 <clockintr+0xe>

00000000800025ba <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025ba:	1101                	addi	sp,sp,-32
    800025bc:	ec06                	sd	ra,24(sp)
    800025be:	e822                	sd	s0,16(sp)
    800025c0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800025c2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800025c6:	57fd                	li	a5,-1
    800025c8:	17fe                	slli	a5,a5,0x3f
    800025ca:	07a5                	addi	a5,a5,9
    800025cc:	00f70c63          	beq	a4,a5,800025e4 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800025d0:	57fd                	li	a5,-1
    800025d2:	17fe                	slli	a5,a5,0x3f
    800025d4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025d6:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800025d8:	04f70763          	beq	a4,a5,80002626 <devintr+0x6c>
  }
}
    800025dc:	60e2                	ld	ra,24(sp)
    800025de:	6442                	ld	s0,16(sp)
    800025e0:	6105                	addi	sp,sp,32
    800025e2:	8082                	ret
    800025e4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025e6:	0c8030ef          	jal	800056ae <plic_claim>
    800025ea:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    800025ec:	47a9                	li	a5,10
    800025ee:	00f50963          	beq	a0,a5,80002600 <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    800025f2:	4785                	li	a5,1
    800025f4:	00f50963          	beq	a0,a5,80002606 <devintr+0x4c>
    return 1;
    800025f8:	4505                	li	a0,1
    } else if (irq) {
    800025fa:	e889                	bnez	s1,8000260c <devintr+0x52>
    800025fc:	64a2                	ld	s1,8(sp)
    800025fe:	bff9                	j	800025dc <devintr+0x22>
      uartintr();
    80002600:	b8cfe0ef          	jal	8000098c <uartintr>
    if (irq)
    80002604:	a819                	j	8000261a <devintr+0x60>
      virtio_disk_intr();
    80002606:	592030ef          	jal	80005b98 <virtio_disk_intr>
    if (irq)
    8000260a:	a801                	j	8000261a <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    8000260c:	85a6                	mv	a1,s1
    8000260e:	00005517          	auipc	a0,0x5
    80002612:	c6250513          	addi	a0,a0,-926 # 80007270 <etext+0x270>
    80002616:	ef5fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    8000261a:	8526                	mv	a0,s1
    8000261c:	0b4030ef          	jal	800056d0 <plic_complete>
    return 1;
    80002620:	4505                	li	a0,1
    80002622:	64a2                	ld	s1,8(sp)
    80002624:	bf65                	j	800025dc <devintr+0x22>
    clockintr();
    80002626:	f41ff0ef          	jal	80002566 <clockintr>
    return 2;
    8000262a:	4509                	li	a0,2
    8000262c:	bf45                	j	800025dc <devintr+0x22>

000000008000262e <usertrap>:
{
    8000262e:	1101                	addi	sp,sp,-32
    80002630:	ec06                	sd	ra,24(sp)
    80002632:	e822                	sd	s0,16(sp)
    80002634:	e426                	sd	s1,8(sp)
    80002636:	e04a                	sd	s2,0(sp)
    80002638:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000263a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000263e:	1007f793          	andi	a5,a5,256
    80002642:	eba5                	bnez	a5,800026b2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002644:	00003797          	auipc	a5,0x3
    80002648:	fbc78793          	addi	a5,a5,-68 # 80005600 <kernelvec>
    8000264c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002650:	b28ff0ef          	jal	80001978 <myproc>
    80002654:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002656:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002658:	14102773          	csrr	a4,sepc
    8000265c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000265e:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002662:	47a1                	li	a5,8
    80002664:	04f70d63          	beq	a4,a5,800026be <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002668:	f53ff0ef          	jal	800025ba <devintr>
    8000266c:	892a                	mv	s2,a0
    8000266e:	e54d                	bnez	a0,80002718 <usertrap+0xea>
    80002670:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002674:	47bd                	li	a5,15
    80002676:	08f70463          	beq	a4,a5,800026fe <usertrap+0xd0>
    8000267a:	14202773          	csrr	a4,scause
    8000267e:	47b5                	li	a5,13
    80002680:	06f70f63          	beq	a4,a5,800026fe <usertrap+0xd0>
    80002684:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002688:	5890                	lw	a2,48(s1)
    8000268a:	00005517          	auipc	a0,0x5
    8000268e:	c2650513          	addi	a0,a0,-986 # 800072b0 <etext+0x2b0>
    80002692:	e79fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002696:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000269a:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000269e:	00005517          	auipc	a0,0x5
    800026a2:	c4250513          	addi	a0,a0,-958 # 800072e0 <etext+0x2e0>
    800026a6:	e65fd0ef          	jal	8000050a <printk>
    setkilled(p);
    800026aa:	8526                	mv	a0,s1
    800026ac:	b07ff0ef          	jal	800021b2 <setkilled>
    800026b0:	a015                	j	800026d4 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800026b2:	00005517          	auipc	a0,0x5
    800026b6:	bde50513          	addi	a0,a0,-1058 # 80007290 <etext+0x290>
    800026ba:	936fe0ef          	jal	800007f0 <panic>
    if (killed(p))
    800026be:	b19ff0ef          	jal	800021d6 <killed>
    800026c2:	e915                	bnez	a0,800026f6 <usertrap+0xc8>
    p->trapframe->epc += 4;
    800026c4:	6cb8                	ld	a4,88(s1)
    800026c6:	6f1c                	ld	a5,24(a4)
    800026c8:	0791                	addi	a5,a5,4
    800026ca:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800026cc:	10016073          	csrsi	sstatus,2
    syscall();
    800026d0:	24a000ef          	jal	8000291a <syscall>
  if (killed(p))
    800026d4:	8526                	mv	a0,s1
    800026d6:	b01ff0ef          	jal	800021d6 <killed>
    800026da:	e521                	bnez	a0,80002722 <usertrap+0xf4>
  prepare_return();
    800026dc:	e17ff0ef          	jal	800024f2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026e0:	68a8                	ld	a0,80(s1)
    800026e2:	8131                	srli	a0,a0,0xc
    800026e4:	57fd                	li	a5,-1
    800026e6:	17fe                	slli	a5,a5,0x3f
    800026e8:	8d5d                	or	a0,a0,a5
}
    800026ea:	60e2                	ld	ra,24(sp)
    800026ec:	6442                	ld	s0,16(sp)
    800026ee:	64a2                	ld	s1,8(sp)
    800026f0:	6902                	ld	s2,0(sp)
    800026f2:	6105                	addi	sp,sp,32
    800026f4:	8082                	ret
      kexit(-1);
    800026f6:	557d                	li	a0,-1
    800026f8:	9adff0ef          	jal	800020a4 <kexit>
    800026fc:	b7e1                	j	800026c4 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    800026fe:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002702:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002706:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002708:	0016b693          	seqz	a3,a3
    8000270c:	64ac                	ld	a1,72(s1)
    8000270e:	68a8                	ld	a0,80(s1)
    80002710:	e23fe0ef          	jal	80001532 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002714:	f161                	bnez	a0,800026d4 <usertrap+0xa6>
    80002716:	b7bd                	j	80002684 <usertrap+0x56>
  if (killed(p))
    80002718:	8526                	mv	a0,s1
    8000271a:	abdff0ef          	jal	800021d6 <killed>
    8000271e:	c511                	beqz	a0,8000272a <usertrap+0xfc>
    80002720:	a011                	j	80002724 <usertrap+0xf6>
    80002722:	4901                	li	s2,0
    kexit(-1);
    80002724:	557d                	li	a0,-1
    80002726:	97fff0ef          	jal	800020a4 <kexit>
  if (which_dev == 2)
    8000272a:	4789                	li	a5,2
    8000272c:	faf918e3          	bne	s2,a5,800026dc <usertrap+0xae>
    yield();
    80002730:	821ff0ef          	jal	80001f50 <yield>
    80002734:	b765                	j	800026dc <usertrap+0xae>

0000000080002736 <kerneltrap>:
{
    80002736:	7179                	addi	sp,sp,-48
    80002738:	f406                	sd	ra,40(sp)
    8000273a:	f022                	sd	s0,32(sp)
    8000273c:	ec26                	sd	s1,24(sp)
    8000273e:	e84a                	sd	s2,16(sp)
    80002740:	e44e                	sd	s3,8(sp)
    80002742:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002744:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002748:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000274c:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002750:	1004f793          	andi	a5,s1,256
    80002754:	c795                	beqz	a5,80002780 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002756:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000275a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000275c:	eb85                	bnez	a5,8000278c <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    8000275e:	e5dff0ef          	jal	800025ba <devintr>
    80002762:	c91d                	beqz	a0,80002798 <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    80002764:	4789                	li	a5,2
    80002766:	04f50a63          	beq	a0,a5,800027ba <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000276a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000276e:	10049073          	csrw	sstatus,s1
}
    80002772:	70a2                	ld	ra,40(sp)
    80002774:	7402                	ld	s0,32(sp)
    80002776:	64e2                	ld	s1,24(sp)
    80002778:	6942                	ld	s2,16(sp)
    8000277a:	69a2                	ld	s3,8(sp)
    8000277c:	6145                	addi	sp,sp,48
    8000277e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002780:	00005517          	auipc	a0,0x5
    80002784:	b8850513          	addi	a0,a0,-1144 # 80007308 <etext+0x308>
    80002788:	868fe0ef          	jal	800007f0 <panic>
    panic("kerneltrap: interrupts enabled");
    8000278c:	00005517          	auipc	a0,0x5
    80002790:	ba450513          	addi	a0,a0,-1116 # 80007330 <etext+0x330>
    80002794:	85cfe0ef          	jal	800007f0 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002798:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    8000279c:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800027a0:	85ce                	mv	a1,s3
    800027a2:	00005517          	auipc	a0,0x5
    800027a6:	bae50513          	addi	a0,a0,-1106 # 80007350 <etext+0x350>
    800027aa:	d61fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800027ae:	00005517          	auipc	a0,0x5
    800027b2:	bca50513          	addi	a0,a0,-1078 # 80007378 <etext+0x378>
    800027b6:	83afe0ef          	jal	800007f0 <panic>
  if (which_dev == 2 && myproc() != 0)
    800027ba:	9beff0ef          	jal	80001978 <myproc>
    800027be:	d555                	beqz	a0,8000276a <kerneltrap+0x34>
    yield();
    800027c0:	f90ff0ef          	jal	80001f50 <yield>
    800027c4:	b75d                	j	8000276a <kerneltrap+0x34>

00000000800027c6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027c6:	1101                	addi	sp,sp,-32
    800027c8:	ec06                	sd	ra,24(sp)
    800027ca:	e822                	sd	s0,16(sp)
    800027cc:	e426                	sd	s1,8(sp)
    800027ce:	1000                	addi	s0,sp,32
    800027d0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027d2:	9a6ff0ef          	jal	80001978 <myproc>
  switch (n) {
    800027d6:	4795                	li	a5,5
    800027d8:	0497e163          	bltu	a5,s1,8000281a <argraw+0x54>
    800027dc:	048a                	slli	s1,s1,0x2
    800027de:	00005717          	auipc	a4,0x5
    800027e2:	03270713          	addi	a4,a4,50 # 80007810 <states.0+0x30>
    800027e6:	94ba                	add	s1,s1,a4
    800027e8:	409c                	lw	a5,0(s1)
    800027ea:	97ba                	add	a5,a5,a4
    800027ec:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027ee:	6d3c                	ld	a5,88(a0)
    800027f0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027f2:	60e2                	ld	ra,24(sp)
    800027f4:	6442                	ld	s0,16(sp)
    800027f6:	64a2                	ld	s1,8(sp)
    800027f8:	6105                	addi	sp,sp,32
    800027fa:	8082                	ret
    return p->trapframe->a1;
    800027fc:	6d3c                	ld	a5,88(a0)
    800027fe:	7fa8                	ld	a0,120(a5)
    80002800:	bfcd                	j	800027f2 <argraw+0x2c>
    return p->trapframe->a2;
    80002802:	6d3c                	ld	a5,88(a0)
    80002804:	63c8                	ld	a0,128(a5)
    80002806:	b7f5                	j	800027f2 <argraw+0x2c>
    return p->trapframe->a3;
    80002808:	6d3c                	ld	a5,88(a0)
    8000280a:	67c8                	ld	a0,136(a5)
    8000280c:	b7dd                	j	800027f2 <argraw+0x2c>
    return p->trapframe->a4;
    8000280e:	6d3c                	ld	a5,88(a0)
    80002810:	6bc8                	ld	a0,144(a5)
    80002812:	b7c5                	j	800027f2 <argraw+0x2c>
    return p->trapframe->a5;
    80002814:	6d3c                	ld	a5,88(a0)
    80002816:	6fc8                	ld	a0,152(a5)
    80002818:	bfe9                	j	800027f2 <argraw+0x2c>
  panic("argraw");
    8000281a:	00005517          	auipc	a0,0x5
    8000281e:	b6e50513          	addi	a0,a0,-1170 # 80007388 <etext+0x388>
    80002822:	fcffd0ef          	jal	800007f0 <panic>

0000000080002826 <fetchaddr>:
{
    80002826:	1101                	addi	sp,sp,-32
    80002828:	ec06                	sd	ra,24(sp)
    8000282a:	e822                	sd	s0,16(sp)
    8000282c:	e426                	sd	s1,8(sp)
    8000282e:	e04a                	sd	s2,0(sp)
    80002830:	1000                	addi	s0,sp,32
    80002832:	84aa                	mv	s1,a0
    80002834:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002836:	942ff0ef          	jal	80001978 <myproc>
  if (addr >= p->sz ||
    8000283a:	652c                	ld	a1,72(a0)
    8000283c:	02b4f663          	bgeu	s1,a1,80002868 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002840:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002844:	02f5e463          	bltu	a1,a5,8000286c <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002848:	4721                	li	a4,8
    8000284a:	86a6                	mv	a3,s1
    8000284c:	864a                	mv	a2,s2
    8000284e:	6928                	ld	a0,80(a0)
    80002850:	e4bfe0ef          	jal	8000169a <copyin>
    80002854:	00a03533          	snez	a0,a0
    80002858:	40a00533          	neg	a0,a0
}
    8000285c:	60e2                	ld	ra,24(sp)
    8000285e:	6442                	ld	s0,16(sp)
    80002860:	64a2                	ld	s1,8(sp)
    80002862:	6902                	ld	s2,0(sp)
    80002864:	6105                	addi	sp,sp,32
    80002866:	8082                	ret
    return -1;
    80002868:	557d                	li	a0,-1
    8000286a:	bfcd                	j	8000285c <fetchaddr+0x36>
    8000286c:	557d                	li	a0,-1
    8000286e:	b7fd                	j	8000285c <fetchaddr+0x36>

0000000080002870 <fetchstr>:
{
    80002870:	7179                	addi	sp,sp,-48
    80002872:	f406                	sd	ra,40(sp)
    80002874:	f022                	sd	s0,32(sp)
    80002876:	ec26                	sd	s1,24(sp)
    80002878:	e84a                	sd	s2,16(sp)
    8000287a:	e44e                	sd	s3,8(sp)
    8000287c:	1800                	addi	s0,sp,48
    8000287e:	892a                	mv	s2,a0
    80002880:	84ae                	mv	s1,a1
    80002882:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002884:	8f4ff0ef          	jal	80001978 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002888:	874e                	mv	a4,s3
    8000288a:	86ca                	mv	a3,s2
    8000288c:	8626                	mv	a2,s1
    8000288e:	652c                	ld	a1,72(a0)
    80002890:	6928                	ld	a0,80(a0)
    80002892:	e9ffe0ef          	jal	80001730 <copyinstr>
    80002896:	00054c63          	bltz	a0,800028ae <fetchstr+0x3e>
  return strlen(buf);
    8000289a:	8526                	mv	a0,s1
    8000289c:	de4fe0ef          	jal	80000e80 <strlen>
}
    800028a0:	70a2                	ld	ra,40(sp)
    800028a2:	7402                	ld	s0,32(sp)
    800028a4:	64e2                	ld	s1,24(sp)
    800028a6:	6942                	ld	s2,16(sp)
    800028a8:	69a2                	ld	s3,8(sp)
    800028aa:	6145                	addi	sp,sp,48
    800028ac:	8082                	ret
    return -1;
    800028ae:	557d                	li	a0,-1
    800028b0:	bfc5                	j	800028a0 <fetchstr+0x30>

00000000800028b2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028b2:	1101                	addi	sp,sp,-32
    800028b4:	ec06                	sd	ra,24(sp)
    800028b6:	e822                	sd	s0,16(sp)
    800028b8:	e426                	sd	s1,8(sp)
    800028ba:	1000                	addi	s0,sp,32
    800028bc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028be:	f09ff0ef          	jal	800027c6 <argraw>
    800028c2:	c088                	sw	a0,0(s1)
}
    800028c4:	60e2                	ld	ra,24(sp)
    800028c6:	6442                	ld	s0,16(sp)
    800028c8:	64a2                	ld	s1,8(sp)
    800028ca:	6105                	addi	sp,sp,32
    800028cc:	8082                	ret

00000000800028ce <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028ce:	1101                	addi	sp,sp,-32
    800028d0:	ec06                	sd	ra,24(sp)
    800028d2:	e822                	sd	s0,16(sp)
    800028d4:	e426                	sd	s1,8(sp)
    800028d6:	1000                	addi	s0,sp,32
    800028d8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028da:	eedff0ef          	jal	800027c6 <argraw>
    800028de:	e088                	sd	a0,0(s1)
}
    800028e0:	60e2                	ld	ra,24(sp)
    800028e2:	6442                	ld	s0,16(sp)
    800028e4:	64a2                	ld	s1,8(sp)
    800028e6:	6105                	addi	sp,sp,32
    800028e8:	8082                	ret

00000000800028ea <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028ea:	7179                	addi	sp,sp,-48
    800028ec:	f406                	sd	ra,40(sp)
    800028ee:	f022                	sd	s0,32(sp)
    800028f0:	ec26                	sd	s1,24(sp)
    800028f2:	e84a                	sd	s2,16(sp)
    800028f4:	1800                	addi	s0,sp,48
    800028f6:	84ae                	mv	s1,a1
    800028f8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800028fa:	fd840593          	addi	a1,s0,-40
    800028fe:	fd1ff0ef          	jal	800028ce <argaddr>
  return fetchstr(addr, buf, max);
    80002902:	864a                	mv	a2,s2
    80002904:	85a6                	mv	a1,s1
    80002906:	fd843503          	ld	a0,-40(s0)
    8000290a:	f67ff0ef          	jal	80002870 <fetchstr>
}
    8000290e:	70a2                	ld	ra,40(sp)
    80002910:	7402                	ld	s0,32(sp)
    80002912:	64e2                	ld	s1,24(sp)
    80002914:	6942                	ld	s2,16(sp)
    80002916:	6145                	addi	sp,sp,48
    80002918:	8082                	ret

000000008000291a <syscall>:
  // clang-format on
};

void
syscall(void)
{
    8000291a:	1101                	addi	sp,sp,-32
    8000291c:	ec06                	sd	ra,24(sp)
    8000291e:	e822                	sd	s0,16(sp)
    80002920:	e426                	sd	s1,8(sp)
    80002922:	e04a                	sd	s2,0(sp)
    80002924:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002926:	852ff0ef          	jal	80001978 <myproc>
    8000292a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000292c:	05853903          	ld	s2,88(a0)
    80002930:	0a893783          	ld	a5,168(s2)
    80002934:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002938:	37fd                	addiw	a5,a5,-1
    8000293a:	4755                	li	a4,21
    8000293c:	00f76f63          	bltu	a4,a5,8000295a <syscall+0x40>
    80002940:	00369713          	slli	a4,a3,0x3
    80002944:	00005797          	auipc	a5,0x5
    80002948:	ee478793          	addi	a5,a5,-284 # 80007828 <syscalls>
    8000294c:	97ba                	add	a5,a5,a4
    8000294e:	639c                	ld	a5,0(a5)
    80002950:	c789                	beqz	a5,8000295a <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002952:	9782                	jalr	a5
    80002954:	06a93823          	sd	a0,112(s2)
    80002958:	a829                	j	80002972 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    8000295a:	15848613          	addi	a2,s1,344
    8000295e:	588c                	lw	a1,48(s1)
    80002960:	00005517          	auipc	a0,0x5
    80002964:	a3050513          	addi	a0,a0,-1488 # 80007390 <etext+0x390>
    80002968:	ba3fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    8000296c:	6cbc                	ld	a5,88(s1)
    8000296e:	577d                	li	a4,-1
    80002970:	fbb8                	sd	a4,112(a5)
  }
}
    80002972:	60e2                	ld	ra,24(sp)
    80002974:	6442                	ld	s0,16(sp)
    80002976:	64a2                	ld	s1,8(sp)
    80002978:	6902                	ld	s2,0(sp)
    8000297a:	6105                	addi	sp,sp,32
    8000297c:	8082                	ret

000000008000297e <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000297e:	1101                	addi	sp,sp,-32
    80002980:	ec06                	sd	ra,24(sp)
    80002982:	e822                	sd	s0,16(sp)
    80002984:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002986:	fec40593          	addi	a1,s0,-20
    8000298a:	4501                	li	a0,0
    8000298c:	f27ff0ef          	jal	800028b2 <argint>
  kexit(n);
    80002990:	fec42503          	lw	a0,-20(s0)
    80002994:	f10ff0ef          	jal	800020a4 <kexit>
  return 0; // not reached
}
    80002998:	4501                	li	a0,0
    8000299a:	60e2                	ld	ra,24(sp)
    8000299c:	6442                	ld	s0,16(sp)
    8000299e:	6105                	addi	sp,sp,32
    800029a0:	8082                	ret

00000000800029a2 <sys_getpid>:

uint64
sys_getpid(void)
{
    800029a2:	1141                	addi	sp,sp,-16
    800029a4:	e406                	sd	ra,8(sp)
    800029a6:	e022                	sd	s0,0(sp)
    800029a8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029aa:	fcffe0ef          	jal	80001978 <myproc>
}
    800029ae:	5908                	lw	a0,48(a0)
    800029b0:	60a2                	ld	ra,8(sp)
    800029b2:	6402                	ld	s0,0(sp)
    800029b4:	0141                	addi	sp,sp,16
    800029b6:	8082                	ret

00000000800029b8 <sys_fork>:

uint64
sys_fork(void)
{
    800029b8:	1141                	addi	sp,sp,-16
    800029ba:	e406                	sd	ra,8(sp)
    800029bc:	e022                	sd	s0,0(sp)
    800029be:	0800                	addi	s0,sp,16
  return kfork();
    800029c0:	b14ff0ef          	jal	80001cd4 <kfork>
}
    800029c4:	60a2                	ld	ra,8(sp)
    800029c6:	6402                	ld	s0,0(sp)
    800029c8:	0141                	addi	sp,sp,16
    800029ca:	8082                	ret

00000000800029cc <sys_wait>:

uint64
sys_wait(void)
{
    800029cc:	1101                	addi	sp,sp,-32
    800029ce:	ec06                	sd	ra,24(sp)
    800029d0:	e822                	sd	s0,16(sp)
    800029d2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029d4:	fe840593          	addi	a1,s0,-24
    800029d8:	4501                	li	a0,0
    800029da:	ef5ff0ef          	jal	800028ce <argaddr>
  return kwait(p);
    800029de:	fe843503          	ld	a0,-24(s0)
    800029e2:	81fff0ef          	jal	80002200 <kwait>
}
    800029e6:	60e2                	ld	ra,24(sp)
    800029e8:	6442                	ld	s0,16(sp)
    800029ea:	6105                	addi	sp,sp,32
    800029ec:	8082                	ret

00000000800029ee <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029ee:	7179                	addi	sp,sp,-48
    800029f0:	f406                	sd	ra,40(sp)
    800029f2:	f022                	sd	s0,32(sp)
    800029f4:	ec26                	sd	s1,24(sp)
    800029f6:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029f8:	fd840593          	addi	a1,s0,-40
    800029fc:	4501                	li	a0,0
    800029fe:	eb5ff0ef          	jal	800028b2 <argint>
  argint(1, &t);
    80002a02:	fdc40593          	addi	a1,s0,-36
    80002a06:	4505                	li	a0,1
    80002a08:	eabff0ef          	jal	800028b2 <argint>
  addr = myproc()->sz;
    80002a0c:	f6dfe0ef          	jal	80001978 <myproc>
    80002a10:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002a12:	fdc42703          	lw	a4,-36(s0)
    80002a16:	4785                	li	a5,1
    80002a18:	02f70763          	beq	a4,a5,80002a46 <sys_sbrk+0x58>
    80002a1c:	fd842783          	lw	a5,-40(s0)
    80002a20:	0207c363          	bltz	a5,80002a46 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002a24:	97a6                	add	a5,a5,s1
    80002a26:	0297ee63          	bltu	a5,s1,80002a62 <sys_sbrk+0x74>
      return -1;
    if (addr + n > TRAPFRAME)
    80002a2a:	02000737          	lui	a4,0x2000
    80002a2e:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a30:	0736                	slli	a4,a4,0xd
    80002a32:	02f76a63          	bltu	a4,a5,80002a66 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002a36:	f43fe0ef          	jal	80001978 <myproc>
    80002a3a:	fd842703          	lw	a4,-40(s0)
    80002a3e:	653c                	ld	a5,72(a0)
    80002a40:	97ba                	add	a5,a5,a4
    80002a42:	e53c                	sd	a5,72(a0)
    80002a44:	a039                	j	80002a52 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002a46:	fd842503          	lw	a0,-40(s0)
    80002a4a:	a28ff0ef          	jal	80001c72 <growproc>
    80002a4e:	00054863          	bltz	a0,80002a5e <sys_sbrk+0x70>
  }
  return addr;
}
    80002a52:	8526                	mv	a0,s1
    80002a54:	70a2                	ld	ra,40(sp)
    80002a56:	7402                	ld	s0,32(sp)
    80002a58:	64e2                	ld	s1,24(sp)
    80002a5a:	6145                	addi	sp,sp,48
    80002a5c:	8082                	ret
      return -1;
    80002a5e:	54fd                	li	s1,-1
    80002a60:	bfcd                	j	80002a52 <sys_sbrk+0x64>
      return -1;
    80002a62:	54fd                	li	s1,-1
    80002a64:	b7fd                	j	80002a52 <sys_sbrk+0x64>
      return -1;
    80002a66:	54fd                	li	s1,-1
    80002a68:	b7ed                	j	80002a52 <sys_sbrk+0x64>

0000000080002a6a <sys_pause>:

uint64
sys_pause(void)
{
    80002a6a:	7139                	addi	sp,sp,-64
    80002a6c:	fc06                	sd	ra,56(sp)
    80002a6e:	f822                	sd	s0,48(sp)
    80002a70:	ec4e                	sd	s3,24(sp)
    80002a72:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a74:	fcc40593          	addi	a1,s0,-52
    80002a78:	4501                	li	a0,0
    80002a7a:	e39ff0ef          	jal	800028b2 <argint>
  if (n < 0)
    80002a7e:	fcc42783          	lw	a5,-52(s0)
    80002a82:	0607cf63          	bltz	a5,80002b00 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002a86:	00013517          	auipc	a0,0x13
    80002a8a:	dda50513          	addi	a0,a0,-550 # 80015860 <tickslock>
    80002a8e:	9befe0ef          	jal	80000c4c <acquire>
  ticks0 = ticks;
    80002a92:	00005997          	auipc	s3,0x5
    80002a96:	e7e9a983          	lw	s3,-386(s3) # 80007910 <ticks>
  while (ticks - ticks0 < n) {
    80002a9a:	fcc42783          	lw	a5,-52(s0)
    80002a9e:	c7a9                	beqz	a5,80002ae8 <sys_pause+0x7e>
    80002aa0:	f426                	sd	s1,40(sp)
    80002aa2:	f04a                	sd	s2,32(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002aa4:	00005917          	auipc	s2,0x5
    80002aa8:	e6c90913          	addi	s2,s2,-404 # 80007910 <ticks>
    release(&tickslock);
    80002aac:	00013497          	auipc	s1,0x13
    80002ab0:	db448493          	addi	s1,s1,-588 # 80015860 <tickslock>
    if (killed(myproc())) {
    80002ab4:	ec5fe0ef          	jal	80001978 <myproc>
    80002ab8:	f1eff0ef          	jal	800021d6 <killed>
    80002abc:	e529                	bnez	a0,80002b06 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002abe:	854a                	mv	a0,s2
    80002ac0:	cbcff0ef          	jal	80001f7c <sleep_prepare>
    release(&tickslock);
    80002ac4:	8526                	mv	a0,s1
    80002ac6:	a12fe0ef          	jal	80000cd8 <release>
    sleep();
    80002aca:	ceeff0ef          	jal	80001fb8 <sleep>
    acquire(&tickslock);
    80002ace:	8526                	mv	a0,s1
    80002ad0:	97cfe0ef          	jal	80000c4c <acquire>
  while (ticks - ticks0 < n) {
    80002ad4:	00092783          	lw	a5,0(s2)
    80002ad8:	413787bb          	subw	a5,a5,s3
    80002adc:	fcc42703          	lw	a4,-52(s0)
    80002ae0:	fce7eae3          	bltu	a5,a4,80002ab4 <sys_pause+0x4a>
    80002ae4:	74a2                	ld	s1,40(sp)
    80002ae6:	7902                	ld	s2,32(sp)
  }
  release(&tickslock);
    80002ae8:	00013517          	auipc	a0,0x13
    80002aec:	d7850513          	addi	a0,a0,-648 # 80015860 <tickslock>
    80002af0:	9e8fe0ef          	jal	80000cd8 <release>
  return 0;
    80002af4:	4501                	li	a0,0
}
    80002af6:	70e2                	ld	ra,56(sp)
    80002af8:	7442                	ld	s0,48(sp)
    80002afa:	69e2                	ld	s3,24(sp)
    80002afc:	6121                	addi	sp,sp,64
    80002afe:	8082                	ret
    n = 0;
    80002b00:	fc042623          	sw	zero,-52(s0)
    80002b04:	b749                	j	80002a86 <sys_pause+0x1c>
      release(&tickslock);
    80002b06:	00013517          	auipc	a0,0x13
    80002b0a:	d5a50513          	addi	a0,a0,-678 # 80015860 <tickslock>
    80002b0e:	9cafe0ef          	jal	80000cd8 <release>
      return -1;
    80002b12:	557d                	li	a0,-1
    80002b14:	74a2                	ld	s1,40(sp)
    80002b16:	7902                	ld	s2,32(sp)
    80002b18:	bff9                	j	80002af6 <sys_pause+0x8c>

0000000080002b1a <sys_kill>:

uint64
sys_kill(void)
{
    80002b1a:	1101                	addi	sp,sp,-32
    80002b1c:	ec06                	sd	ra,24(sp)
    80002b1e:	e822                	sd	s0,16(sp)
    80002b20:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b22:	fec40593          	addi	a1,s0,-20
    80002b26:	4501                	li	a0,0
    80002b28:	d8bff0ef          	jal	800028b2 <argint>
  return kkill(pid);
    80002b2c:	fec42503          	lw	a0,-20(s0)
    80002b30:	e16ff0ef          	jal	80002146 <kkill>
}
    80002b34:	60e2                	ld	ra,24(sp)
    80002b36:	6442                	ld	s0,16(sp)
    80002b38:	6105                	addi	sp,sp,32
    80002b3a:	8082                	ret

0000000080002b3c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b3c:	1101                	addi	sp,sp,-32
    80002b3e:	ec06                	sd	ra,24(sp)
    80002b40:	e822                	sd	s0,16(sp)
    80002b42:	e426                	sd	s1,8(sp)
    80002b44:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b46:	00013517          	auipc	a0,0x13
    80002b4a:	d1a50513          	addi	a0,a0,-742 # 80015860 <tickslock>
    80002b4e:	8fefe0ef          	jal	80000c4c <acquire>
  xticks = ticks;
    80002b52:	00005497          	auipc	s1,0x5
    80002b56:	dbe4a483          	lw	s1,-578(s1) # 80007910 <ticks>
  release(&tickslock);
    80002b5a:	00013517          	auipc	a0,0x13
    80002b5e:	d0650513          	addi	a0,a0,-762 # 80015860 <tickslock>
    80002b62:	976fe0ef          	jal	80000cd8 <release>
  return xticks;
}
    80002b66:	02049513          	slli	a0,s1,0x20
    80002b6a:	9101                	srli	a0,a0,0x20
    80002b6c:	60e2                	ld	ra,24(sp)
    80002b6e:	6442                	ld	s0,16(sp)
    80002b70:	64a2                	ld	s1,8(sp)
    80002b72:	6105                	addi	sp,sp,32
    80002b74:	8082                	ret

0000000080002b76 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b76:	7179                	addi	sp,sp,-48
    80002b78:	f406                	sd	ra,40(sp)
    80002b7a:	f022                	sd	s0,32(sp)
    80002b7c:	ec26                	sd	s1,24(sp)
    80002b7e:	e84a                	sd	s2,16(sp)
    80002b80:	e44e                	sd	s3,8(sp)
    80002b82:	e052                	sd	s4,0(sp)
    80002b84:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b86:	00005597          	auipc	a1,0x5
    80002b8a:	82a58593          	addi	a1,a1,-2006 # 800073b0 <etext+0x3b0>
    80002b8e:	00013517          	auipc	a0,0x13
    80002b92:	cea50513          	addi	a0,a0,-790 # 80015878 <bcache>
    80002b96:	840fe0ef          	jal	80000bd6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b9a:	0001b797          	auipc	a5,0x1b
    80002b9e:	cde78793          	addi	a5,a5,-802 # 8001d878 <bcache+0x8000>
    80002ba2:	0001b717          	auipc	a4,0x1b
    80002ba6:	f3e70713          	addi	a4,a4,-194 # 8001dae0 <bcache+0x8268>
    80002baa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002bae:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002bb2:	00013497          	auipc	s1,0x13
    80002bb6:	cde48493          	addi	s1,s1,-802 # 80015890 <bcache+0x18>
    b->next = bcache.head.next;
    80002bba:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bbc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bbe:	00004a17          	auipc	s4,0x4
    80002bc2:	7faa0a13          	addi	s4,s4,2042 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002bc6:	2b893783          	ld	a5,696(s2)
    80002bca:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bcc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bd0:	85d2                	mv	a1,s4
    80002bd2:	01048513          	addi	a0,s1,16
    80002bd6:	414010ef          	jal	80003fea <initsleeplock>
    bcache.head.next->prev = b;
    80002bda:	2b893783          	ld	a5,696(s2)
    80002bde:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002be0:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002be4:	45848493          	addi	s1,s1,1112
    80002be8:	fd349fe3          	bne	s1,s3,80002bc6 <binit+0x50>
  }
}
    80002bec:	70a2                	ld	ra,40(sp)
    80002bee:	7402                	ld	s0,32(sp)
    80002bf0:	64e2                	ld	s1,24(sp)
    80002bf2:	6942                	ld	s2,16(sp)
    80002bf4:	69a2                	ld	s3,8(sp)
    80002bf6:	6a02                	ld	s4,0(sp)
    80002bf8:	6145                	addi	sp,sp,48
    80002bfa:	8082                	ret

0000000080002bfc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002bfc:	7179                	addi	sp,sp,-48
    80002bfe:	f406                	sd	ra,40(sp)
    80002c00:	f022                	sd	s0,32(sp)
    80002c02:	ec26                	sd	s1,24(sp)
    80002c04:	e84a                	sd	s2,16(sp)
    80002c06:	e44e                	sd	s3,8(sp)
    80002c08:	1800                	addi	s0,sp,48
    80002c0a:	892a                	mv	s2,a0
    80002c0c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c0e:	00013517          	auipc	a0,0x13
    80002c12:	c6a50513          	addi	a0,a0,-918 # 80015878 <bcache>
    80002c16:	836fe0ef          	jal	80000c4c <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002c1a:	0001b497          	auipc	s1,0x1b
    80002c1e:	f164b483          	ld	s1,-234(s1) # 8001db30 <bcache+0x82b8>
    80002c22:	0001b797          	auipc	a5,0x1b
    80002c26:	ebe78793          	addi	a5,a5,-322 # 8001dae0 <bcache+0x8268>
    80002c2a:	02f48b63          	beq	s1,a5,80002c60 <bread+0x64>
    80002c2e:	873e                	mv	a4,a5
    80002c30:	a021                	j	80002c38 <bread+0x3c>
    80002c32:	68a4                	ld	s1,80(s1)
    80002c34:	02e48663          	beq	s1,a4,80002c60 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002c38:	449c                	lw	a5,8(s1)
    80002c3a:	ff279ce3          	bne	a5,s2,80002c32 <bread+0x36>
    80002c3e:	44dc                	lw	a5,12(s1)
    80002c40:	ff3799e3          	bne	a5,s3,80002c32 <bread+0x36>
      b->refcnt++;
    80002c44:	40bc                	lw	a5,64(s1)
    80002c46:	2785                	addiw	a5,a5,1
    80002c48:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c4a:	00013517          	auipc	a0,0x13
    80002c4e:	c2e50513          	addi	a0,a0,-978 # 80015878 <bcache>
    80002c52:	886fe0ef          	jal	80000cd8 <release>
      acquiresleep(&b->lock);
    80002c56:	01048513          	addi	a0,s1,16
    80002c5a:	3c6010ef          	jal	80004020 <acquiresleep>
      return b;
    80002c5e:	a889                	j	80002cb0 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c60:	0001b497          	auipc	s1,0x1b
    80002c64:	ec84b483          	ld	s1,-312(s1) # 8001db28 <bcache+0x82b0>
    80002c68:	0001b797          	auipc	a5,0x1b
    80002c6c:	e7878793          	addi	a5,a5,-392 # 8001dae0 <bcache+0x8268>
    80002c70:	00f48863          	beq	s1,a5,80002c80 <bread+0x84>
    80002c74:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002c76:	40bc                	lw	a5,64(s1)
    80002c78:	cb91                	beqz	a5,80002c8c <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002c7a:	64a4                	ld	s1,72(s1)
    80002c7c:	fee49de3          	bne	s1,a4,80002c76 <bread+0x7a>
  panic("bget: no buffers");
    80002c80:	00004517          	auipc	a0,0x4
    80002c84:	74050513          	addi	a0,a0,1856 # 800073c0 <etext+0x3c0>
    80002c88:	b69fd0ef          	jal	800007f0 <panic>
      b->dev = dev;
    80002c8c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c90:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c94:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c98:	4785                	li	a5,1
    80002c9a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c9c:	00013517          	auipc	a0,0x13
    80002ca0:	bdc50513          	addi	a0,a0,-1060 # 80015878 <bcache>
    80002ca4:	834fe0ef          	jal	80000cd8 <release>
      acquiresleep(&b->lock);
    80002ca8:	01048513          	addi	a0,s1,16
    80002cac:	374010ef          	jal	80004020 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002cb0:	409c                	lw	a5,0(s1)
    80002cb2:	cb89                	beqz	a5,80002cc4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002cb4:	8526                	mv	a0,s1
    80002cb6:	70a2                	ld	ra,40(sp)
    80002cb8:	7402                	ld	s0,32(sp)
    80002cba:	64e2                	ld	s1,24(sp)
    80002cbc:	6942                	ld	s2,16(sp)
    80002cbe:	69a2                	ld	s3,8(sp)
    80002cc0:	6145                	addi	sp,sp,48
    80002cc2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cc4:	4581                	li	a1,0
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	4a1020ef          	jal	80005968 <virtio_disk_rw>
    b->valid = 1;
    80002ccc:	4785                	li	a5,1
    80002cce:	c09c                	sw	a5,0(s1)
  return b;
    80002cd0:	b7d5                	j	80002cb4 <bread+0xb8>

0000000080002cd2 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002cd2:	1101                	addi	sp,sp,-32
    80002cd4:	ec06                	sd	ra,24(sp)
    80002cd6:	e822                	sd	s0,16(sp)
    80002cd8:	e426                	sd	s1,8(sp)
    80002cda:	1000                	addi	s0,sp,32
    80002cdc:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002cde:	0541                	addi	a0,a0,16
    80002ce0:	3cc010ef          	jal	800040ac <holdingsleep>
    80002ce4:	c911                	beqz	a0,80002cf8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ce6:	4585                	li	a1,1
    80002ce8:	8526                	mv	a0,s1
    80002cea:	47f020ef          	jal	80005968 <virtio_disk_rw>
}
    80002cee:	60e2                	ld	ra,24(sp)
    80002cf0:	6442                	ld	s0,16(sp)
    80002cf2:	64a2                	ld	s1,8(sp)
    80002cf4:	6105                	addi	sp,sp,32
    80002cf6:	8082                	ret
    panic("bwrite");
    80002cf8:	00004517          	auipc	a0,0x4
    80002cfc:	6e050513          	addi	a0,a0,1760 # 800073d8 <etext+0x3d8>
    80002d00:	af1fd0ef          	jal	800007f0 <panic>

0000000080002d04 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d04:	1101                	addi	sp,sp,-32
    80002d06:	ec06                	sd	ra,24(sp)
    80002d08:	e822                	sd	s0,16(sp)
    80002d0a:	e426                	sd	s1,8(sp)
    80002d0c:	e04a                	sd	s2,0(sp)
    80002d0e:	1000                	addi	s0,sp,32
    80002d10:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002d12:	01050913          	addi	s2,a0,16
    80002d16:	854a                	mv	a0,s2
    80002d18:	394010ef          	jal	800040ac <holdingsleep>
    80002d1c:	c135                	beqz	a0,80002d80 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002d1e:	854a                	mv	a0,s2
    80002d20:	354010ef          	jal	80004074 <releasesleep>

  acquire(&bcache.lock);
    80002d24:	00013517          	auipc	a0,0x13
    80002d28:	b5450513          	addi	a0,a0,-1196 # 80015878 <bcache>
    80002d2c:	f21fd0ef          	jal	80000c4c <acquire>
  b->refcnt--;
    80002d30:	40bc                	lw	a5,64(s1)
    80002d32:	37fd                	addiw	a5,a5,-1
    80002d34:	0007871b          	sext.w	a4,a5
    80002d38:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d3a:	e71d                	bnez	a4,80002d68 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d3c:	68b8                	ld	a4,80(s1)
    80002d3e:	64bc                	ld	a5,72(s1)
    80002d40:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d42:	68b8                	ld	a4,80(s1)
    80002d44:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d46:	0001b797          	auipc	a5,0x1b
    80002d4a:	b3278793          	addi	a5,a5,-1230 # 8001d878 <bcache+0x8000>
    80002d4e:	2b87b703          	ld	a4,696(a5)
    80002d52:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d54:	0001b717          	auipc	a4,0x1b
    80002d58:	d8c70713          	addi	a4,a4,-628 # 8001dae0 <bcache+0x8268>
    80002d5c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d5e:	2b87b703          	ld	a4,696(a5)
    80002d62:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d64:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002d68:	00013517          	auipc	a0,0x13
    80002d6c:	b1050513          	addi	a0,a0,-1264 # 80015878 <bcache>
    80002d70:	f69fd0ef          	jal	80000cd8 <release>
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	64a2                	ld	s1,8(sp)
    80002d7a:	6902                	ld	s2,0(sp)
    80002d7c:	6105                	addi	sp,sp,32
    80002d7e:	8082                	ret
    panic("brelse");
    80002d80:	00004517          	auipc	a0,0x4
    80002d84:	66050513          	addi	a0,a0,1632 # 800073e0 <etext+0x3e0>
    80002d88:	a69fd0ef          	jal	800007f0 <panic>

0000000080002d8c <bpin>:

void
bpin(struct buf *b)
{
    80002d8c:	1101                	addi	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	e426                	sd	s1,8(sp)
    80002d94:	1000                	addi	s0,sp,32
    80002d96:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d98:	00013517          	auipc	a0,0x13
    80002d9c:	ae050513          	addi	a0,a0,-1312 # 80015878 <bcache>
    80002da0:	eadfd0ef          	jal	80000c4c <acquire>
  b->refcnt++;
    80002da4:	40bc                	lw	a5,64(s1)
    80002da6:	2785                	addiw	a5,a5,1
    80002da8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002daa:	00013517          	auipc	a0,0x13
    80002dae:	ace50513          	addi	a0,a0,-1330 # 80015878 <bcache>
    80002db2:	f27fd0ef          	jal	80000cd8 <release>
}
    80002db6:	60e2                	ld	ra,24(sp)
    80002db8:	6442                	ld	s0,16(sp)
    80002dba:	64a2                	ld	s1,8(sp)
    80002dbc:	6105                	addi	sp,sp,32
    80002dbe:	8082                	ret

0000000080002dc0 <bunpin>:

void
bunpin(struct buf *b)
{
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	1000                	addi	s0,sp,32
    80002dca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dcc:	00013517          	auipc	a0,0x13
    80002dd0:	aac50513          	addi	a0,a0,-1364 # 80015878 <bcache>
    80002dd4:	e79fd0ef          	jal	80000c4c <acquire>
  b->refcnt--;
    80002dd8:	40bc                	lw	a5,64(s1)
    80002dda:	37fd                	addiw	a5,a5,-1
    80002ddc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dde:	00013517          	auipc	a0,0x13
    80002de2:	a9a50513          	addi	a0,a0,-1382 # 80015878 <bcache>
    80002de6:	ef3fd0ef          	jal	80000cd8 <release>
}
    80002dea:	60e2                	ld	ra,24(sp)
    80002dec:	6442                	ld	s0,16(sp)
    80002dee:	64a2                	ld	s1,8(sp)
    80002df0:	6105                	addi	sp,sp,32
    80002df2:	8082                	ret

0000000080002df4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002df4:	1101                	addi	sp,sp,-32
    80002df6:	ec06                	sd	ra,24(sp)
    80002df8:	e822                	sd	s0,16(sp)
    80002dfa:	e426                	sd	s1,8(sp)
    80002dfc:	e04a                	sd	s2,0(sp)
    80002dfe:	1000                	addi	s0,sp,32
    80002e00:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e02:	00d5d59b          	srliw	a1,a1,0xd
    80002e06:	0001b797          	auipc	a5,0x1b
    80002e0a:	14e7a783          	lw	a5,334(a5) # 8001df54 <sb+0x1c>
    80002e0e:	9dbd                	addw	a1,a1,a5
    80002e10:	dedff0ef          	jal	80002bfc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e14:	0074f713          	andi	a4,s1,7
    80002e18:	4785                	li	a5,1
    80002e1a:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80002e1e:	14ce                	slli	s1,s1,0x33
    80002e20:	90d9                	srli	s1,s1,0x36
    80002e22:	00950733          	add	a4,a0,s1
    80002e26:	05874703          	lbu	a4,88(a4)
    80002e2a:	00e7f6b3          	and	a3,a5,a4
    80002e2e:	c29d                	beqz	a3,80002e54 <bfree+0x60>
    80002e30:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002e32:	94aa                	add	s1,s1,a0
    80002e34:	fff7c793          	not	a5,a5
    80002e38:	8f7d                	and	a4,a4,a5
    80002e3a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e3e:	07a010ef          	jal	80003eb8 <log_write>
  brelse(bp);
    80002e42:	854a                	mv	a0,s2
    80002e44:	ec1ff0ef          	jal	80002d04 <brelse>
}
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6902                	ld	s2,0(sp)
    80002e50:	6105                	addi	sp,sp,32
    80002e52:	8082                	ret
    panic("freeing free block");
    80002e54:	00004517          	auipc	a0,0x4
    80002e58:	59450513          	addi	a0,a0,1428 # 800073e8 <etext+0x3e8>
    80002e5c:	995fd0ef          	jal	800007f0 <panic>

0000000080002e60 <balloc>:
{
    80002e60:	711d                	addi	sp,sp,-96
    80002e62:	ec86                	sd	ra,88(sp)
    80002e64:	e8a2                	sd	s0,80(sp)
    80002e66:	e4a6                	sd	s1,72(sp)
    80002e68:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB) {
    80002e6a:	0001b797          	auipc	a5,0x1b
    80002e6e:	0d27a783          	lw	a5,210(a5) # 8001df3c <sb+0x4>
    80002e72:	0e078f63          	beqz	a5,80002f70 <balloc+0x110>
    80002e76:	e0ca                	sd	s2,64(sp)
    80002e78:	fc4e                	sd	s3,56(sp)
    80002e7a:	f852                	sd	s4,48(sp)
    80002e7c:	f456                	sd	s5,40(sp)
    80002e7e:	f05a                	sd	s6,32(sp)
    80002e80:	ec5e                	sd	s7,24(sp)
    80002e82:	e862                	sd	s8,16(sp)
    80002e84:	e466                	sd	s9,8(sp)
    80002e86:	8baa                	mv	s7,a0
    80002e88:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e8a:	0001bb17          	auipc	s6,0x1b
    80002e8e:	0aeb0b13          	addi	s6,s6,174 # 8001df38 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e92:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e94:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e96:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002e98:	6c89                	lui	s9,0x2
    80002e9a:	a0b5                	j	80002f06 <balloc+0xa6>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002e9c:	97ca                	add	a5,a5,s2
    80002e9e:	8e55                	or	a2,a2,a3
    80002ea0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ea4:	854a                	mv	a0,s2
    80002ea6:	012010ef          	jal	80003eb8 <log_write>
        brelse(bp);
    80002eaa:	854a                	mv	a0,s2
    80002eac:	e59ff0ef          	jal	80002d04 <brelse>
  bp = bread(dev, bno);
    80002eb0:	85a6                	mv	a1,s1
    80002eb2:	855e                	mv	a0,s7
    80002eb4:	d49ff0ef          	jal	80002bfc <bread>
    80002eb8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002eba:	40000613          	li	a2,1024
    80002ebe:	4581                	li	a1,0
    80002ec0:	05850513          	addi	a0,a0,88
    80002ec4:	e4dfd0ef          	jal	80000d10 <memset>
  log_write(bp);
    80002ec8:	854a                	mv	a0,s2
    80002eca:	7ef000ef          	jal	80003eb8 <log_write>
  brelse(bp);
    80002ece:	854a                	mv	a0,s2
    80002ed0:	e35ff0ef          	jal	80002d04 <brelse>
}
    80002ed4:	6906                	ld	s2,64(sp)
    80002ed6:	79e2                	ld	s3,56(sp)
    80002ed8:	7a42                	ld	s4,48(sp)
    80002eda:	7aa2                	ld	s5,40(sp)
    80002edc:	7b02                	ld	s6,32(sp)
    80002ede:	6be2                	ld	s7,24(sp)
    80002ee0:	6c42                	ld	s8,16(sp)
    80002ee2:	6ca2                	ld	s9,8(sp)
}
    80002ee4:	8526                	mv	a0,s1
    80002ee6:	60e6                	ld	ra,88(sp)
    80002ee8:	6446                	ld	s0,80(sp)
    80002eea:	64a6                	ld	s1,72(sp)
    80002eec:	6125                	addi	sp,sp,96
    80002eee:	8082                	ret
    brelse(bp);
    80002ef0:	854a                	mv	a0,s2
    80002ef2:	e13ff0ef          	jal	80002d04 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002ef6:	015c87bb          	addw	a5,s9,s5
    80002efa:	00078a9b          	sext.w	s5,a5
    80002efe:	004b2703          	lw	a4,4(s6)
    80002f02:	04eaff63          	bgeu	s5,a4,80002f60 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002f06:	41fad79b          	sraiw	a5,s5,0x1f
    80002f0a:	0137d79b          	srliw	a5,a5,0x13
    80002f0e:	015787bb          	addw	a5,a5,s5
    80002f12:	40d7d79b          	sraiw	a5,a5,0xd
    80002f16:	01cb2583          	lw	a1,28(s6)
    80002f1a:	9dbd                	addw	a1,a1,a5
    80002f1c:	855e                	mv	a0,s7
    80002f1e:	cdfff0ef          	jal	80002bfc <bread>
    80002f22:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f24:	004b2503          	lw	a0,4(s6)
    80002f28:	000a849b          	sext.w	s1,s5
    80002f2c:	8762                	mv	a4,s8
    80002f2e:	fca4f1e3          	bgeu	s1,a0,80002ef0 <balloc+0x90>
      m = 1 << (bi % 8);
    80002f32:	00777693          	andi	a3,a4,7
    80002f36:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002f3a:	41f7579b          	sraiw	a5,a4,0x1f
    80002f3e:	01d7d79b          	srliw	a5,a5,0x1d
    80002f42:	9fb9                	addw	a5,a5,a4
    80002f44:	4037d79b          	sraiw	a5,a5,0x3
    80002f48:	00f90633          	add	a2,s2,a5
    80002f4c:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002f50:	00c6f5b3          	and	a1,a3,a2
    80002f54:	d5a1                	beqz	a1,80002e9c <balloc+0x3c>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f56:	2705                	addiw	a4,a4,1
    80002f58:	2485                	addiw	s1,s1,1
    80002f5a:	fd471ae3          	bne	a4,s4,80002f2e <balloc+0xce>
    80002f5e:	bf49                	j	80002ef0 <balloc+0x90>
    80002f60:	6906                	ld	s2,64(sp)
    80002f62:	79e2                	ld	s3,56(sp)
    80002f64:	7a42                	ld	s4,48(sp)
    80002f66:	7aa2                	ld	s5,40(sp)
    80002f68:	7b02                	ld	s6,32(sp)
    80002f6a:	6be2                	ld	s7,24(sp)
    80002f6c:	6c42                	ld	s8,16(sp)
    80002f6e:	6ca2                	ld	s9,8(sp)
  printk("balloc: out of blocks\n");
    80002f70:	00004517          	auipc	a0,0x4
    80002f74:	49050513          	addi	a0,a0,1168 # 80007400 <etext+0x400>
    80002f78:	d92fd0ef          	jal	8000050a <printk>
  return 0;
    80002f7c:	4481                	li	s1,0
    80002f7e:	b79d                	j	80002ee4 <balloc+0x84>

0000000080002f80 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f80:	7179                	addi	sp,sp,-48
    80002f82:	f406                	sd	ra,40(sp)
    80002f84:	f022                	sd	s0,32(sp)
    80002f86:	ec26                	sd	s1,24(sp)
    80002f88:	e84a                	sd	s2,16(sp)
    80002f8a:	e44e                	sd	s3,8(sp)
    80002f8c:	1800                	addi	s0,sp,48
    80002f8e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002f90:	47ad                	li	a5,11
    80002f92:	02b7e663          	bltu	a5,a1,80002fbe <bmap+0x3e>
    if ((addr = ip->addrs[bn]) == 0) {
    80002f96:	02059793          	slli	a5,a1,0x20
    80002f9a:	01e7d593          	srli	a1,a5,0x1e
    80002f9e:	00b504b3          	add	s1,a0,a1
    80002fa2:	0504a903          	lw	s2,80(s1)
    80002fa6:	06091a63          	bnez	s2,8000301a <bmap+0x9a>
      addr = balloc(ip->dev);
    80002faa:	4108                	lw	a0,0(a0)
    80002fac:	eb5ff0ef          	jal	80002e60 <balloc>
    80002fb0:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80002fb4:	06090363          	beqz	s2,8000301a <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002fb8:	0524a823          	sw	s2,80(s1)
    80002fbc:	a8b9                	j	8000301a <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002fbe:	ff45849b          	addiw	s1,a1,-12
    80002fc2:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT) {
    80002fc6:	0ff00793          	li	a5,255
    80002fca:	06e7ee63          	bltu	a5,a4,80003046 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002fce:	08052903          	lw	s2,128(a0)
    80002fd2:	00091d63          	bnez	s2,80002fec <bmap+0x6c>
      addr = balloc(ip->dev);
    80002fd6:	4108                	lw	a0,0(a0)
    80002fd8:	e89ff0ef          	jal	80002e60 <balloc>
    80002fdc:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80002fe0:	02090d63          	beqz	s2,8000301a <bmap+0x9a>
    80002fe4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fe6:	0929a023          	sw	s2,128(s3)
    80002fea:	a011                	j	80002fee <bmap+0x6e>
    80002fec:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fee:	85ca                	mv	a1,s2
    80002ff0:	0009a503          	lw	a0,0(s3)
    80002ff4:	c09ff0ef          	jal	80002bfc <bread>
    80002ff8:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002ffa:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002ffe:	02049713          	slli	a4,s1,0x20
    80003002:	01e75593          	srli	a1,a4,0x1e
    80003006:	00b784b3          	add	s1,a5,a1
    8000300a:	0004a903          	lw	s2,0(s1)
    8000300e:	00090e63          	beqz	s2,8000302a <bmap+0xaa>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003012:	8552                	mv	a0,s4
    80003014:	cf1ff0ef          	jal	80002d04 <brelse>
    return addr;
    80003018:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000301a:	854a                	mv	a0,s2
    8000301c:	70a2                	ld	ra,40(sp)
    8000301e:	7402                	ld	s0,32(sp)
    80003020:	64e2                	ld	s1,24(sp)
    80003022:	6942                	ld	s2,16(sp)
    80003024:	69a2                	ld	s3,8(sp)
    80003026:	6145                	addi	sp,sp,48
    80003028:	8082                	ret
      addr = balloc(ip->dev);
    8000302a:	0009a503          	lw	a0,0(s3)
    8000302e:	e33ff0ef          	jal	80002e60 <balloc>
    80003032:	0005091b          	sext.w	s2,a0
      if (addr) {
    80003036:	fc090ee3          	beqz	s2,80003012 <bmap+0x92>
        a[bn] = addr;
    8000303a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000303e:	8552                	mv	a0,s4
    80003040:	679000ef          	jal	80003eb8 <log_write>
    80003044:	b7f9                	j	80003012 <bmap+0x92>
    80003046:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003048:	00004517          	auipc	a0,0x4
    8000304c:	3d050513          	addi	a0,a0,976 # 80007418 <etext+0x418>
    80003050:	fa0fd0ef          	jal	800007f0 <panic>

0000000080003054 <iget>:
{
    80003054:	7179                	addi	sp,sp,-48
    80003056:	f406                	sd	ra,40(sp)
    80003058:	f022                	sd	s0,32(sp)
    8000305a:	ec26                	sd	s1,24(sp)
    8000305c:	e84a                	sd	s2,16(sp)
    8000305e:	e44e                	sd	s3,8(sp)
    80003060:	e052                	sd	s4,0(sp)
    80003062:	1800                	addi	s0,sp,48
    80003064:	89aa                	mv	s3,a0
    80003066:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003068:	0001b517          	auipc	a0,0x1b
    8000306c:	ef050513          	addi	a0,a0,-272 # 8001df58 <itable>
    80003070:	bddfd0ef          	jal	80000c4c <acquire>
  empty = 0;
    80003074:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003076:	0001b497          	auipc	s1,0x1b
    8000307a:	efa48493          	addi	s1,s1,-262 # 8001df70 <itable+0x18>
    8000307e:	0001d697          	auipc	a3,0x1d
    80003082:	98268693          	addi	a3,a3,-1662 # 8001fa00 <log>
    80003086:	a039                	j	80003094 <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003088:	02090963          	beqz	s2,800030ba <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000308c:	08848493          	addi	s1,s1,136
    80003090:	02d48863          	beq	s1,a3,800030c0 <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003094:	449c                	lw	a5,8(s1)
    80003096:	fef059e3          	blez	a5,80003088 <iget+0x34>
    8000309a:	4098                	lw	a4,0(s1)
    8000309c:	ff3716e3          	bne	a4,s3,80003088 <iget+0x34>
    800030a0:	40d8                	lw	a4,4(s1)
    800030a2:	ff4713e3          	bne	a4,s4,80003088 <iget+0x34>
      ip->ref++;
    800030a6:	2785                	addiw	a5,a5,1
    800030a8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800030aa:	0001b517          	auipc	a0,0x1b
    800030ae:	eae50513          	addi	a0,a0,-338 # 8001df58 <itable>
    800030b2:	c27fd0ef          	jal	80000cd8 <release>
      return ip;
    800030b6:	8926                	mv	s2,s1
    800030b8:	a02d                	j	800030e2 <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800030ba:	fbe9                	bnez	a5,8000308c <iget+0x38>
      empty = ip;
    800030bc:	8926                	mv	s2,s1
    800030be:	b7f9                	j	8000308c <iget+0x38>
  if (empty == 0)
    800030c0:	02090a63          	beqz	s2,800030f4 <iget+0xa0>
  ip->dev = dev;
    800030c4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800030c8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800030cc:	4785                	li	a5,1
    800030ce:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800030d2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800030d6:	0001b517          	auipc	a0,0x1b
    800030da:	e8250513          	addi	a0,a0,-382 # 8001df58 <itable>
    800030de:	bfbfd0ef          	jal	80000cd8 <release>
}
    800030e2:	854a                	mv	a0,s2
    800030e4:	70a2                	ld	ra,40(sp)
    800030e6:	7402                	ld	s0,32(sp)
    800030e8:	64e2                	ld	s1,24(sp)
    800030ea:	6942                	ld	s2,16(sp)
    800030ec:	69a2                	ld	s3,8(sp)
    800030ee:	6a02                	ld	s4,0(sp)
    800030f0:	6145                	addi	sp,sp,48
    800030f2:	8082                	ret
    panic("iget: no inodes");
    800030f4:	00004517          	auipc	a0,0x4
    800030f8:	33c50513          	addi	a0,a0,828 # 80007430 <etext+0x430>
    800030fc:	ef4fd0ef          	jal	800007f0 <panic>

0000000080003100 <iinit>:
{
    80003100:	7179                	addi	sp,sp,-48
    80003102:	f406                	sd	ra,40(sp)
    80003104:	f022                	sd	s0,32(sp)
    80003106:	ec26                	sd	s1,24(sp)
    80003108:	e84a                	sd	s2,16(sp)
    8000310a:	e44e                	sd	s3,8(sp)
    8000310c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000310e:	00004597          	auipc	a1,0x4
    80003112:	33258593          	addi	a1,a1,818 # 80007440 <etext+0x440>
    80003116:	0001b517          	auipc	a0,0x1b
    8000311a:	e4250513          	addi	a0,a0,-446 # 8001df58 <itable>
    8000311e:	ab9fd0ef          	jal	80000bd6 <initlock>
  for (i = 0; i < NINODE; i++) {
    80003122:	0001b497          	auipc	s1,0x1b
    80003126:	e5e48493          	addi	s1,s1,-418 # 8001df80 <itable+0x28>
    8000312a:	0001d997          	auipc	s3,0x1d
    8000312e:	8e698993          	addi	s3,s3,-1818 # 8001fa10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003132:	00004917          	auipc	s2,0x4
    80003136:	31690913          	addi	s2,s2,790 # 80007448 <etext+0x448>
    8000313a:	85ca                	mv	a1,s2
    8000313c:	8526                	mv	a0,s1
    8000313e:	6ad000ef          	jal	80003fea <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003142:	08848493          	addi	s1,s1,136
    80003146:	ff349ae3          	bne	s1,s3,8000313a <iinit+0x3a>
}
    8000314a:	70a2                	ld	ra,40(sp)
    8000314c:	7402                	ld	s0,32(sp)
    8000314e:	64e2                	ld	s1,24(sp)
    80003150:	6942                	ld	s2,16(sp)
    80003152:	69a2                	ld	s3,8(sp)
    80003154:	6145                	addi	sp,sp,48
    80003156:	8082                	ret

0000000080003158 <ialloc>:
{
    80003158:	7139                	addi	sp,sp,-64
    8000315a:	fc06                	sd	ra,56(sp)
    8000315c:	f822                	sd	s0,48(sp)
    8000315e:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003160:	0001b717          	auipc	a4,0x1b
    80003164:	de472703          	lw	a4,-540(a4) # 8001df44 <sb+0xc>
    80003168:	4785                	li	a5,1
    8000316a:	06e7f063          	bgeu	a5,a4,800031ca <ialloc+0x72>
    8000316e:	f426                	sd	s1,40(sp)
    80003170:	f04a                	sd	s2,32(sp)
    80003172:	ec4e                	sd	s3,24(sp)
    80003174:	e852                	sd	s4,16(sp)
    80003176:	e456                	sd	s5,8(sp)
    80003178:	e05a                	sd	s6,0(sp)
    8000317a:	8aaa                	mv	s5,a0
    8000317c:	8b2e                	mv	s6,a1
    8000317e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003180:	0001ba17          	auipc	s4,0x1b
    80003184:	db8a0a13          	addi	s4,s4,-584 # 8001df38 <sb>
    80003188:	00495593          	srli	a1,s2,0x4
    8000318c:	018a2783          	lw	a5,24(s4)
    80003190:	9dbd                	addw	a1,a1,a5
    80003192:	8556                	mv	a0,s5
    80003194:	a69ff0ef          	jal	80002bfc <bread>
    80003198:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    8000319a:	05850993          	addi	s3,a0,88
    8000319e:	00f97793          	andi	a5,s2,15
    800031a2:	079a                	slli	a5,a5,0x6
    800031a4:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800031a6:	00099783          	lh	a5,0(s3)
    800031aa:	cb9d                	beqz	a5,800031e0 <ialloc+0x88>
    brelse(bp);
    800031ac:	b59ff0ef          	jal	80002d04 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800031b0:	0905                	addi	s2,s2,1
    800031b2:	00ca2703          	lw	a4,12(s4)
    800031b6:	0009079b          	sext.w	a5,s2
    800031ba:	fce7e7e3          	bltu	a5,a4,80003188 <ialloc+0x30>
    800031be:	74a2                	ld	s1,40(sp)
    800031c0:	7902                	ld	s2,32(sp)
    800031c2:	69e2                	ld	s3,24(sp)
    800031c4:	6a42                	ld	s4,16(sp)
    800031c6:	6aa2                	ld	s5,8(sp)
    800031c8:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800031ca:	00004517          	auipc	a0,0x4
    800031ce:	28650513          	addi	a0,a0,646 # 80007450 <etext+0x450>
    800031d2:	b38fd0ef          	jal	8000050a <printk>
  return 0;
    800031d6:	4501                	li	a0,0
}
    800031d8:	70e2                	ld	ra,56(sp)
    800031da:	7442                	ld	s0,48(sp)
    800031dc:	6121                	addi	sp,sp,64
    800031de:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031e0:	04000613          	li	a2,64
    800031e4:	4581                	li	a1,0
    800031e6:	854e                	mv	a0,s3
    800031e8:	b29fd0ef          	jal	80000d10 <memset>
      dip->type = type;
    800031ec:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800031f0:	8526                	mv	a0,s1
    800031f2:	4c7000ef          	jal	80003eb8 <log_write>
      brelse(bp);
    800031f6:	8526                	mv	a0,s1
    800031f8:	b0dff0ef          	jal	80002d04 <brelse>
      return iget(dev, inum);
    800031fc:	0009059b          	sext.w	a1,s2
    80003200:	8556                	mv	a0,s5
    80003202:	e53ff0ef          	jal	80003054 <iget>
    80003206:	74a2                	ld	s1,40(sp)
    80003208:	7902                	ld	s2,32(sp)
    8000320a:	69e2                	ld	s3,24(sp)
    8000320c:	6a42                	ld	s4,16(sp)
    8000320e:	6aa2                	ld	s5,8(sp)
    80003210:	6b02                	ld	s6,0(sp)
    80003212:	b7d9                	j	800031d8 <ialloc+0x80>

0000000080003214 <iupdate>:
{
    80003214:	1101                	addi	sp,sp,-32
    80003216:	ec06                	sd	ra,24(sp)
    80003218:	e822                	sd	s0,16(sp)
    8000321a:	e426                	sd	s1,8(sp)
    8000321c:	e04a                	sd	s2,0(sp)
    8000321e:	1000                	addi	s0,sp,32
    80003220:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003222:	415c                	lw	a5,4(a0)
    80003224:	0047d79b          	srliw	a5,a5,0x4
    80003228:	0001b597          	auipc	a1,0x1b
    8000322c:	d285a583          	lw	a1,-728(a1) # 8001df50 <sb+0x18>
    80003230:	9dbd                	addw	a1,a1,a5
    80003232:	4108                	lw	a0,0(a0)
    80003234:	9c9ff0ef          	jal	80002bfc <bread>
    80003238:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000323a:	05850793          	addi	a5,a0,88
    8000323e:	40d8                	lw	a4,4(s1)
    80003240:	8b3d                	andi	a4,a4,15
    80003242:	071a                	slli	a4,a4,0x6
    80003244:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003246:	04449703          	lh	a4,68(s1)
    8000324a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000324e:	04649703          	lh	a4,70(s1)
    80003252:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003256:	04849703          	lh	a4,72(s1)
    8000325a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000325e:	04a49703          	lh	a4,74(s1)
    80003262:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003266:	44f8                	lw	a4,76(s1)
    80003268:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000326a:	03400613          	li	a2,52
    8000326e:	05048593          	addi	a1,s1,80
    80003272:	00c78513          	addi	a0,a5,12
    80003276:	af7fd0ef          	jal	80000d6c <memmove>
  log_write(bp);
    8000327a:	854a                	mv	a0,s2
    8000327c:	43d000ef          	jal	80003eb8 <log_write>
  brelse(bp);
    80003280:	854a                	mv	a0,s2
    80003282:	a83ff0ef          	jal	80002d04 <brelse>
}
    80003286:	60e2                	ld	ra,24(sp)
    80003288:	6442                	ld	s0,16(sp)
    8000328a:	64a2                	ld	s1,8(sp)
    8000328c:	6902                	ld	s2,0(sp)
    8000328e:	6105                	addi	sp,sp,32
    80003290:	8082                	ret

0000000080003292 <idup>:
{
    80003292:	1101                	addi	sp,sp,-32
    80003294:	ec06                	sd	ra,24(sp)
    80003296:	e822                	sd	s0,16(sp)
    80003298:	e426                	sd	s1,8(sp)
    8000329a:	1000                	addi	s0,sp,32
    8000329c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000329e:	0001b517          	auipc	a0,0x1b
    800032a2:	cba50513          	addi	a0,a0,-838 # 8001df58 <itable>
    800032a6:	9a7fd0ef          	jal	80000c4c <acquire>
  ip->ref++;
    800032aa:	449c                	lw	a5,8(s1)
    800032ac:	2785                	addiw	a5,a5,1
    800032ae:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032b0:	0001b517          	auipc	a0,0x1b
    800032b4:	ca850513          	addi	a0,a0,-856 # 8001df58 <itable>
    800032b8:	a21fd0ef          	jal	80000cd8 <release>
}
    800032bc:	8526                	mv	a0,s1
    800032be:	60e2                	ld	ra,24(sp)
    800032c0:	6442                	ld	s0,16(sp)
    800032c2:	64a2                	ld	s1,8(sp)
    800032c4:	6105                	addi	sp,sp,32
    800032c6:	8082                	ret

00000000800032c8 <ilock>:
{
    800032c8:	1101                	addi	sp,sp,-32
    800032ca:	ec06                	sd	ra,24(sp)
    800032cc:	e822                	sd	s0,16(sp)
    800032ce:	e426                	sd	s1,8(sp)
    800032d0:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800032d2:	cd19                	beqz	a0,800032f0 <ilock+0x28>
    800032d4:	84aa                	mv	s1,a0
    800032d6:	451c                	lw	a5,8(a0)
    800032d8:	00f05c63          	blez	a5,800032f0 <ilock+0x28>
  acquiresleep(&ip->lock);
    800032dc:	0541                	addi	a0,a0,16
    800032de:	543000ef          	jal	80004020 <acquiresleep>
  if (ip->valid == 0) {
    800032e2:	40bc                	lw	a5,64(s1)
    800032e4:	cf89                	beqz	a5,800032fe <ilock+0x36>
}
    800032e6:	60e2                	ld	ra,24(sp)
    800032e8:	6442                	ld	s0,16(sp)
    800032ea:	64a2                	ld	s1,8(sp)
    800032ec:	6105                	addi	sp,sp,32
    800032ee:	8082                	ret
    800032f0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032f2:	00004517          	auipc	a0,0x4
    800032f6:	17650513          	addi	a0,a0,374 # 80007468 <etext+0x468>
    800032fa:	cf6fd0ef          	jal	800007f0 <panic>
    800032fe:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003300:	40dc                	lw	a5,4(s1)
    80003302:	0047d79b          	srliw	a5,a5,0x4
    80003306:	0001b597          	auipc	a1,0x1b
    8000330a:	c4a5a583          	lw	a1,-950(a1) # 8001df50 <sb+0x18>
    8000330e:	9dbd                	addw	a1,a1,a5
    80003310:	4088                	lw	a0,0(s1)
    80003312:	8ebff0ef          	jal	80002bfc <bread>
    80003316:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003318:	05850593          	addi	a1,a0,88
    8000331c:	40dc                	lw	a5,4(s1)
    8000331e:	8bbd                	andi	a5,a5,15
    80003320:	079a                	slli	a5,a5,0x6
    80003322:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003324:	00059783          	lh	a5,0(a1)
    80003328:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000332c:	00259783          	lh	a5,2(a1)
    80003330:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003334:	00459783          	lh	a5,4(a1)
    80003338:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000333c:	00659783          	lh	a5,6(a1)
    80003340:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003344:	459c                	lw	a5,8(a1)
    80003346:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003348:	03400613          	li	a2,52
    8000334c:	05b1                	addi	a1,a1,12
    8000334e:	05048513          	addi	a0,s1,80
    80003352:	a1bfd0ef          	jal	80000d6c <memmove>
    brelse(bp);
    80003356:	854a                	mv	a0,s2
    80003358:	9adff0ef          	jal	80002d04 <brelse>
    ip->valid = 1;
    8000335c:	4785                	li	a5,1
    8000335e:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003360:	04449783          	lh	a5,68(s1)
    80003364:	c399                	beqz	a5,8000336a <ilock+0xa2>
    80003366:	6902                	ld	s2,0(sp)
    80003368:	bfbd                	j	800032e6 <ilock+0x1e>
      panic("ilock: no type");
    8000336a:	00004517          	auipc	a0,0x4
    8000336e:	10650513          	addi	a0,a0,262 # 80007470 <etext+0x470>
    80003372:	c7efd0ef          	jal	800007f0 <panic>

0000000080003376 <iunlock>:
{
    80003376:	1101                	addi	sp,sp,-32
    80003378:	ec06                	sd	ra,24(sp)
    8000337a:	e822                	sd	s0,16(sp)
    8000337c:	e426                	sd	s1,8(sp)
    8000337e:	e04a                	sd	s2,0(sp)
    80003380:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003382:	c505                	beqz	a0,800033aa <iunlock+0x34>
    80003384:	84aa                	mv	s1,a0
    80003386:	01050913          	addi	s2,a0,16
    8000338a:	854a                	mv	a0,s2
    8000338c:	521000ef          	jal	800040ac <holdingsleep>
    80003390:	cd09                	beqz	a0,800033aa <iunlock+0x34>
    80003392:	449c                	lw	a5,8(s1)
    80003394:	00f05b63          	blez	a5,800033aa <iunlock+0x34>
  releasesleep(&ip->lock);
    80003398:	854a                	mv	a0,s2
    8000339a:	4db000ef          	jal	80004074 <releasesleep>
}
    8000339e:	60e2                	ld	ra,24(sp)
    800033a0:	6442                	ld	s0,16(sp)
    800033a2:	64a2                	ld	s1,8(sp)
    800033a4:	6902                	ld	s2,0(sp)
    800033a6:	6105                	addi	sp,sp,32
    800033a8:	8082                	ret
    panic("iunlock");
    800033aa:	00004517          	auipc	a0,0x4
    800033ae:	0d650513          	addi	a0,a0,214 # 80007480 <etext+0x480>
    800033b2:	c3efd0ef          	jal	800007f0 <panic>

00000000800033b6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033b6:	7179                	addi	sp,sp,-48
    800033b8:	f406                	sd	ra,40(sp)
    800033ba:	f022                	sd	s0,32(sp)
    800033bc:	ec26                	sd	s1,24(sp)
    800033be:	e84a                	sd	s2,16(sp)
    800033c0:	e44e                	sd	s3,8(sp)
    800033c2:	1800                	addi	s0,sp,48
    800033c4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800033c6:	05050493          	addi	s1,a0,80
    800033ca:	08050913          	addi	s2,a0,128
    800033ce:	a021                	j	800033d6 <itrunc+0x20>
    800033d0:	0491                	addi	s1,s1,4
    800033d2:	01248b63          	beq	s1,s2,800033e8 <itrunc+0x32>
    if (ip->addrs[i]) {
    800033d6:	408c                	lw	a1,0(s1)
    800033d8:	dde5                	beqz	a1,800033d0 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033da:	0009a503          	lw	a0,0(s3)
    800033de:	a17ff0ef          	jal	80002df4 <bfree>
      ip->addrs[i] = 0;
    800033e2:	0004a023          	sw	zero,0(s1)
    800033e6:	b7ed                	j	800033d0 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800033e8:	0809a583          	lw	a1,128(s3)
    800033ec:	ed89                	bnez	a1,80003406 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033ee:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033f2:	854e                	mv	a0,s3
    800033f4:	e21ff0ef          	jal	80003214 <iupdate>
}
    800033f8:	70a2                	ld	ra,40(sp)
    800033fa:	7402                	ld	s0,32(sp)
    800033fc:	64e2                	ld	s1,24(sp)
    800033fe:	6942                	ld	s2,16(sp)
    80003400:	69a2                	ld	s3,8(sp)
    80003402:	6145                	addi	sp,sp,48
    80003404:	8082                	ret
    80003406:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003408:	0009a503          	lw	a0,0(s3)
    8000340c:	ff0ff0ef          	jal	80002bfc <bread>
    80003410:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003412:	05850493          	addi	s1,a0,88
    80003416:	45850913          	addi	s2,a0,1112
    8000341a:	a021                	j	80003422 <itrunc+0x6c>
    8000341c:	0491                	addi	s1,s1,4
    8000341e:	01248963          	beq	s1,s2,80003430 <itrunc+0x7a>
      if (a[j])
    80003422:	408c                	lw	a1,0(s1)
    80003424:	dde5                	beqz	a1,8000341c <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003426:	0009a503          	lw	a0,0(s3)
    8000342a:	9cbff0ef          	jal	80002df4 <bfree>
    8000342e:	b7fd                	j	8000341c <itrunc+0x66>
    brelse(bp);
    80003430:	8552                	mv	a0,s4
    80003432:	8d3ff0ef          	jal	80002d04 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003436:	0809a583          	lw	a1,128(s3)
    8000343a:	0009a503          	lw	a0,0(s3)
    8000343e:	9b7ff0ef          	jal	80002df4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003442:	0809a023          	sw	zero,128(s3)
    80003446:	6a02                	ld	s4,0(sp)
    80003448:	b75d                	j	800033ee <itrunc+0x38>

000000008000344a <iput>:
{
    8000344a:	7179                	addi	sp,sp,-48
    8000344c:	f406                	sd	ra,40(sp)
    8000344e:	f022                	sd	s0,32(sp)
    80003450:	ec26                	sd	s1,24(sp)
    80003452:	1800                	addi	s0,sp,48
    80003454:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003456:	0001b517          	auipc	a0,0x1b
    8000345a:	b0250513          	addi	a0,a0,-1278 # 8001df58 <itable>
    8000345e:	feefd0ef          	jal	80000c4c <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003462:	449c                	lw	a5,8(s1)
    80003464:	4705                	li	a4,1
    80003466:	00e78f63          	beq	a5,a4,80003484 <iput+0x3a>
  ip->ref--;
    8000346a:	37fd                	addiw	a5,a5,-1
    8000346c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000346e:	0001b517          	auipc	a0,0x1b
    80003472:	aea50513          	addi	a0,a0,-1302 # 8001df58 <itable>
    80003476:	863fd0ef          	jal	80000cd8 <release>
}
    8000347a:	70a2                	ld	ra,40(sp)
    8000347c:	7402                	ld	s0,32(sp)
    8000347e:	64e2                	ld	s1,24(sp)
    80003480:	6145                	addi	sp,sp,48
    80003482:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003484:	40b8                	lw	a4,64(s1)
    80003486:	d375                	beqz	a4,8000346a <iput+0x20>
    80003488:	e84a                	sd	s2,16(sp)
    8000348a:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    8000348c:	0004aa03          	lw	s4,0(s1)
    80003490:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003494:	04a49703          	lh	a4,74(s1)
    80003498:	ef35                	bnez	a4,80003514 <iput+0xca>
    8000349a:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    8000349c:	01048993          	addi	s3,s1,16
    800034a0:	854e                	mv	a0,s3
    800034a2:	37f000ef          	jal	80004020 <acquiresleep>
    release(&itable.lock);
    800034a6:	0001b517          	auipc	a0,0x1b
    800034aa:	ab250513          	addi	a0,a0,-1358 # 8001df58 <itable>
    800034ae:	82bfd0ef          	jal	80000cd8 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800034b2:	8526                	mv	a0,s1
    800034b4:	f03ff0ef          	jal	800033b6 <itrunc>
    ip->valid = 0;
    800034b8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034bc:	854e                	mv	a0,s3
    800034be:	3b7000ef          	jal	80004074 <releasesleep>
    acquire(&itable.lock);
    800034c2:	0001b517          	auipc	a0,0x1b
    800034c6:	a9650513          	addi	a0,a0,-1386 # 8001df58 <itable>
    800034ca:	f82fd0ef          	jal	80000c4c <acquire>
  ip->ref--;
    800034ce:	449c                	lw	a5,8(s1)
    800034d0:	37fd                	addiw	a5,a5,-1
    800034d2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034d4:	0001b517          	auipc	a0,0x1b
    800034d8:	a8450513          	addi	a0,a0,-1404 # 8001df58 <itable>
    800034dc:	ffcfd0ef          	jal	80000cd8 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034e0:	0049559b          	srliw	a1,s2,0x4
    800034e4:	0001b797          	auipc	a5,0x1b
    800034e8:	a6c7a783          	lw	a5,-1428(a5) # 8001df50 <sb+0x18>
    800034ec:	9dbd                	addw	a1,a1,a5
    800034ee:	8552                	mv	a0,s4
    800034f0:	f0cff0ef          	jal	80002bfc <bread>
    800034f4:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034f6:	00f97913          	andi	s2,s2,15
  dip->type = 0;
    800034fa:	091a                	slli	s2,s2,0x6
    800034fc:	992a                	add	s2,s2,a0
    800034fe:	04091c23          	sh	zero,88(s2)
  log_write(bp);
    80003502:	1b7000ef          	jal	80003eb8 <log_write>
  brelse(bp);
    80003506:	8526                	mv	a0,s1
    80003508:	ffcff0ef          	jal	80002d04 <brelse>
}
    8000350c:	6942                	ld	s2,16(sp)
    8000350e:	69a2                	ld	s3,8(sp)
    80003510:	6a02                	ld	s4,0(sp)
    80003512:	b7a5                	j	8000347a <iput+0x30>
    80003514:	6942                	ld	s2,16(sp)
    80003516:	6a02                	ld	s4,0(sp)
    80003518:	bf89                	j	8000346a <iput+0x20>

000000008000351a <iunlockput>:
{
    8000351a:	1101                	addi	sp,sp,-32
    8000351c:	ec06                	sd	ra,24(sp)
    8000351e:	e822                	sd	s0,16(sp)
    80003520:	e426                	sd	s1,8(sp)
    80003522:	1000                	addi	s0,sp,32
    80003524:	84aa                	mv	s1,a0
  iunlock(ip);
    80003526:	e51ff0ef          	jal	80003376 <iunlock>
  iput(ip);
    8000352a:	8526                	mv	a0,s1
    8000352c:	f1fff0ef          	jal	8000344a <iput>
}
    80003530:	60e2                	ld	ra,24(sp)
    80003532:	6442                	ld	s0,16(sp)
    80003534:	64a2                	ld	s1,8(sp)
    80003536:	6105                	addi	sp,sp,32
    80003538:	8082                	ret

000000008000353a <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000353a:	0001b717          	auipc	a4,0x1b
    8000353e:	a0a72703          	lw	a4,-1526(a4) # 8001df44 <sb+0xc>
    80003542:	4785                	li	a5,1
    80003544:	0ae7ff63          	bgeu	a5,a4,80003602 <ireclaim+0xc8>
{
    80003548:	7139                	addi	sp,sp,-64
    8000354a:	fc06                	sd	ra,56(sp)
    8000354c:	f822                	sd	s0,48(sp)
    8000354e:	f426                	sd	s1,40(sp)
    80003550:	f04a                	sd	s2,32(sp)
    80003552:	ec4e                	sd	s3,24(sp)
    80003554:	e852                	sd	s4,16(sp)
    80003556:	e456                	sd	s5,8(sp)
    80003558:	e05a                	sd	s6,0(sp)
    8000355a:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000355c:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000355e:	00050a1b          	sext.w	s4,a0
    80003562:	0001ba97          	auipc	s5,0x1b
    80003566:	9d6a8a93          	addi	s5,s5,-1578 # 8001df38 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000356a:	00004b17          	auipc	s6,0x4
    8000356e:	f1eb0b13          	addi	s6,s6,-226 # 80007488 <etext+0x488>
    80003572:	a099                	j	800035b8 <ireclaim+0x7e>
    80003574:	85ce                	mv	a1,s3
    80003576:	855a                	mv	a0,s6
    80003578:	f93fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    8000357c:	85ce                	mv	a1,s3
    8000357e:	8552                	mv	a0,s4
    80003580:	ad5ff0ef          	jal	80003054 <iget>
    80003584:	89aa                	mv	s3,a0
    brelse(bp);
    80003586:	854a                	mv	a0,s2
    80003588:	f7cff0ef          	jal	80002d04 <brelse>
    if (ip) {
    8000358c:	00098f63          	beqz	s3,800035aa <ireclaim+0x70>
      begin_op();
    80003590:	782000ef          	jal	80003d12 <begin_op>
      ilock(ip);
    80003594:	854e                	mv	a0,s3
    80003596:	d33ff0ef          	jal	800032c8 <ilock>
      iunlock(ip);
    8000359a:	854e                	mv	a0,s3
    8000359c:	ddbff0ef          	jal	80003376 <iunlock>
      iput(ip);
    800035a0:	854e                	mv	a0,s3
    800035a2:	ea9ff0ef          	jal	8000344a <iput>
      end_op();
    800035a6:	7f2000ef          	jal	80003d98 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035aa:	0485                	addi	s1,s1,1
    800035ac:	00caa703          	lw	a4,12(s5)
    800035b0:	0004879b          	sext.w	a5,s1
    800035b4:	02e7fd63          	bgeu	a5,a4,800035ee <ireclaim+0xb4>
    800035b8:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035bc:	0044d593          	srli	a1,s1,0x4
    800035c0:	018aa783          	lw	a5,24(s5)
    800035c4:	9dbd                	addw	a1,a1,a5
    800035c6:	8552                	mv	a0,s4
    800035c8:	e34ff0ef          	jal	80002bfc <bread>
    800035cc:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035ce:	05850793          	addi	a5,a0,88
    800035d2:	00f9f713          	andi	a4,s3,15
    800035d6:	071a                	slli	a4,a4,0x6
    800035d8:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    800035da:	00079703          	lh	a4,0(a5)
    800035de:	c701                	beqz	a4,800035e6 <ireclaim+0xac>
    800035e0:	00679783          	lh	a5,6(a5)
    800035e4:	dbc1                	beqz	a5,80003574 <ireclaim+0x3a>
    brelse(bp);
    800035e6:	854a                	mv	a0,s2
    800035e8:	f1cff0ef          	jal	80002d04 <brelse>
    if (ip) {
    800035ec:	bf7d                	j	800035aa <ireclaim+0x70>
}
    800035ee:	70e2                	ld	ra,56(sp)
    800035f0:	7442                	ld	s0,48(sp)
    800035f2:	74a2                	ld	s1,40(sp)
    800035f4:	7902                	ld	s2,32(sp)
    800035f6:	69e2                	ld	s3,24(sp)
    800035f8:	6a42                	ld	s4,16(sp)
    800035fa:	6aa2                	ld	s5,8(sp)
    800035fc:	6b02                	ld	s6,0(sp)
    800035fe:	6121                	addi	sp,sp,64
    80003600:	8082                	ret
    80003602:	8082                	ret

0000000080003604 <fsinit>:
{
    80003604:	7179                	addi	sp,sp,-48
    80003606:	f406                	sd	ra,40(sp)
    80003608:	f022                	sd	s0,32(sp)
    8000360a:	ec26                	sd	s1,24(sp)
    8000360c:	e84a                	sd	s2,16(sp)
    8000360e:	e44e                	sd	s3,8(sp)
    80003610:	1800                	addi	s0,sp,48
    80003612:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003614:	4585                	li	a1,1
    80003616:	de6ff0ef          	jal	80002bfc <bread>
    8000361a:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000361c:	0001b997          	auipc	s3,0x1b
    80003620:	91c98993          	addi	s3,s3,-1764 # 8001df38 <sb>
    80003624:	02000613          	li	a2,32
    80003628:	05850593          	addi	a1,a0,88
    8000362c:	854e                	mv	a0,s3
    8000362e:	f3efd0ef          	jal	80000d6c <memmove>
  brelse(bp);
    80003632:	854a                	mv	a0,s2
    80003634:	ed0ff0ef          	jal	80002d04 <brelse>
  if (sb.magic != FSMAGIC)
    80003638:	0009a703          	lw	a4,0(s3)
    8000363c:	102037b7          	lui	a5,0x10203
    80003640:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003644:	02f71363          	bne	a4,a5,8000366a <fsinit+0x66>
  initlog(dev, &sb);
    80003648:	0001b597          	auipc	a1,0x1b
    8000364c:	8f058593          	addi	a1,a1,-1808 # 8001df38 <sb>
    80003650:	8526                	mv	a0,s1
    80003652:	642000ef          	jal	80003c94 <initlog>
  ireclaim(dev);
    80003656:	8526                	mv	a0,s1
    80003658:	ee3ff0ef          	jal	8000353a <ireclaim>
}
    8000365c:	70a2                	ld	ra,40(sp)
    8000365e:	7402                	ld	s0,32(sp)
    80003660:	64e2                	ld	s1,24(sp)
    80003662:	6942                	ld	s2,16(sp)
    80003664:	69a2                	ld	s3,8(sp)
    80003666:	6145                	addi	sp,sp,48
    80003668:	8082                	ret
    panic("invalid file system");
    8000366a:	00004517          	auipc	a0,0x4
    8000366e:	e3e50513          	addi	a0,a0,-450 # 800074a8 <etext+0x4a8>
    80003672:	97efd0ef          	jal	800007f0 <panic>

0000000080003676 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003676:	1141                	addi	sp,sp,-16
    80003678:	e422                	sd	s0,8(sp)
    8000367a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000367c:	411c                	lw	a5,0(a0)
    8000367e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003680:	415c                	lw	a5,4(a0)
    80003682:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003684:	04451783          	lh	a5,68(a0)
    80003688:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000368c:	04a51783          	lh	a5,74(a0)
    80003690:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003694:	04c56783          	lwu	a5,76(a0)
    80003698:	e99c                	sd	a5,16(a1)
}
    8000369a:	6422                	ld	s0,8(sp)
    8000369c:	0141                	addi	sp,sp,16
    8000369e:	8082                	ret

00000000800036a0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800036a0:	457c                	lw	a5,76(a0)
    800036a2:	0ed7eb63          	bltu	a5,a3,80003798 <readi+0xf8>
{
    800036a6:	7159                	addi	sp,sp,-112
    800036a8:	f486                	sd	ra,104(sp)
    800036aa:	f0a2                	sd	s0,96(sp)
    800036ac:	eca6                	sd	s1,88(sp)
    800036ae:	e0d2                	sd	s4,64(sp)
    800036b0:	fc56                	sd	s5,56(sp)
    800036b2:	f85a                	sd	s6,48(sp)
    800036b4:	f45e                	sd	s7,40(sp)
    800036b6:	1880                	addi	s0,sp,112
    800036b8:	8b2a                	mv	s6,a0
    800036ba:	8bae                	mv	s7,a1
    800036bc:	8a32                	mv	s4,a2
    800036be:	84b6                	mv	s1,a3
    800036c0:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800036c2:	9f35                	addw	a4,a4,a3
    return 0;
    800036c4:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800036c6:	0cd76063          	bltu	a4,a3,80003786 <readi+0xe6>
    800036ca:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    800036cc:	00e7f463          	bgeu	a5,a4,800036d4 <readi+0x34>
    n = ip->size - off;
    800036d0:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036d4:	080a8f63          	beqz	s5,80003772 <readi+0xd2>
    800036d8:	e8ca                	sd	s2,80(sp)
    800036da:	f062                	sd	s8,32(sp)
    800036dc:	ec66                	sd	s9,24(sp)
    800036de:	e86a                	sd	s10,16(sp)
    800036e0:	e46e                	sd	s11,8(sp)
    800036e2:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800036e4:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036e8:	5c7d                	li	s8,-1
    800036ea:	a80d                	j	8000371c <readi+0x7c>
    800036ec:	020d1d93          	slli	s11,s10,0x20
    800036f0:	020ddd93          	srli	s11,s11,0x20
    800036f4:	05890613          	addi	a2,s2,88
    800036f8:	86ee                	mv	a3,s11
    800036fa:	963a                	add	a2,a2,a4
    800036fc:	85d2                	mv	a1,s4
    800036fe:	855e                	mv	a0,s7
    80003700:	c11fe0ef          	jal	80002310 <either_copyout>
    80003704:	05850763          	beq	a0,s8,80003752 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003708:	854a                	mv	a0,s2
    8000370a:	dfaff0ef          	jal	80002d04 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000370e:	013d09bb          	addw	s3,s10,s3
    80003712:	009d04bb          	addw	s1,s10,s1
    80003716:	9a6e                	add	s4,s4,s11
    80003718:	0559f763          	bgeu	s3,s5,80003766 <readi+0xc6>
    uint addr = bmap(ip, off / BSIZE);
    8000371c:	00a4d59b          	srliw	a1,s1,0xa
    80003720:	855a                	mv	a0,s6
    80003722:	85fff0ef          	jal	80002f80 <bmap>
    80003726:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    8000372a:	c5b1                	beqz	a1,80003776 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000372c:	000b2503          	lw	a0,0(s6)
    80003730:	cccff0ef          	jal	80002bfc <bread>
    80003734:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003736:	3ff4f713          	andi	a4,s1,1023
    8000373a:	40ec87bb          	subw	a5,s9,a4
    8000373e:	413a86bb          	subw	a3,s5,s3
    80003742:	8d3e                	mv	s10,a5
    80003744:	2781                	sext.w	a5,a5
    80003746:	0006861b          	sext.w	a2,a3
    8000374a:	faf671e3          	bgeu	a2,a5,800036ec <readi+0x4c>
    8000374e:	8d36                	mv	s10,a3
    80003750:	bf71                	j	800036ec <readi+0x4c>
      brelse(bp);
    80003752:	854a                	mv	a0,s2
    80003754:	db0ff0ef          	jal	80002d04 <brelse>
      tot = -1;
    80003758:	59fd                	li	s3,-1
      break;
    8000375a:	6946                	ld	s2,80(sp)
    8000375c:	7c02                	ld	s8,32(sp)
    8000375e:	6ce2                	ld	s9,24(sp)
    80003760:	6d42                	ld	s10,16(sp)
    80003762:	6da2                	ld	s11,8(sp)
    80003764:	a831                	j	80003780 <readi+0xe0>
    80003766:	6946                	ld	s2,80(sp)
    80003768:	7c02                	ld	s8,32(sp)
    8000376a:	6ce2                	ld	s9,24(sp)
    8000376c:	6d42                	ld	s10,16(sp)
    8000376e:	6da2                	ld	s11,8(sp)
    80003770:	a801                	j	80003780 <readi+0xe0>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003772:	89d6                	mv	s3,s5
    80003774:	a031                	j	80003780 <readi+0xe0>
    80003776:	6946                	ld	s2,80(sp)
    80003778:	7c02                	ld	s8,32(sp)
    8000377a:	6ce2                	ld	s9,24(sp)
    8000377c:	6d42                	ld	s10,16(sp)
    8000377e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003780:	0009851b          	sext.w	a0,s3
    80003784:	69a6                	ld	s3,72(sp)
}
    80003786:	70a6                	ld	ra,104(sp)
    80003788:	7406                	ld	s0,96(sp)
    8000378a:	64e6                	ld	s1,88(sp)
    8000378c:	6a06                	ld	s4,64(sp)
    8000378e:	7ae2                	ld	s5,56(sp)
    80003790:	7b42                	ld	s6,48(sp)
    80003792:	7ba2                	ld	s7,40(sp)
    80003794:	6165                	addi	sp,sp,112
    80003796:	8082                	ret
    return 0;
    80003798:	4501                	li	a0,0
}
    8000379a:	8082                	ret

000000008000379c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    8000379c:	457c                	lw	a5,76(a0)
    8000379e:	10d7e363          	bltu	a5,a3,800038a4 <writei+0x108>
{
    800037a2:	7159                	addi	sp,sp,-112
    800037a4:	f486                	sd	ra,104(sp)
    800037a6:	f0a2                	sd	s0,96(sp)
    800037a8:	e8ca                	sd	s2,80(sp)
    800037aa:	e0d2                	sd	s4,64(sp)
    800037ac:	fc56                	sd	s5,56(sp)
    800037ae:	f85a                	sd	s6,48(sp)
    800037b0:	f45e                	sd	s7,40(sp)
    800037b2:	1880                	addi	s0,sp,112
    800037b4:	8aaa                	mv	s5,a0
    800037b6:	8bae                	mv	s7,a1
    800037b8:	8a32                	mv	s4,a2
    800037ba:	8936                	mv	s2,a3
    800037bc:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800037be:	00e687bb          	addw	a5,a3,a4
    800037c2:	0ed7e363          	bltu	a5,a3,800038a8 <writei+0x10c>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800037c6:	00043737          	lui	a4,0x43
    800037ca:	0ef76163          	bltu	a4,a5,800038ac <writei+0x110>
    800037ce:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037d0:	0c0b0263          	beqz	s6,80003894 <writei+0xf8>
    800037d4:	eca6                	sd	s1,88(sp)
    800037d6:	f062                	sd	s8,32(sp)
    800037d8:	ec66                	sd	s9,24(sp)
    800037da:	e86a                	sd	s10,16(sp)
    800037dc:	e46e                	sd	s11,8(sp)
    800037de:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800037e0:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800037e4:	5c7d                	li	s8,-1
    800037e6:	a825                	j	8000381e <writei+0x82>
    800037e8:	020d1d93          	slli	s11,s10,0x20
    800037ec:	020ddd93          	srli	s11,s11,0x20
    800037f0:	05848513          	addi	a0,s1,88
    800037f4:	86ee                	mv	a3,s11
    800037f6:	8652                	mv	a2,s4
    800037f8:	85de                	mv	a1,s7
    800037fa:	953a                	add	a0,a0,a4
    800037fc:	b61fe0ef          	jal	8000235c <either_copyin>
    80003800:	05850a63          	beq	a0,s8,80003854 <writei+0xb8>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003804:	8526                	mv	a0,s1
    80003806:	6b2000ef          	jal	80003eb8 <log_write>
    brelse(bp);
    8000380a:	8526                	mv	a0,s1
    8000380c:	cf8ff0ef          	jal	80002d04 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003810:	013d09bb          	addw	s3,s10,s3
    80003814:	012d093b          	addw	s2,s10,s2
    80003818:	9a6e                	add	s4,s4,s11
    8000381a:	0569f363          	bgeu	s3,s6,80003860 <writei+0xc4>
    uint addr = bmap(ip, off / BSIZE);
    8000381e:	00a9559b          	srliw	a1,s2,0xa
    80003822:	8556                	mv	a0,s5
    80003824:	f5cff0ef          	jal	80002f80 <bmap>
    80003828:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    8000382c:	c995                	beqz	a1,80003860 <writei+0xc4>
    bp = bread(ip->dev, addr);
    8000382e:	000aa503          	lw	a0,0(s5)
    80003832:	bcaff0ef          	jal	80002bfc <bread>
    80003836:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003838:	3ff97713          	andi	a4,s2,1023
    8000383c:	40ec87bb          	subw	a5,s9,a4
    80003840:	413b06bb          	subw	a3,s6,s3
    80003844:	8d3e                	mv	s10,a5
    80003846:	2781                	sext.w	a5,a5
    80003848:	0006861b          	sext.w	a2,a3
    8000384c:	f8f67ee3          	bgeu	a2,a5,800037e8 <writei+0x4c>
    80003850:	8d36                	mv	s10,a3
    80003852:	bf59                	j	800037e8 <writei+0x4c>
      log_write(bp);
    80003854:	8526                	mv	a0,s1
    80003856:	662000ef          	jal	80003eb8 <log_write>
      brelse(bp);
    8000385a:	8526                	mv	a0,s1
    8000385c:	ca8ff0ef          	jal	80002d04 <brelse>
  }

  if (off > ip->size)
    80003860:	04caa783          	lw	a5,76(s5)
    80003864:	0327fa63          	bgeu	a5,s2,80003898 <writei+0xfc>
    ip->size = off;
    80003868:	052aa623          	sw	s2,76(s5)
    8000386c:	64e6                	ld	s1,88(sp)
    8000386e:	7c02                	ld	s8,32(sp)
    80003870:	6ce2                	ld	s9,24(sp)
    80003872:	6d42                	ld	s10,16(sp)
    80003874:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003876:	8556                	mv	a0,s5
    80003878:	99dff0ef          	jal	80003214 <iupdate>

  return tot;
    8000387c:	0009851b          	sext.w	a0,s3
    80003880:	69a6                	ld	s3,72(sp)
}
    80003882:	70a6                	ld	ra,104(sp)
    80003884:	7406                	ld	s0,96(sp)
    80003886:	6946                	ld	s2,80(sp)
    80003888:	6a06                	ld	s4,64(sp)
    8000388a:	7ae2                	ld	s5,56(sp)
    8000388c:	7b42                	ld	s6,48(sp)
    8000388e:	7ba2                	ld	s7,40(sp)
    80003890:	6165                	addi	sp,sp,112
    80003892:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003894:	89da                	mv	s3,s6
    80003896:	b7c5                	j	80003876 <writei+0xda>
    80003898:	64e6                	ld	s1,88(sp)
    8000389a:	7c02                	ld	s8,32(sp)
    8000389c:	6ce2                	ld	s9,24(sp)
    8000389e:	6d42                	ld	s10,16(sp)
    800038a0:	6da2                	ld	s11,8(sp)
    800038a2:	bfd1                	j	80003876 <writei+0xda>
    return -1;
    800038a4:	557d                	li	a0,-1
}
    800038a6:	8082                	ret
    return -1;
    800038a8:	557d                	li	a0,-1
    800038aa:	bfe1                	j	80003882 <writei+0xe6>
    return -1;
    800038ac:	557d                	li	a0,-1
    800038ae:	bfd1                	j	80003882 <writei+0xe6>

00000000800038b0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038b0:	1141                	addi	sp,sp,-16
    800038b2:	e406                	sd	ra,8(sp)
    800038b4:	e022                	sd	s0,0(sp)
    800038b6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038b8:	4639                	li	a2,14
    800038ba:	d22fd0ef          	jal	80000ddc <strncmp>
}
    800038be:	60a2                	ld	ra,8(sp)
    800038c0:	6402                	ld	s0,0(sp)
    800038c2:	0141                	addi	sp,sp,16
    800038c4:	8082                	ret

00000000800038c6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800038c6:	7139                	addi	sp,sp,-64
    800038c8:	fc06                	sd	ra,56(sp)
    800038ca:	f822                	sd	s0,48(sp)
    800038cc:	f426                	sd	s1,40(sp)
    800038ce:	f04a                	sd	s2,32(sp)
    800038d0:	ec4e                	sd	s3,24(sp)
    800038d2:	e852                	sd	s4,16(sp)
    800038d4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    800038d6:	04451703          	lh	a4,68(a0)
    800038da:	4785                	li	a5,1
    800038dc:	00f71a63          	bne	a4,a5,800038f0 <dirlookup+0x2a>
    800038e0:	892a                	mv	s2,a0
    800038e2:	89ae                	mv	s3,a1
    800038e4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038e6:	457c                	lw	a5,76(a0)
    800038e8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038ea:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800038ec:	e39d                	bnez	a5,80003912 <dirlookup+0x4c>
    800038ee:	a095                	j	80003952 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800038f0:	00004517          	auipc	a0,0x4
    800038f4:	bd050513          	addi	a0,a0,-1072 # 800074c0 <etext+0x4c0>
    800038f8:	ef9fc0ef          	jal	800007f0 <panic>
      panic("dirlookup read");
    800038fc:	00004517          	auipc	a0,0x4
    80003900:	bdc50513          	addi	a0,a0,-1060 # 800074d8 <etext+0x4d8>
    80003904:	eedfc0ef          	jal	800007f0 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003908:	24c1                	addiw	s1,s1,16
    8000390a:	04c92783          	lw	a5,76(s2)
    8000390e:	04f4f163          	bgeu	s1,a5,80003950 <dirlookup+0x8a>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003912:	4741                	li	a4,16
    80003914:	86a6                	mv	a3,s1
    80003916:	fc040613          	addi	a2,s0,-64
    8000391a:	4581                	li	a1,0
    8000391c:	854a                	mv	a0,s2
    8000391e:	d83ff0ef          	jal	800036a0 <readi>
    80003922:	47c1                	li	a5,16
    80003924:	fcf51ce3          	bne	a0,a5,800038fc <dirlookup+0x36>
    if (de.inum == 0)
    80003928:	fc045783          	lhu	a5,-64(s0)
    8000392c:	dff1                	beqz	a5,80003908 <dirlookup+0x42>
    if (namecmp(name, de.name) == 0) {
    8000392e:	fc240593          	addi	a1,s0,-62
    80003932:	854e                	mv	a0,s3
    80003934:	f7dff0ef          	jal	800038b0 <namecmp>
    80003938:	f961                	bnez	a0,80003908 <dirlookup+0x42>
      if (poff)
    8000393a:	000a0463          	beqz	s4,80003942 <dirlookup+0x7c>
        *poff = off;
    8000393e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003942:	fc045583          	lhu	a1,-64(s0)
    80003946:	00092503          	lw	a0,0(s2)
    8000394a:	f0aff0ef          	jal	80003054 <iget>
    8000394e:	a011                	j	80003952 <dirlookup+0x8c>
  return 0;
    80003950:	4501                	li	a0,0
}
    80003952:	70e2                	ld	ra,56(sp)
    80003954:	7442                	ld	s0,48(sp)
    80003956:	74a2                	ld	s1,40(sp)
    80003958:	7902                	ld	s2,32(sp)
    8000395a:	69e2                	ld	s3,24(sp)
    8000395c:	6a42                	ld	s4,16(sp)
    8000395e:	6121                	addi	sp,sp,64
    80003960:	8082                	ret

0000000080003962 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003962:	711d                	addi	sp,sp,-96
    80003964:	ec86                	sd	ra,88(sp)
    80003966:	e8a2                	sd	s0,80(sp)
    80003968:	e4a6                	sd	s1,72(sp)
    8000396a:	e0ca                	sd	s2,64(sp)
    8000396c:	fc4e                	sd	s3,56(sp)
    8000396e:	f852                	sd	s4,48(sp)
    80003970:	f456                	sd	s5,40(sp)
    80003972:	f05a                	sd	s6,32(sp)
    80003974:	ec5e                	sd	s7,24(sp)
    80003976:	e862                	sd	s8,16(sp)
    80003978:	e466                	sd	s9,8(sp)
    8000397a:	1080                	addi	s0,sp,96
    8000397c:	84aa                	mv	s1,a0
    8000397e:	8b2e                	mv	s6,a1
    80003980:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003982:	00054703          	lbu	a4,0(a0)
    80003986:	02f00793          	li	a5,47
    8000398a:	00f70e63          	beq	a4,a5,800039a6 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000398e:	febfd0ef          	jal	80001978 <myproc>
    80003992:	15053503          	ld	a0,336(a0)
    80003996:	8fdff0ef          	jal	80003292 <idup>
    8000399a:	8a2a                	mv	s4,a0
  while (*path == '/')
    8000399c:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    800039a0:	4c35                	li	s8,13

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    800039a2:	4b85                	li	s7,1
    800039a4:	a075                	j	80003a50 <namex+0xee>
    ip = iget(ROOTDEV, ROOTINO);
    800039a6:	4585                	li	a1,1
    800039a8:	4505                	li	a0,1
    800039aa:	eaaff0ef          	jal	80003054 <iget>
    800039ae:	8a2a                	mv	s4,a0
    800039b0:	b7f5                	j	8000399c <namex+0x3a>
      iunlockput(ip);
    800039b2:	8552                	mv	a0,s4
    800039b4:	b67ff0ef          	jal	8000351a <iunlockput>
      return 0;
    800039b8:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    800039ba:	8552                	mv	a0,s4
    800039bc:	60e6                	ld	ra,88(sp)
    800039be:	6446                	ld	s0,80(sp)
    800039c0:	64a6                	ld	s1,72(sp)
    800039c2:	6906                	ld	s2,64(sp)
    800039c4:	79e2                	ld	s3,56(sp)
    800039c6:	7a42                	ld	s4,48(sp)
    800039c8:	7aa2                	ld	s5,40(sp)
    800039ca:	7b02                	ld	s6,32(sp)
    800039cc:	6be2                	ld	s7,24(sp)
    800039ce:	6c42                	ld	s8,16(sp)
    800039d0:	6ca2                	ld	s9,8(sp)
    800039d2:	6125                	addi	sp,sp,96
    800039d4:	8082                	ret
      iunlockput(ip);
    800039d6:	8552                	mv	a0,s4
    800039d8:	b43ff0ef          	jal	8000351a <iunlockput>
      return 0;
    800039dc:	4a01                	li	s4,0
    800039de:	bff1                	j	800039ba <namex+0x58>
      iunlock(ip);
    800039e0:	8552                	mv	a0,s4
    800039e2:	995ff0ef          	jal	80003376 <iunlock>
      return ip;
    800039e6:	bfd1                	j	800039ba <namex+0x58>
      iunlockput(ip);
    800039e8:	8552                	mv	a0,s4
    800039ea:	b31ff0ef          	jal	8000351a <iunlockput>
      return 0;
    800039ee:	8a4e                	mv	s4,s3
    800039f0:	b7e9                	j	800039ba <namex+0x58>
  len = path - s;
    800039f2:	40998633          	sub	a2,s3,s1
    800039f6:	00060c9b          	sext.w	s9,a2
  if (len >= DIRSIZ)
    800039fa:	099c5363          	bge	s8,s9,80003a80 <namex+0x11e>
    memmove(name, s, DIRSIZ);
    800039fe:	4639                	li	a2,14
    80003a00:	85a6                	mv	a1,s1
    80003a02:	8556                	mv	a0,s5
    80003a04:	b68fd0ef          	jal	80000d6c <memmove>
    80003a08:	84ce                	mv	s1,s3
  while (*path == '/')
    80003a0a:	0004c783          	lbu	a5,0(s1)
    80003a0e:	09279363          	bne	a5,s2,80003a94 <namex+0x132>
    path++;
    80003a12:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a14:	0004c783          	lbu	a5,0(s1)
    80003a18:	ff278de3          	beq	a5,s2,80003a12 <namex+0xb0>
    ilock(ip);
    80003a1c:	8552                	mv	a0,s4
    80003a1e:	8abff0ef          	jal	800032c8 <ilock>
    if (ip->type != T_DIR) {
    80003a22:	044a1783          	lh	a5,68(s4)
    80003a26:	f97796e3          	bne	a5,s7,800039b2 <namex+0x50>
    if (ip->nlink == 0) {
    80003a2a:	04aa1783          	lh	a5,74(s4)
    80003a2e:	d7c5                	beqz	a5,800039d6 <namex+0x74>
    if (nameiparent && *path == '\0') {
    80003a30:	000b0563          	beqz	s6,80003a3a <namex+0xd8>
    80003a34:	0004c783          	lbu	a5,0(s1)
    80003a38:	d7c5                	beqz	a5,800039e0 <namex+0x7e>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003a3a:	4601                	li	a2,0
    80003a3c:	85d6                	mv	a1,s5
    80003a3e:	8552                	mv	a0,s4
    80003a40:	e87ff0ef          	jal	800038c6 <dirlookup>
    80003a44:	89aa                	mv	s3,a0
    80003a46:	d14d                	beqz	a0,800039e8 <namex+0x86>
    iunlockput(ip);
    80003a48:	8552                	mv	a0,s4
    80003a4a:	ad1ff0ef          	jal	8000351a <iunlockput>
    ip = next;
    80003a4e:	8a4e                	mv	s4,s3
  while (*path == '/')
    80003a50:	0004c783          	lbu	a5,0(s1)
    80003a54:	01279763          	bne	a5,s2,80003a62 <namex+0x100>
    path++;
    80003a58:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003a5a:	0004c783          	lbu	a5,0(s1)
    80003a5e:	ff278de3          	beq	a5,s2,80003a58 <namex+0xf6>
  if (*path == 0)
    80003a62:	cb95                	beqz	a5,80003a96 <namex+0x134>
  while (*path != '/' && *path != 0)
    80003a64:	0004c783          	lbu	a5,0(s1)
    80003a68:	89a6                	mv	s3,s1
  len = path - s;
    80003a6a:	4c81                	li	s9,0
    80003a6c:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    80003a6e:	01278963          	beq	a5,s2,80003a80 <namex+0x11e>
    80003a72:	d3c1                	beqz	a5,800039f2 <namex+0x90>
    path++;
    80003a74:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80003a76:	0009c783          	lbu	a5,0(s3)
    80003a7a:	ff279ce3          	bne	a5,s2,80003a72 <namex+0x110>
    80003a7e:	bf95                	j	800039f2 <namex+0x90>
    memmove(name, s, len);
    80003a80:	2601                	sext.w	a2,a2
    80003a82:	85a6                	mv	a1,s1
    80003a84:	8556                	mv	a0,s5
    80003a86:	ae6fd0ef          	jal	80000d6c <memmove>
    name[len] = 0;
    80003a8a:	9cd6                	add	s9,s9,s5
    80003a8c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a90:	84ce                	mv	s1,s3
    80003a92:	bfa5                	j	80003a0a <namex+0xa8>
  while ((path = skipelem(path, name)) != 0) {
    80003a94:	f4c1                	bnez	s1,80003a1c <namex+0xba>
  if (nameiparent) {
    80003a96:	f20b02e3          	beqz	s6,800039ba <namex+0x58>
    iput(ip);
    80003a9a:	8552                	mv	a0,s4
    80003a9c:	9afff0ef          	jal	8000344a <iput>
    return 0;
    80003aa0:	4a01                	li	s4,0
    80003aa2:	bf21                	j	800039ba <namex+0x58>

0000000080003aa4 <dirlink>:
{
    80003aa4:	7139                	addi	sp,sp,-64
    80003aa6:	fc06                	sd	ra,56(sp)
    80003aa8:	f822                	sd	s0,48(sp)
    80003aaa:	f04a                	sd	s2,32(sp)
    80003aac:	ec4e                	sd	s3,24(sp)
    80003aae:	e852                	sd	s4,16(sp)
    80003ab0:	0080                	addi	s0,sp,64
    80003ab2:	892a                	mv	s2,a0
    80003ab4:	8a2e                	mv	s4,a1
    80003ab6:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003ab8:	4601                	li	a2,0
    80003aba:	e0dff0ef          	jal	800038c6 <dirlookup>
    80003abe:	e535                	bnez	a0,80003b2a <dirlink+0x86>
    80003ac0:	f426                	sd	s1,40(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ac2:	04c92483          	lw	s1,76(s2)
    80003ac6:	c48d                	beqz	s1,80003af0 <dirlink+0x4c>
    80003ac8:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003aca:	4741                	li	a4,16
    80003acc:	86a6                	mv	a3,s1
    80003ace:	fc040613          	addi	a2,s0,-64
    80003ad2:	4581                	li	a1,0
    80003ad4:	854a                	mv	a0,s2
    80003ad6:	bcbff0ef          	jal	800036a0 <readi>
    80003ada:	47c1                	li	a5,16
    80003adc:	04f51b63          	bne	a0,a5,80003b32 <dirlink+0x8e>
    if (de.inum == 0)
    80003ae0:	fc045783          	lhu	a5,-64(s0)
    80003ae4:	c791                	beqz	a5,80003af0 <dirlink+0x4c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ae6:	24c1                	addiw	s1,s1,16
    80003ae8:	04c92783          	lw	a5,76(s2)
    80003aec:	fcf4efe3          	bltu	s1,a5,80003aca <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003af0:	4639                	li	a2,14
    80003af2:	85d2                	mv	a1,s4
    80003af4:	fc240513          	addi	a0,s0,-62
    80003af8:	b1afd0ef          	jal	80000e12 <strncpy>
  de.inum = inum;
    80003afc:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b00:	4741                	li	a4,16
    80003b02:	86a6                	mv	a3,s1
    80003b04:	fc040613          	addi	a2,s0,-64
    80003b08:	4581                	li	a1,0
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	c91ff0ef          	jal	8000379c <writei>
    80003b10:	1541                	addi	a0,a0,-16
    80003b12:	00a03533          	snez	a0,a0
    80003b16:	40a00533          	neg	a0,a0
    80003b1a:	74a2                	ld	s1,40(sp)
}
    80003b1c:	70e2                	ld	ra,56(sp)
    80003b1e:	7442                	ld	s0,48(sp)
    80003b20:	7902                	ld	s2,32(sp)
    80003b22:	69e2                	ld	s3,24(sp)
    80003b24:	6a42                	ld	s4,16(sp)
    80003b26:	6121                	addi	sp,sp,64
    80003b28:	8082                	ret
    iput(ip);
    80003b2a:	921ff0ef          	jal	8000344a <iput>
    return -1;
    80003b2e:	557d                	li	a0,-1
    80003b30:	b7f5                	j	80003b1c <dirlink+0x78>
      panic("dirlink read");
    80003b32:	00004517          	auipc	a0,0x4
    80003b36:	9b650513          	addi	a0,a0,-1610 # 800074e8 <etext+0x4e8>
    80003b3a:	cb7fc0ef          	jal	800007f0 <panic>

0000000080003b3e <namei>:

struct inode *
namei(char *path)
{
    80003b3e:	1101                	addi	sp,sp,-32
    80003b40:	ec06                	sd	ra,24(sp)
    80003b42:	e822                	sd	s0,16(sp)
    80003b44:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b46:	fe040613          	addi	a2,s0,-32
    80003b4a:	4581                	li	a1,0
    80003b4c:	e17ff0ef          	jal	80003962 <namex>
}
    80003b50:	60e2                	ld	ra,24(sp)
    80003b52:	6442                	ld	s0,16(sp)
    80003b54:	6105                	addi	sp,sp,32
    80003b56:	8082                	ret

0000000080003b58 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003b58:	1141                	addi	sp,sp,-16
    80003b5a:	e406                	sd	ra,8(sp)
    80003b5c:	e022                	sd	s0,0(sp)
    80003b5e:	0800                	addi	s0,sp,16
    80003b60:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b62:	4585                	li	a1,1
    80003b64:	dffff0ef          	jal	80003962 <namex>
}
    80003b68:	60a2                	ld	ra,8(sp)
    80003b6a:	6402                	ld	s0,0(sp)
    80003b6c:	0141                	addi	sp,sp,16
    80003b6e:	8082                	ret

0000000080003b70 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b70:	1101                	addi	sp,sp,-32
    80003b72:	ec06                	sd	ra,24(sp)
    80003b74:	e822                	sd	s0,16(sp)
    80003b76:	e426                	sd	s1,8(sp)
    80003b78:	e04a                	sd	s2,0(sp)
    80003b7a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b7c:	0001c917          	auipc	s2,0x1c
    80003b80:	e8490913          	addi	s2,s2,-380 # 8001fa00 <log>
    80003b84:	01892583          	lw	a1,24(s2)
    80003b88:	02492503          	lw	a0,36(s2)
    80003b8c:	870ff0ef          	jal	80002bfc <bread>
    80003b90:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003b92:	02c92603          	lw	a2,44(s2)
    80003b96:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b98:	00c05f63          	blez	a2,80003bb6 <write_head+0x46>
    80003b9c:	0001c717          	auipc	a4,0x1c
    80003ba0:	e9470713          	addi	a4,a4,-364 # 8001fa30 <log+0x30>
    80003ba4:	87aa                	mv	a5,a0
    80003ba6:	060a                	slli	a2,a2,0x2
    80003ba8:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003baa:	4314                	lw	a3,0(a4)
    80003bac:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003bae:	0711                	addi	a4,a4,4
    80003bb0:	0791                	addi	a5,a5,4
    80003bb2:	fec79ce3          	bne	a5,a2,80003baa <write_head+0x3a>
  }
  bwrite(buf);
    80003bb6:	8526                	mv	a0,s1
    80003bb8:	91aff0ef          	jal	80002cd2 <bwrite>
  brelse(buf);
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	946ff0ef          	jal	80002d04 <brelse>
}
    80003bc2:	60e2                	ld	ra,24(sp)
    80003bc4:	6442                	ld	s0,16(sp)
    80003bc6:	64a2                	ld	s1,8(sp)
    80003bc8:	6902                	ld	s2,0(sp)
    80003bca:	6105                	addi	sp,sp,32
    80003bcc:	8082                	ret

0000000080003bce <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bce:	0001c797          	auipc	a5,0x1c
    80003bd2:	e5e7a783          	lw	a5,-418(a5) # 8001fa2c <log+0x2c>
    80003bd6:	0af05e63          	blez	a5,80003c92 <install_trans+0xc4>
{
    80003bda:	715d                	addi	sp,sp,-80
    80003bdc:	e486                	sd	ra,72(sp)
    80003bde:	e0a2                	sd	s0,64(sp)
    80003be0:	fc26                	sd	s1,56(sp)
    80003be2:	f84a                	sd	s2,48(sp)
    80003be4:	f44e                	sd	s3,40(sp)
    80003be6:	f052                	sd	s4,32(sp)
    80003be8:	ec56                	sd	s5,24(sp)
    80003bea:	e85a                	sd	s6,16(sp)
    80003bec:	e45e                	sd	s7,8(sp)
    80003bee:	0880                	addi	s0,sp,80
    80003bf0:	8b2a                	mv	s6,a0
    80003bf2:	0001ca97          	auipc	s5,0x1c
    80003bf6:	e3ea8a93          	addi	s5,s5,-450 # 8001fa30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bfa:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bfc:	00004b97          	auipc	s7,0x4
    80003c00:	8fcb8b93          	addi	s7,s7,-1796 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c04:	0001ca17          	auipc	s4,0x1c
    80003c08:	dfca0a13          	addi	s4,s4,-516 # 8001fa00 <log>
    80003c0c:	a025                	j	80003c34 <install_trans+0x66>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c0e:	000aa603          	lw	a2,0(s5)
    80003c12:	85ce                	mv	a1,s3
    80003c14:	855e                	mv	a0,s7
    80003c16:	8f5fc0ef          	jal	8000050a <printk>
    80003c1a:	a839                	j	80003c38 <install_trans+0x6a>
    brelse(lbuf);
    80003c1c:	854a                	mv	a0,s2
    80003c1e:	8e6ff0ef          	jal	80002d04 <brelse>
    brelse(dbuf);
    80003c22:	8526                	mv	a0,s1
    80003c24:	8e0ff0ef          	jal	80002d04 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c28:	2985                	addiw	s3,s3,1
    80003c2a:	0a91                	addi	s5,s5,4
    80003c2c:	02ca2783          	lw	a5,44(s4)
    80003c30:	04f9d663          	bge	s3,a5,80003c7c <install_trans+0xae>
    if (recovering) {
    80003c34:	fc0b1de3          	bnez	s6,80003c0e <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003c38:	018a2583          	lw	a1,24(s4)
    80003c3c:	013585bb          	addw	a1,a1,s3
    80003c40:	2585                	addiw	a1,a1,1
    80003c42:	024a2503          	lw	a0,36(s4)
    80003c46:	fb7fe0ef          	jal	80002bfc <bread>
    80003c4a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003c4c:	000aa583          	lw	a1,0(s5)
    80003c50:	024a2503          	lw	a0,36(s4)
    80003c54:	fa9fe0ef          	jal	80002bfc <bread>
    80003c58:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003c5a:	40000613          	li	a2,1024
    80003c5e:	05890593          	addi	a1,s2,88
    80003c62:	05850513          	addi	a0,a0,88
    80003c66:	906fd0ef          	jal	80000d6c <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003c6a:	8526                	mv	a0,s1
    80003c6c:	866ff0ef          	jal	80002cd2 <bwrite>
    if (recovering == 0)
    80003c70:	fa0b16e3          	bnez	s6,80003c1c <install_trans+0x4e>
      bunpin(dbuf);
    80003c74:	8526                	mv	a0,s1
    80003c76:	94aff0ef          	jal	80002dc0 <bunpin>
    80003c7a:	b74d                	j	80003c1c <install_trans+0x4e>
}
    80003c7c:	60a6                	ld	ra,72(sp)
    80003c7e:	6406                	ld	s0,64(sp)
    80003c80:	74e2                	ld	s1,56(sp)
    80003c82:	7942                	ld	s2,48(sp)
    80003c84:	79a2                	ld	s3,40(sp)
    80003c86:	7a02                	ld	s4,32(sp)
    80003c88:	6ae2                	ld	s5,24(sp)
    80003c8a:	6b42                	ld	s6,16(sp)
    80003c8c:	6ba2                	ld	s7,8(sp)
    80003c8e:	6161                	addi	sp,sp,80
    80003c90:	8082                	ret
    80003c92:	8082                	ret

0000000080003c94 <initlog>:
{
    80003c94:	7179                	addi	sp,sp,-48
    80003c96:	f406                	sd	ra,40(sp)
    80003c98:	f022                	sd	s0,32(sp)
    80003c9a:	ec26                	sd	s1,24(sp)
    80003c9c:	e84a                	sd	s2,16(sp)
    80003c9e:	e44e                	sd	s3,8(sp)
    80003ca0:	1800                	addi	s0,sp,48
    80003ca2:	892a                	mv	s2,a0
    80003ca4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ca6:	0001c497          	auipc	s1,0x1c
    80003caa:	d5a48493          	addi	s1,s1,-678 # 8001fa00 <log>
    80003cae:	00004597          	auipc	a1,0x4
    80003cb2:	86a58593          	addi	a1,a1,-1942 # 80007518 <etext+0x518>
    80003cb6:	8526                	mv	a0,s1
    80003cb8:	f1ffc0ef          	jal	80000bd6 <initlock>
  log.start = sb->logstart;
    80003cbc:	0149a583          	lw	a1,20(s3)
    80003cc0:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003cc2:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003cc6:	854a                	mv	a0,s2
    80003cc8:	f35fe0ef          	jal	80002bfc <bread>
  log.lh.n = lh->n;
    80003ccc:	4d30                	lw	a2,88(a0)
    80003cce:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003cd0:	00c05f63          	blez	a2,80003cee <initlog+0x5a>
    80003cd4:	87aa                	mv	a5,a0
    80003cd6:	0001c717          	auipc	a4,0x1c
    80003cda:	d5a70713          	addi	a4,a4,-678 # 8001fa30 <log+0x30>
    80003cde:	060a                	slli	a2,a2,0x2
    80003ce0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ce2:	4ff4                	lw	a3,92(a5)
    80003ce4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ce6:	0791                	addi	a5,a5,4
    80003ce8:	0711                	addi	a4,a4,4
    80003cea:	fec79ce3          	bne	a5,a2,80003ce2 <initlog+0x4e>
  brelse(buf);
    80003cee:	816ff0ef          	jal	80002d04 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003cf2:	4505                	li	a0,1
    80003cf4:	edbff0ef          	jal	80003bce <install_trans>
  log.lh.n = 0;
    80003cf8:	0001c797          	auipc	a5,0x1c
    80003cfc:	d207aa23          	sw	zero,-716(a5) # 8001fa2c <log+0x2c>
  write_head(); // clear the log
    80003d00:	e71ff0ef          	jal	80003b70 <write_head>
}
    80003d04:	70a2                	ld	ra,40(sp)
    80003d06:	7402                	ld	s0,32(sp)
    80003d08:	64e2                	ld	s1,24(sp)
    80003d0a:	6942                	ld	s2,16(sp)
    80003d0c:	69a2                	ld	s3,8(sp)
    80003d0e:	6145                	addi	sp,sp,48
    80003d10:	8082                	ret

0000000080003d12 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d12:	1101                	addi	sp,sp,-32
    80003d14:	ec06                	sd	ra,24(sp)
    80003d16:	e822                	sd	s0,16(sp)
    80003d18:	e426                	sd	s1,8(sp)
    80003d1a:	e04a                	sd	s2,0(sp)
    80003d1c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d1e:	0001c517          	auipc	a0,0x1c
    80003d22:	ce250513          	addi	a0,a0,-798 # 8001fa00 <log>
    80003d26:	f27fc0ef          	jal	80000c4c <acquire>
  while (1) {
    if (log.committing) {
    80003d2a:	0001c497          	auipc	s1,0x1c
    80003d2e:	cd648493          	addi	s1,s1,-810 # 8001fa00 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d32:	4979                	li	s2,30
    80003d34:	a821                	j	80003d4c <begin_op+0x3a>
      sleep_prepare(&log);
    80003d36:	8526                	mv	a0,s1
    80003d38:	a44fe0ef          	jal	80001f7c <sleep_prepare>
      release(&log.lock);
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	f9bfc0ef          	jal	80000cd8 <release>
      sleep();
    80003d42:	a76fe0ef          	jal	80001fb8 <sleep>
      acquire(&log.lock);
    80003d46:	8526                	mv	a0,s1
    80003d48:	f05fc0ef          	jal	80000c4c <acquire>
    if (log.committing) {
    80003d4c:	509c                	lw	a5,32(s1)
    80003d4e:	f7e5                	bnez	a5,80003d36 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003d50:	4cd8                	lw	a4,28(s1)
    80003d52:	2705                	addiw	a4,a4,1
    80003d54:	0027179b          	slliw	a5,a4,0x2
    80003d58:	9fb9                	addw	a5,a5,a4
    80003d5a:	0017979b          	slliw	a5,a5,0x1
    80003d5e:	54d4                	lw	a3,44(s1)
    80003d60:	9fb5                	addw	a5,a5,a3
    80003d62:	00f95e63          	bge	s2,a5,80003d7e <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003d66:	8526                	mv	a0,s1
    80003d68:	a14fe0ef          	jal	80001f7c <sleep_prepare>
      release(&log.lock);
    80003d6c:	8526                	mv	a0,s1
    80003d6e:	f6bfc0ef          	jal	80000cd8 <release>
      sleep();
    80003d72:	a46fe0ef          	jal	80001fb8 <sleep>
      acquire(&log.lock);
    80003d76:	8526                	mv	a0,s1
    80003d78:	ed5fc0ef          	jal	80000c4c <acquire>
    80003d7c:	bfc1                	j	80003d4c <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003d7e:	0001c517          	auipc	a0,0x1c
    80003d82:	c8250513          	addi	a0,a0,-894 # 8001fa00 <log>
    80003d86:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003d88:	f51fc0ef          	jal	80000cd8 <release>
      break;
    }
  }
}
    80003d8c:	60e2                	ld	ra,24(sp)
    80003d8e:	6442                	ld	s0,16(sp)
    80003d90:	64a2                	ld	s1,8(sp)
    80003d92:	6902                	ld	s2,0(sp)
    80003d94:	6105                	addi	sp,sp,32
    80003d96:	8082                	ret

0000000080003d98 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d98:	7139                	addi	sp,sp,-64
    80003d9a:	fc06                	sd	ra,56(sp)
    80003d9c:	f822                	sd	s0,48(sp)
    80003d9e:	f426                	sd	s1,40(sp)
    80003da0:	f04a                	sd	s2,32(sp)
    80003da2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003da4:	0001c497          	auipc	s1,0x1c
    80003da8:	c5c48493          	addi	s1,s1,-932 # 8001fa00 <log>
    80003dac:	8526                	mv	a0,s1
    80003dae:	e9ffc0ef          	jal	80000c4c <acquire>
  log.outstanding -= 1;
    80003db2:	4cdc                	lw	a5,28(s1)
    80003db4:	37fd                	addiw	a5,a5,-1
    80003db6:	0007891b          	sext.w	s2,a5
    80003dba:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003dbc:	509c                	lw	a5,32(s1)
    80003dbe:	e3b1                	bnez	a5,80003e02 <end_op+0x6a>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003dc0:	04091a63          	bnez	s2,80003e14 <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    80003dc4:	0001c497          	auipc	s1,0x1c
    80003dc8:	c3c48493          	addi	s1,s1,-964 # 8001fa00 <log>
    80003dcc:	4785                	li	a5,1
    80003dce:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003dd0:	8526                	mv	a0,s1
    80003dd2:	f07fc0ef          	jal	80000cd8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003dd6:	54dc                	lw	a5,44(s1)
    80003dd8:	04f04e63          	bgtz	a5,80003e34 <end_op+0x9c>
    acquire(&log.lock);
    80003ddc:	0001c497          	auipc	s1,0x1c
    80003de0:	c2448493          	addi	s1,s1,-988 # 8001fa00 <log>
    80003de4:	8526                	mv	a0,s1
    80003de6:	e67fc0ef          	jal	80000c4c <acquire>
    log.committing = 0;
    80003dea:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003dee:	549c                	lw	a5,40(s1)
    80003df0:	2785                	addiw	a5,a5,1
    80003df2:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003df4:	8526                	mv	a0,s1
    80003df6:	9f2fe0ef          	jal	80001fe8 <wakeup>
    release(&log.lock);
    80003dfa:	8526                	mv	a0,s1
    80003dfc:	eddfc0ef          	jal	80000cd8 <release>
}
    80003e00:	a025                	j	80003e28 <end_op+0x90>
    80003e02:	ec4e                	sd	s3,24(sp)
    80003e04:	e852                	sd	s4,16(sp)
    80003e06:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e08:	00003517          	auipc	a0,0x3
    80003e0c:	71850513          	addi	a0,a0,1816 # 80007520 <etext+0x520>
    80003e10:	9e1fc0ef          	jal	800007f0 <panic>
    wakeup(&log);
    80003e14:	0001c497          	auipc	s1,0x1c
    80003e18:	bec48493          	addi	s1,s1,-1044 # 8001fa00 <log>
    80003e1c:	8526                	mv	a0,s1
    80003e1e:	9cafe0ef          	jal	80001fe8 <wakeup>
  release(&log.lock);
    80003e22:	8526                	mv	a0,s1
    80003e24:	eb5fc0ef          	jal	80000cd8 <release>
}
    80003e28:	70e2                	ld	ra,56(sp)
    80003e2a:	7442                	ld	s0,48(sp)
    80003e2c:	74a2                	ld	s1,40(sp)
    80003e2e:	7902                	ld	s2,32(sp)
    80003e30:	6121                	addi	sp,sp,64
    80003e32:	8082                	ret
    80003e34:	ec4e                	sd	s3,24(sp)
    80003e36:	e852                	sd	s4,16(sp)
    80003e38:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e3a:	0001ca97          	auipc	s5,0x1c
    80003e3e:	bf6a8a93          	addi	s5,s5,-1034 # 8001fa30 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003e42:	0001ca17          	auipc	s4,0x1c
    80003e46:	bbea0a13          	addi	s4,s4,-1090 # 8001fa00 <log>
    80003e4a:	018a2583          	lw	a1,24(s4)
    80003e4e:	012585bb          	addw	a1,a1,s2
    80003e52:	2585                	addiw	a1,a1,1
    80003e54:	024a2503          	lw	a0,36(s4)
    80003e58:	da5fe0ef          	jal	80002bfc <bread>
    80003e5c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e5e:	000aa583          	lw	a1,0(s5)
    80003e62:	024a2503          	lw	a0,36(s4)
    80003e66:	d97fe0ef          	jal	80002bfc <bread>
    80003e6a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e6c:	40000613          	li	a2,1024
    80003e70:	05850593          	addi	a1,a0,88
    80003e74:	05848513          	addi	a0,s1,88
    80003e78:	ef5fc0ef          	jal	80000d6c <memmove>
    bwrite(to); // write the log
    80003e7c:	8526                	mv	a0,s1
    80003e7e:	e55fe0ef          	jal	80002cd2 <bwrite>
    brelse(from);
    80003e82:	854e                	mv	a0,s3
    80003e84:	e81fe0ef          	jal	80002d04 <brelse>
    brelse(to);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	e7bfe0ef          	jal	80002d04 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e8e:	2905                	addiw	s2,s2,1
    80003e90:	0a91                	addi	s5,s5,4
    80003e92:	02ca2783          	lw	a5,44(s4)
    80003e96:	faf94ae3          	blt	s2,a5,80003e4a <end_op+0xb2>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003e9a:	cd7ff0ef          	jal	80003b70 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e9e:	4501                	li	a0,0
    80003ea0:	d2fff0ef          	jal	80003bce <install_trans>
    log.lh.n = 0;
    80003ea4:	0001c797          	auipc	a5,0x1c
    80003ea8:	b807a423          	sw	zero,-1144(a5) # 8001fa2c <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003eac:	cc5ff0ef          	jal	80003b70 <write_head>
    80003eb0:	69e2                	ld	s3,24(sp)
    80003eb2:	6a42                	ld	s4,16(sp)
    80003eb4:	6aa2                	ld	s5,8(sp)
    80003eb6:	b71d                	j	80003ddc <end_op+0x44>

0000000080003eb8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003eb8:	1101                	addi	sp,sp,-32
    80003eba:	ec06                	sd	ra,24(sp)
    80003ebc:	e822                	sd	s0,16(sp)
    80003ebe:	e426                	sd	s1,8(sp)
    80003ec0:	e04a                	sd	s2,0(sp)
    80003ec2:	1000                	addi	s0,sp,32
    80003ec4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003ec6:	0001c917          	auipc	s2,0x1c
    80003eca:	b3a90913          	addi	s2,s2,-1222 # 8001fa00 <log>
    80003ece:	854a                	mv	a0,s2
    80003ed0:	d7dfc0ef          	jal	80000c4c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003ed4:	02c92603          	lw	a2,44(s2)
    80003ed8:	47f5                	li	a5,29
    80003eda:	04c7cc63          	blt	a5,a2,80003f32 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003ede:	0001c797          	auipc	a5,0x1c
    80003ee2:	b3e7a783          	lw	a5,-1218(a5) # 8001fa1c <log+0x1c>
    80003ee6:	04f05c63          	blez	a5,80003f3e <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003eea:	4781                	li	a5,0
    80003eec:	04c05f63          	blez	a2,80003f4a <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003ef0:	44cc                	lw	a1,12(s1)
    80003ef2:	0001c717          	auipc	a4,0x1c
    80003ef6:	b3e70713          	addi	a4,a4,-1218 # 8001fa30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003efa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003efc:	4314                	lw	a3,0(a4)
    80003efe:	04b68663          	beq	a3,a1,80003f4a <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f02:	2785                	addiw	a5,a5,1
    80003f04:	0711                	addi	a4,a4,4
    80003f06:	fef61be3          	bne	a2,a5,80003efc <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f0a:	0621                	addi	a2,a2,8
    80003f0c:	060a                	slli	a2,a2,0x2
    80003f0e:	0001c797          	auipc	a5,0x1c
    80003f12:	af278793          	addi	a5,a5,-1294 # 8001fa00 <log>
    80003f16:	97b2                	add	a5,a5,a2
    80003f18:	44d8                	lw	a4,12(s1)
    80003f1a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003f1c:	8526                	mv	a0,s1
    80003f1e:	e6ffe0ef          	jal	80002d8c <bpin>
    log.lh.n++;
    80003f22:	0001c717          	auipc	a4,0x1c
    80003f26:	ade70713          	addi	a4,a4,-1314 # 8001fa00 <log>
    80003f2a:	575c                	lw	a5,44(a4)
    80003f2c:	2785                	addiw	a5,a5,1
    80003f2e:	d75c                	sw	a5,44(a4)
    80003f30:	a80d                	j	80003f62 <log_write+0xaa>
    panic("too big a transaction");
    80003f32:	00003517          	auipc	a0,0x3
    80003f36:	5fe50513          	addi	a0,a0,1534 # 80007530 <etext+0x530>
    80003f3a:	8b7fc0ef          	jal	800007f0 <panic>
    panic("log_write outside of trans");
    80003f3e:	00003517          	auipc	a0,0x3
    80003f42:	60a50513          	addi	a0,a0,1546 # 80007548 <etext+0x548>
    80003f46:	8abfc0ef          	jal	800007f0 <panic>
  log.lh.block[i] = b->blockno;
    80003f4a:	00878693          	addi	a3,a5,8
    80003f4e:	068a                	slli	a3,a3,0x2
    80003f50:	0001c717          	auipc	a4,0x1c
    80003f54:	ab070713          	addi	a4,a4,-1360 # 8001fa00 <log>
    80003f58:	9736                	add	a4,a4,a3
    80003f5a:	44d4                	lw	a3,12(s1)
    80003f5c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003f5e:	faf60fe3          	beq	a2,a5,80003f1c <log_write+0x64>
  }
  release(&log.lock);
    80003f62:	0001c517          	auipc	a0,0x1c
    80003f66:	a9e50513          	addi	a0,a0,-1378 # 8001fa00 <log>
    80003f6a:	d6ffc0ef          	jal	80000cd8 <release>
}
    80003f6e:	60e2                	ld	ra,24(sp)
    80003f70:	6442                	ld	s0,16(sp)
    80003f72:	64a2                	ld	s1,8(sp)
    80003f74:	6902                	ld	s2,0(sp)
    80003f76:	6105                	addi	sp,sp,32
    80003f78:	8082                	ret

0000000080003f7a <sys_sync>:

uint64
sys_sync(void)
{
    80003f7a:	1101                	addi	sp,sp,-32
    80003f7c:	ec06                	sd	ra,24(sp)
    80003f7e:	e822                	sd	s0,16(sp)
    80003f80:	e426                	sd	s1,8(sp)
    80003f82:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f84:	0001c497          	auipc	s1,0x1c
    80003f88:	a7c48493          	addi	s1,s1,-1412 # 8001fa00 <log>
    80003f8c:	8526                	mv	a0,s1
    80003f8e:	cbffc0ef          	jal	80000c4c <acquire>
  if (log.committing || log.outstanding > 0) {
    80003f92:	509c                	lw	a5,32(s1)
    80003f94:	e799                	bnez	a5,80003fa2 <sys_sync+0x28>
    80003f96:	0001c797          	auipc	a5,0x1c
    80003f9a:	a867a783          	lw	a5,-1402(a5) # 8001fa1c <log+0x1c>
    80003f9e:	02f05a63          	blez	a5,80003fd2 <sys_sync+0x58>
    80003fa2:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003fa4:	0001c917          	auipc	s2,0x1c
    80003fa8:	a8492903          	lw	s2,-1404(s2) # 8001fa28 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80003fac:	0001c497          	auipc	s1,0x1c
    80003fb0:	a5448493          	addi	s1,s1,-1452 # 8001fa00 <log>
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	fc7fd0ef          	jal	80001f7c <sleep_prepare>
      release(&log.lock);
    80003fba:	8526                	mv	a0,s1
    80003fbc:	d1dfc0ef          	jal	80000cd8 <release>
      sleep();
    80003fc0:	ff9fd0ef          	jal	80001fb8 <sleep>
      acquire(&log.lock);
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	c87fc0ef          	jal	80000c4c <acquire>
    while (log.ncommit < n) {
    80003fca:	549c                	lw	a5,40(s1)
    80003fcc:	fef954e3          	bge	s2,a5,80003fb4 <sys_sync+0x3a>
    80003fd0:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003fd2:	0001c517          	auipc	a0,0x1c
    80003fd6:	a2e50513          	addi	a0,a0,-1490 # 8001fa00 <log>
    80003fda:	cfffc0ef          	jal	80000cd8 <release>
  return 0;
}
    80003fde:	4501                	li	a0,0
    80003fe0:	60e2                	ld	ra,24(sp)
    80003fe2:	6442                	ld	s0,16(sp)
    80003fe4:	64a2                	ld	s1,8(sp)
    80003fe6:	6105                	addi	sp,sp,32
    80003fe8:	8082                	ret

0000000080003fea <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fea:	1101                	addi	sp,sp,-32
    80003fec:	ec06                	sd	ra,24(sp)
    80003fee:	e822                	sd	s0,16(sp)
    80003ff0:	e426                	sd	s1,8(sp)
    80003ff2:	e04a                	sd	s2,0(sp)
    80003ff4:	1000                	addi	s0,sp,32
    80003ff6:	84aa                	mv	s1,a0
    80003ff8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ffa:	00003597          	auipc	a1,0x3
    80003ffe:	56e58593          	addi	a1,a1,1390 # 80007568 <etext+0x568>
    80004002:	0521                	addi	a0,a0,8
    80004004:	bd3fc0ef          	jal	80000bd6 <initlock>
  lk->name = name;
    80004008:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000400c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004010:	0204a423          	sw	zero,40(s1)
}
    80004014:	60e2                	ld	ra,24(sp)
    80004016:	6442                	ld	s0,16(sp)
    80004018:	64a2                	ld	s1,8(sp)
    8000401a:	6902                	ld	s2,0(sp)
    8000401c:	6105                	addi	sp,sp,32
    8000401e:	8082                	ret

0000000080004020 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004020:	1101                	addi	sp,sp,-32
    80004022:	ec06                	sd	ra,24(sp)
    80004024:	e822                	sd	s0,16(sp)
    80004026:	e426                	sd	s1,8(sp)
    80004028:	e04a                	sd	s2,0(sp)
    8000402a:	1000                	addi	s0,sp,32
    8000402c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000402e:	00850913          	addi	s2,a0,8
    80004032:	854a                	mv	a0,s2
    80004034:	c19fc0ef          	jal	80000c4c <acquire>
  while (lk->locked) {
    80004038:	409c                	lw	a5,0(s1)
    8000403a:	cf91                	beqz	a5,80004056 <acquiresleep+0x36>
    sleep_prepare(lk);
    8000403c:	8526                	mv	a0,s1
    8000403e:	f3ffd0ef          	jal	80001f7c <sleep_prepare>
    release(&lk->lk);
    80004042:	854a                	mv	a0,s2
    80004044:	c95fc0ef          	jal	80000cd8 <release>
    sleep();
    80004048:	f71fd0ef          	jal	80001fb8 <sleep>
    acquire(&lk->lk);
    8000404c:	854a                	mv	a0,s2
    8000404e:	bfffc0ef          	jal	80000c4c <acquire>
  while (lk->locked) {
    80004052:	409c                	lw	a5,0(s1)
    80004054:	f7e5                	bnez	a5,8000403c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004056:	4785                	li	a5,1
    80004058:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000405a:	91ffd0ef          	jal	80001978 <myproc>
    8000405e:	591c                	lw	a5,48(a0)
    80004060:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004062:	854a                	mv	a0,s2
    80004064:	c75fc0ef          	jal	80000cd8 <release>
}
    80004068:	60e2                	ld	ra,24(sp)
    8000406a:	6442                	ld	s0,16(sp)
    8000406c:	64a2                	ld	s1,8(sp)
    8000406e:	6902                	ld	s2,0(sp)
    80004070:	6105                	addi	sp,sp,32
    80004072:	8082                	ret

0000000080004074 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004074:	1101                	addi	sp,sp,-32
    80004076:	ec06                	sd	ra,24(sp)
    80004078:	e822                	sd	s0,16(sp)
    8000407a:	e426                	sd	s1,8(sp)
    8000407c:	e04a                	sd	s2,0(sp)
    8000407e:	1000                	addi	s0,sp,32
    80004080:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004082:	00850913          	addi	s2,a0,8
    80004086:	854a                	mv	a0,s2
    80004088:	bc5fc0ef          	jal	80000c4c <acquire>
  lk->locked = 0;
    8000408c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004090:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004094:	8526                	mv	a0,s1
    80004096:	f53fd0ef          	jal	80001fe8 <wakeup>
  release(&lk->lk);
    8000409a:	854a                	mv	a0,s2
    8000409c:	c3dfc0ef          	jal	80000cd8 <release>
}
    800040a0:	60e2                	ld	ra,24(sp)
    800040a2:	6442                	ld	s0,16(sp)
    800040a4:	64a2                	ld	s1,8(sp)
    800040a6:	6902                	ld	s2,0(sp)
    800040a8:	6105                	addi	sp,sp,32
    800040aa:	8082                	ret

00000000800040ac <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800040ac:	7179                	addi	sp,sp,-48
    800040ae:	f406                	sd	ra,40(sp)
    800040b0:	f022                	sd	s0,32(sp)
    800040b2:	ec26                	sd	s1,24(sp)
    800040b4:	e84a                	sd	s2,16(sp)
    800040b6:	1800                	addi	s0,sp,48
    800040b8:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800040ba:	00850913          	addi	s2,a0,8
    800040be:	854a                	mv	a0,s2
    800040c0:	b8dfc0ef          	jal	80000c4c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040c4:	409c                	lw	a5,0(s1)
    800040c6:	ef81                	bnez	a5,800040de <holdingsleep+0x32>
    800040c8:	4481                	li	s1,0
  release(&lk->lk);
    800040ca:	854a                	mv	a0,s2
    800040cc:	c0dfc0ef          	jal	80000cd8 <release>
  return r;
}
    800040d0:	8526                	mv	a0,s1
    800040d2:	70a2                	ld	ra,40(sp)
    800040d4:	7402                	ld	s0,32(sp)
    800040d6:	64e2                	ld	s1,24(sp)
    800040d8:	6942                	ld	s2,16(sp)
    800040da:	6145                	addi	sp,sp,48
    800040dc:	8082                	ret
    800040de:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040e0:	0284a983          	lw	s3,40(s1)
    800040e4:	895fd0ef          	jal	80001978 <myproc>
    800040e8:	5904                	lw	s1,48(a0)
    800040ea:	413484b3          	sub	s1,s1,s3
    800040ee:	0014b493          	seqz	s1,s1
    800040f2:	69a2                	ld	s3,8(sp)
    800040f4:	bfd9                	j	800040ca <holdingsleep+0x1e>

00000000800040f6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040f6:	1141                	addi	sp,sp,-16
    800040f8:	e406                	sd	ra,8(sp)
    800040fa:	e022                	sd	s0,0(sp)
    800040fc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040fe:	00003597          	auipc	a1,0x3
    80004102:	47a58593          	addi	a1,a1,1146 # 80007578 <etext+0x578>
    80004106:	0001c517          	auipc	a0,0x1c
    8000410a:	a4250513          	addi	a0,a0,-1470 # 8001fb48 <ftable>
    8000410e:	ac9fc0ef          	jal	80000bd6 <initlock>
}
    80004112:	60a2                	ld	ra,8(sp)
    80004114:	6402                	ld	s0,0(sp)
    80004116:	0141                	addi	sp,sp,16
    80004118:	8082                	ret

000000008000411a <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000411a:	1101                	addi	sp,sp,-32
    8000411c:	ec06                	sd	ra,24(sp)
    8000411e:	e822                	sd	s0,16(sp)
    80004120:	e426                	sd	s1,8(sp)
    80004122:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004124:	0001c517          	auipc	a0,0x1c
    80004128:	a2450513          	addi	a0,a0,-1500 # 8001fb48 <ftable>
    8000412c:	b21fc0ef          	jal	80000c4c <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004130:	0001c497          	auipc	s1,0x1c
    80004134:	a3048493          	addi	s1,s1,-1488 # 8001fb60 <ftable+0x18>
    80004138:	0001d717          	auipc	a4,0x1d
    8000413c:	9c870713          	addi	a4,a4,-1592 # 80020b00 <disk>
    if (f->ref == 0) {
    80004140:	40dc                	lw	a5,4(s1)
    80004142:	cf89                	beqz	a5,8000415c <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004144:	02848493          	addi	s1,s1,40
    80004148:	fee49ce3          	bne	s1,a4,80004140 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000414c:	0001c517          	auipc	a0,0x1c
    80004150:	9fc50513          	addi	a0,a0,-1540 # 8001fb48 <ftable>
    80004154:	b85fc0ef          	jal	80000cd8 <release>
  return 0;
    80004158:	4481                	li	s1,0
    8000415a:	a809                	j	8000416c <filealloc+0x52>
      f->ref = 1;
    8000415c:	4785                	li	a5,1
    8000415e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004160:	0001c517          	auipc	a0,0x1c
    80004164:	9e850513          	addi	a0,a0,-1560 # 8001fb48 <ftable>
    80004168:	b71fc0ef          	jal	80000cd8 <release>
}
    8000416c:	8526                	mv	a0,s1
    8000416e:	60e2                	ld	ra,24(sp)
    80004170:	6442                	ld	s0,16(sp)
    80004172:	64a2                	ld	s1,8(sp)
    80004174:	6105                	addi	sp,sp,32
    80004176:	8082                	ret

0000000080004178 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004178:	1101                	addi	sp,sp,-32
    8000417a:	ec06                	sd	ra,24(sp)
    8000417c:	e822                	sd	s0,16(sp)
    8000417e:	e426                	sd	s1,8(sp)
    80004180:	1000                	addi	s0,sp,32
    80004182:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004184:	0001c517          	auipc	a0,0x1c
    80004188:	9c450513          	addi	a0,a0,-1596 # 8001fb48 <ftable>
    8000418c:	ac1fc0ef          	jal	80000c4c <acquire>
  if (f->ref < 1)
    80004190:	40dc                	lw	a5,4(s1)
    80004192:	02f05063          	blez	a5,800041b2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004196:	2785                	addiw	a5,a5,1
    80004198:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000419a:	0001c517          	auipc	a0,0x1c
    8000419e:	9ae50513          	addi	a0,a0,-1618 # 8001fb48 <ftable>
    800041a2:	b37fc0ef          	jal	80000cd8 <release>
  return f;
}
    800041a6:	8526                	mv	a0,s1
    800041a8:	60e2                	ld	ra,24(sp)
    800041aa:	6442                	ld	s0,16(sp)
    800041ac:	64a2                	ld	s1,8(sp)
    800041ae:	6105                	addi	sp,sp,32
    800041b0:	8082                	ret
    panic("filedup");
    800041b2:	00003517          	auipc	a0,0x3
    800041b6:	3ce50513          	addi	a0,a0,974 # 80007580 <etext+0x580>
    800041ba:	e36fc0ef          	jal	800007f0 <panic>

00000000800041be <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041be:	7139                	addi	sp,sp,-64
    800041c0:	fc06                	sd	ra,56(sp)
    800041c2:	f822                	sd	s0,48(sp)
    800041c4:	f426                	sd	s1,40(sp)
    800041c6:	0080                	addi	s0,sp,64
    800041c8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041ca:	0001c517          	auipc	a0,0x1c
    800041ce:	97e50513          	addi	a0,a0,-1666 # 8001fb48 <ftable>
    800041d2:	a7bfc0ef          	jal	80000c4c <acquire>
  if (f->ref < 1)
    800041d6:	40dc                	lw	a5,4(s1)
    800041d8:	04f05a63          	blez	a5,8000422c <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800041dc:	37fd                	addiw	a5,a5,-1
    800041de:	0007871b          	sext.w	a4,a5
    800041e2:	c0dc                	sw	a5,4(s1)
    800041e4:	04e04e63          	bgtz	a4,80004240 <fileclose+0x82>
    800041e8:	f04a                	sd	s2,32(sp)
    800041ea:	ec4e                	sd	s3,24(sp)
    800041ec:	e852                	sd	s4,16(sp)
    800041ee:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041f0:	0004a903          	lw	s2,0(s1)
    800041f4:	0094ca83          	lbu	s5,9(s1)
    800041f8:	0104ba03          	ld	s4,16(s1)
    800041fc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004200:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004204:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004208:	0001c517          	auipc	a0,0x1c
    8000420c:	94050513          	addi	a0,a0,-1728 # 8001fb48 <ftable>
    80004210:	ac9fc0ef          	jal	80000cd8 <release>

  if (ff.type == FD_PIPE) {
    80004214:	4785                	li	a5,1
    80004216:	04f90063          	beq	s2,a5,80004256 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000421a:	3979                	addiw	s2,s2,-2
    8000421c:	4785                	li	a5,1
    8000421e:	0527f563          	bgeu	a5,s2,80004268 <fileclose+0xaa>
    80004222:	7902                	ld	s2,32(sp)
    80004224:	69e2                	ld	s3,24(sp)
    80004226:	6a42                	ld	s4,16(sp)
    80004228:	6aa2                	ld	s5,8(sp)
    8000422a:	a00d                	j	8000424c <fileclose+0x8e>
    8000422c:	f04a                	sd	s2,32(sp)
    8000422e:	ec4e                	sd	s3,24(sp)
    80004230:	e852                	sd	s4,16(sp)
    80004232:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004234:	00003517          	auipc	a0,0x3
    80004238:	35450513          	addi	a0,a0,852 # 80007588 <etext+0x588>
    8000423c:	db4fc0ef          	jal	800007f0 <panic>
    release(&ftable.lock);
    80004240:	0001c517          	auipc	a0,0x1c
    80004244:	90850513          	addi	a0,a0,-1784 # 8001fb48 <ftable>
    80004248:	a91fc0ef          	jal	80000cd8 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000424c:	70e2                	ld	ra,56(sp)
    8000424e:	7442                	ld	s0,48(sp)
    80004250:	74a2                	ld	s1,40(sp)
    80004252:	6121                	addi	sp,sp,64
    80004254:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004256:	85d6                	mv	a1,s5
    80004258:	8552                	mv	a0,s4
    8000425a:	34c000ef          	jal	800045a6 <pipeclose>
    8000425e:	7902                	ld	s2,32(sp)
    80004260:	69e2                	ld	s3,24(sp)
    80004262:	6a42                	ld	s4,16(sp)
    80004264:	6aa2                	ld	s5,8(sp)
    80004266:	b7dd                	j	8000424c <fileclose+0x8e>
    begin_op();
    80004268:	aabff0ef          	jal	80003d12 <begin_op>
    iput(ff.ip);
    8000426c:	854e                	mv	a0,s3
    8000426e:	9dcff0ef          	jal	8000344a <iput>
    end_op();
    80004272:	b27ff0ef          	jal	80003d98 <end_op>
    80004276:	7902                	ld	s2,32(sp)
    80004278:	69e2                	ld	s3,24(sp)
    8000427a:	6a42                	ld	s4,16(sp)
    8000427c:	6aa2                	ld	s5,8(sp)
    8000427e:	b7f9                	j	8000424c <fileclose+0x8e>

0000000080004280 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004280:	715d                	addi	sp,sp,-80
    80004282:	e486                	sd	ra,72(sp)
    80004284:	e0a2                	sd	s0,64(sp)
    80004286:	fc26                	sd	s1,56(sp)
    80004288:	f44e                	sd	s3,40(sp)
    8000428a:	0880                	addi	s0,sp,80
    8000428c:	84aa                	mv	s1,a0
    8000428e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004290:	ee8fd0ef          	jal	80001978 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004294:	409c                	lw	a5,0(s1)
    80004296:	37f9                	addiw	a5,a5,-2
    80004298:	4705                	li	a4,1
    8000429a:	04f76263          	bltu	a4,a5,800042de <filestat+0x5e>
    8000429e:	f84a                	sd	s2,48(sp)
    800042a0:	892a                	mv	s2,a0
    ilock(f->ip);
    800042a2:	6c88                	ld	a0,24(s1)
    800042a4:	824ff0ef          	jal	800032c8 <ilock>
    stati(f->ip, &st);
    800042a8:	fb840593          	addi	a1,s0,-72
    800042ac:	6c88                	ld	a0,24(s1)
    800042ae:	bc8ff0ef          	jal	80003676 <stati>
    iunlock(f->ip);
    800042b2:	6c88                	ld	a0,24(s1)
    800042b4:	8c2ff0ef          	jal	80003376 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800042b8:	4761                	li	a4,24
    800042ba:	fb840693          	addi	a3,s0,-72
    800042be:	864e                	mv	a2,s3
    800042c0:	04893583          	ld	a1,72(s2)
    800042c4:	05093503          	ld	a0,80(s2)
    800042c8:	ae6fd0ef          	jal	800015ae <copyout>
    800042cc:	41f5551b          	sraiw	a0,a0,0x1f
    800042d0:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800042d2:	60a6                	ld	ra,72(sp)
    800042d4:	6406                	ld	s0,64(sp)
    800042d6:	74e2                	ld	s1,56(sp)
    800042d8:	79a2                	ld	s3,40(sp)
    800042da:	6161                	addi	sp,sp,80
    800042dc:	8082                	ret
  return -1;
    800042de:	557d                	li	a0,-1
    800042e0:	bfcd                	j	800042d2 <filestat+0x52>

00000000800042e2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042e2:	7179                	addi	sp,sp,-48
    800042e4:	f406                	sd	ra,40(sp)
    800042e6:	f022                	sd	s0,32(sp)
    800042e8:	e84a                	sd	s2,16(sp)
    800042ea:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800042ec:	00854783          	lbu	a5,8(a0)
    800042f0:	c3c5                	beqz	a5,80004390 <fileread+0xae>
    800042f2:	ec26                	sd	s1,24(sp)
    800042f4:	e44e                	sd	s3,8(sp)
    800042f6:	84aa                	mv	s1,a0
    800042f8:	89ae                	mv	s3,a1
    800042fa:	8932                	mv	s2,a2
    800042fc:	08064c63          	bltz	a2,80004394 <fileread+0xb2>
    return -1;

  if (f->type == FD_PIPE) {
    80004300:	411c                	lw	a5,0(a0)
    80004302:	4705                	li	a4,1
    80004304:	04e78363          	beq	a5,a4,8000434a <fileread+0x68>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004308:	470d                	li	a4,3
    8000430a:	04e78763          	beq	a5,a4,80004358 <fileread+0x76>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000430e:	4709                	li	a4,2
    80004310:	06e79a63          	bne	a5,a4,80004384 <fileread+0xa2>
    ilock(f->ip);
    80004314:	6d08                	ld	a0,24(a0)
    80004316:	fb3fe0ef          	jal	800032c8 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000431a:	874a                	mv	a4,s2
    8000431c:	5094                	lw	a3,32(s1)
    8000431e:	864e                	mv	a2,s3
    80004320:	4585                	li	a1,1
    80004322:	6c88                	ld	a0,24(s1)
    80004324:	b7cff0ef          	jal	800036a0 <readi>
    80004328:	892a                	mv	s2,a0
    8000432a:	00a05563          	blez	a0,80004334 <fileread+0x52>
      f->off += r;
    8000432e:	509c                	lw	a5,32(s1)
    80004330:	9fa9                	addw	a5,a5,a0
    80004332:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004334:	6c88                	ld	a0,24(s1)
    80004336:	840ff0ef          	jal	80003376 <iunlock>
    8000433a:	64e2                	ld	s1,24(sp)
    8000433c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000433e:	854a                	mv	a0,s2
    80004340:	70a2                	ld	ra,40(sp)
    80004342:	7402                	ld	s0,32(sp)
    80004344:	6942                	ld	s2,16(sp)
    80004346:	6145                	addi	sp,sp,48
    80004348:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000434a:	6908                	ld	a0,16(a0)
    8000434c:	3b6000ef          	jal	80004702 <piperead>
    80004350:	892a                	mv	s2,a0
    80004352:	64e2                	ld	s1,24(sp)
    80004354:	69a2                	ld	s3,8(sp)
    80004356:	b7e5                	j	8000433e <fileread+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004358:	02451783          	lh	a5,36(a0)
    8000435c:	03079693          	slli	a3,a5,0x30
    80004360:	92c1                	srli	a3,a3,0x30
    80004362:	4725                	li	a4,9
    80004364:	02d76c63          	bltu	a4,a3,8000439c <fileread+0xba>
    80004368:	0792                	slli	a5,a5,0x4
    8000436a:	0001b717          	auipc	a4,0x1b
    8000436e:	73e70713          	addi	a4,a4,1854 # 8001faa8 <devsw>
    80004372:	97ba                	add	a5,a5,a4
    80004374:	639c                	ld	a5,0(a5)
    80004376:	c79d                	beqz	a5,800043a4 <fileread+0xc2>
    r = devsw[f->major].read(1, addr, n);
    80004378:	4505                	li	a0,1
    8000437a:	9782                	jalr	a5
    8000437c:	892a                	mv	s2,a0
    8000437e:	64e2                	ld	s1,24(sp)
    80004380:	69a2                	ld	s3,8(sp)
    80004382:	bf75                	j	8000433e <fileread+0x5c>
    panic("fileread");
    80004384:	00003517          	auipc	a0,0x3
    80004388:	21450513          	addi	a0,a0,532 # 80007598 <etext+0x598>
    8000438c:	c64fc0ef          	jal	800007f0 <panic>
    return -1;
    80004390:	597d                	li	s2,-1
    80004392:	b775                	j	8000433e <fileread+0x5c>
    80004394:	597d                	li	s2,-1
    80004396:	64e2                	ld	s1,24(sp)
    80004398:	69a2                	ld	s3,8(sp)
    8000439a:	b755                	j	8000433e <fileread+0x5c>
      return -1;
    8000439c:	597d                	li	s2,-1
    8000439e:	64e2                	ld	s1,24(sp)
    800043a0:	69a2                	ld	s3,8(sp)
    800043a2:	bf71                	j	8000433e <fileread+0x5c>
    800043a4:	597d                	li	s2,-1
    800043a6:	64e2                	ld	s1,24(sp)
    800043a8:	69a2                	ld	s3,8(sp)
    800043aa:	bf51                	j	8000433e <fileread+0x5c>

00000000800043ac <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800043ac:	00954783          	lbu	a5,9(a0)
    800043b0:	10078663          	beqz	a5,800044bc <filewrite+0x110>
{
    800043b4:	715d                	addi	sp,sp,-80
    800043b6:	e486                	sd	ra,72(sp)
    800043b8:	e0a2                	sd	s0,64(sp)
    800043ba:	f84a                	sd	s2,48(sp)
    800043bc:	f052                	sd	s4,32(sp)
    800043be:	e85a                	sd	s6,16(sp)
    800043c0:	0880                	addi	s0,sp,80
    800043c2:	892a                	mv	s2,a0
    800043c4:	8b2e                	mv	s6,a1
    800043c6:	8a32                	mv	s4,a2
  if (f->writable == 0 || n < 0)
    800043c8:	0e064c63          	bltz	a2,800044c0 <filewrite+0x114>
    return -1;

  if (f->type == FD_PIPE) {
    800043cc:	411c                	lw	a5,0(a0)
    800043ce:	4705                	li	a4,1
    800043d0:	02e78763          	beq	a5,a4,800043fe <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800043d4:	470d                	li	a4,3
    800043d6:	02e78863          	beq	a5,a4,80004406 <filewrite+0x5a>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800043da:	4709                	li	a4,2
    800043dc:	0ce79563          	bne	a5,a4,800044a6 <filewrite+0xfa>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800043e0:	0ec05663          	blez	a2,800044cc <filewrite+0x120>
    800043e4:	fc26                	sd	s1,56(sp)
    800043e6:	f44e                	sd	s3,40(sp)
    800043e8:	ec56                	sd	s5,24(sp)
    800043ea:	e45e                	sd	s7,8(sp)
    800043ec:	e062                	sd	s8,0(sp)
    int i = 0;
    800043ee:	4981                	li	s3,0
      int n1 = n - i;
      if (n1 > max)
    800043f0:	6b85                	lui	s7,0x1
    800043f2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800043f6:	6c05                	lui	s8,0x1
    800043f8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800043fc:	a8b5                	j	80004478 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800043fe:	6908                	ld	a0,16(a0)
    80004400:	1fe000ef          	jal	800045fe <pipewrite>
    80004404:	a851                	j	80004498 <filewrite+0xec>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004406:	02451783          	lh	a5,36(a0)
    8000440a:	03079693          	slli	a3,a5,0x30
    8000440e:	92c1                	srli	a3,a3,0x30
    80004410:	4725                	li	a4,9
    80004412:	0ad76963          	bltu	a4,a3,800044c4 <filewrite+0x118>
    80004416:	0792                	slli	a5,a5,0x4
    80004418:	0001b717          	auipc	a4,0x1b
    8000441c:	69070713          	addi	a4,a4,1680 # 8001faa8 <devsw>
    80004420:	97ba                	add	a5,a5,a4
    80004422:	679c                	ld	a5,8(a5)
    80004424:	c3d5                	beqz	a5,800044c8 <filewrite+0x11c>
    ret = devsw[f->major].write(1, addr, n);
    80004426:	4505                	li	a0,1
    80004428:	9782                	jalr	a5
    8000442a:	a0bd                	j	80004498 <filewrite+0xec>
      if (n1 > max)
    8000442c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004430:	8e3ff0ef          	jal	80003d12 <begin_op>
      ilock(f->ip);
    80004434:	01893503          	ld	a0,24(s2)
    80004438:	e91fe0ef          	jal	800032c8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000443c:	8756                	mv	a4,s5
    8000443e:	02092683          	lw	a3,32(s2)
    80004442:	01698633          	add	a2,s3,s6
    80004446:	4585                	li	a1,1
    80004448:	01893503          	ld	a0,24(s2)
    8000444c:	b50ff0ef          	jal	8000379c <writei>
    80004450:	84aa                	mv	s1,a0
    80004452:	00a05763          	blez	a0,80004460 <filewrite+0xb4>
        f->off += r;
    80004456:	02092783          	lw	a5,32(s2)
    8000445a:	9fa9                	addw	a5,a5,a0
    8000445c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004460:	01893503          	ld	a0,24(s2)
    80004464:	f13fe0ef          	jal	80003376 <iunlock>
      end_op();
    80004468:	931ff0ef          	jal	80003d98 <end_op>

      if (r != n1) {
    8000446c:	009a9e63          	bne	s5,s1,80004488 <filewrite+0xdc>
        // error from writei
        break;
      }
      i += r;
    80004470:	013489bb          	addw	s3,s1,s3
    while (i < n) {
    80004474:	0149da63          	bge	s3,s4,80004488 <filewrite+0xdc>
      int n1 = n - i;
    80004478:	413a04bb          	subw	s1,s4,s3
      if (n1 > max)
    8000447c:	0004879b          	sext.w	a5,s1
    80004480:	fafbd6e3          	bge	s7,a5,8000442c <filewrite+0x80>
    80004484:	84e2                	mv	s1,s8
    80004486:	b75d                	j	8000442c <filewrite+0x80>
    }
    ret = (i == n ? n : -1);
    80004488:	053a1463          	bne	s4,s3,800044d0 <filewrite+0x124>
    8000448c:	8552                	mv	a0,s4
    8000448e:	74e2                	ld	s1,56(sp)
    80004490:	79a2                	ld	s3,40(sp)
    80004492:	6ae2                	ld	s5,24(sp)
    80004494:	6ba2                	ld	s7,8(sp)
    80004496:	6c02                	ld	s8,0(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004498:	60a6                	ld	ra,72(sp)
    8000449a:	6406                	ld	s0,64(sp)
    8000449c:	7942                	ld	s2,48(sp)
    8000449e:	7a02                	ld	s4,32(sp)
    800044a0:	6b42                	ld	s6,16(sp)
    800044a2:	6161                	addi	sp,sp,80
    800044a4:	8082                	ret
    800044a6:	fc26                	sd	s1,56(sp)
    800044a8:	f44e                	sd	s3,40(sp)
    800044aa:	ec56                	sd	s5,24(sp)
    800044ac:	e45e                	sd	s7,8(sp)
    800044ae:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800044b0:	00003517          	auipc	a0,0x3
    800044b4:	0f850513          	addi	a0,a0,248 # 800075a8 <etext+0x5a8>
    800044b8:	b38fc0ef          	jal	800007f0 <panic>
    return -1;
    800044bc:	557d                	li	a0,-1
}
    800044be:	8082                	ret
    return -1;
    800044c0:	557d                	li	a0,-1
    800044c2:	bfd9                	j	80004498 <filewrite+0xec>
      return -1;
    800044c4:	557d                	li	a0,-1
    800044c6:	bfc9                	j	80004498 <filewrite+0xec>
    800044c8:	557d                	li	a0,-1
    800044ca:	b7f9                	j	80004498 <filewrite+0xec>
    ret = (i == n ? n : -1);
    800044cc:	8532                	mv	a0,a2
    800044ce:	b7e9                	j	80004498 <filewrite+0xec>
    800044d0:	557d                	li	a0,-1
    800044d2:	74e2                	ld	s1,56(sp)
    800044d4:	79a2                	ld	s3,40(sp)
    800044d6:	6ae2                	ld	s5,24(sp)
    800044d8:	6ba2                	ld	s7,8(sp)
    800044da:	6c02                	ld	s8,0(sp)
    800044dc:	bf75                	j	80004498 <filewrite+0xec>

00000000800044de <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044de:	7179                	addi	sp,sp,-48
    800044e0:	f406                	sd	ra,40(sp)
    800044e2:	f022                	sd	s0,32(sp)
    800044e4:	ec26                	sd	s1,24(sp)
    800044e6:	e052                	sd	s4,0(sp)
    800044e8:	1800                	addi	s0,sp,48
    800044ea:	84aa                	mv	s1,a0
    800044ec:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044ee:	0005b023          	sd	zero,0(a1)
    800044f2:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044f6:	c25ff0ef          	jal	8000411a <filealloc>
    800044fa:	e088                	sd	a0,0(s1)
    800044fc:	c549                	beqz	a0,80004586 <pipealloc+0xa8>
    800044fe:	c1dff0ef          	jal	8000411a <filealloc>
    80004502:	00aa3023          	sd	a0,0(s4)
    80004506:	cd25                	beqz	a0,8000457e <pipealloc+0xa0>
    80004508:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000450a:	dc0fc0ef          	jal	80000aca <kalloc>
    8000450e:	892a                	mv	s2,a0
    80004510:	c12d                	beqz	a0,80004572 <pipealloc+0x94>
    80004512:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004514:	4985                	li	s3,1
    80004516:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000451a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000451e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004522:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004526:	00003597          	auipc	a1,0x3
    8000452a:	09258593          	addi	a1,a1,146 # 800075b8 <etext+0x5b8>
    8000452e:	ea8fc0ef          	jal	80000bd6 <initlock>
  (*f0)->type = FD_PIPE;
    80004532:	609c                	ld	a5,0(s1)
    80004534:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004538:	609c                	ld	a5,0(s1)
    8000453a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000453e:	609c                	ld	a5,0(s1)
    80004540:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004544:	609c                	ld	a5,0(s1)
    80004546:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000454a:	000a3783          	ld	a5,0(s4)
    8000454e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004552:	000a3783          	ld	a5,0(s4)
    80004556:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000455a:	000a3783          	ld	a5,0(s4)
    8000455e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004562:	000a3783          	ld	a5,0(s4)
    80004566:	0127b823          	sd	s2,16(a5)
  return 0;
    8000456a:	4501                	li	a0,0
    8000456c:	6942                	ld	s2,16(sp)
    8000456e:	69a2                	ld	s3,8(sp)
    80004570:	a01d                	j	80004596 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004572:	6088                	ld	a0,0(s1)
    80004574:	c119                	beqz	a0,8000457a <pipealloc+0x9c>
    80004576:	6942                	ld	s2,16(sp)
    80004578:	a029                	j	80004582 <pipealloc+0xa4>
    8000457a:	6942                	ld	s2,16(sp)
    8000457c:	a029                	j	80004586 <pipealloc+0xa8>
    8000457e:	6088                	ld	a0,0(s1)
    80004580:	c10d                	beqz	a0,800045a2 <pipealloc+0xc4>
    fileclose(*f0);
    80004582:	c3dff0ef          	jal	800041be <fileclose>
  if (*f1)
    80004586:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000458a:	557d                	li	a0,-1
  if (*f1)
    8000458c:	c789                	beqz	a5,80004596 <pipealloc+0xb8>
    fileclose(*f1);
    8000458e:	853e                	mv	a0,a5
    80004590:	c2fff0ef          	jal	800041be <fileclose>
  return -1;
    80004594:	557d                	li	a0,-1
}
    80004596:	70a2                	ld	ra,40(sp)
    80004598:	7402                	ld	s0,32(sp)
    8000459a:	64e2                	ld	s1,24(sp)
    8000459c:	6a02                	ld	s4,0(sp)
    8000459e:	6145                	addi	sp,sp,48
    800045a0:	8082                	ret
  return -1;
    800045a2:	557d                	li	a0,-1
    800045a4:	bfcd                	j	80004596 <pipealloc+0xb8>

00000000800045a6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800045a6:	1101                	addi	sp,sp,-32
    800045a8:	ec06                	sd	ra,24(sp)
    800045aa:	e822                	sd	s0,16(sp)
    800045ac:	e426                	sd	s1,8(sp)
    800045ae:	e04a                	sd	s2,0(sp)
    800045b0:	1000                	addi	s0,sp,32
    800045b2:	84aa                	mv	s1,a0
    800045b4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800045b6:	e96fc0ef          	jal	80000c4c <acquire>
  if (writable) {
    800045ba:	02090763          	beqz	s2,800045e8 <pipeclose+0x42>
    pi->writeopen = 0;
    800045be:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800045c2:	21848513          	addi	a0,s1,536
    800045c6:	a23fd0ef          	jal	80001fe8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800045ca:	2204b783          	ld	a5,544(s1)
    800045ce:	e785                	bnez	a5,800045f6 <pipeclose+0x50>
    release(&pi->lock);
    800045d0:	8526                	mv	a0,s1
    800045d2:	f06fc0ef          	jal	80000cd8 <release>
    kfree((char *)pi);
    800045d6:	8526                	mv	a0,s1
    800045d8:	c10fc0ef          	jal	800009e8 <kfree>
  } else
    release(&pi->lock);
}
    800045dc:	60e2                	ld	ra,24(sp)
    800045de:	6442                	ld	s0,16(sp)
    800045e0:	64a2                	ld	s1,8(sp)
    800045e2:	6902                	ld	s2,0(sp)
    800045e4:	6105                	addi	sp,sp,32
    800045e6:	8082                	ret
    pi->readopen = 0;
    800045e8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045ec:	21c48513          	addi	a0,s1,540
    800045f0:	9f9fd0ef          	jal	80001fe8 <wakeup>
    800045f4:	bfd9                	j	800045ca <pipeclose+0x24>
    release(&pi->lock);
    800045f6:	8526                	mv	a0,s1
    800045f8:	ee0fc0ef          	jal	80000cd8 <release>
}
    800045fc:	b7c5                	j	800045dc <pipeclose+0x36>

00000000800045fe <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045fe:	711d                	addi	sp,sp,-96
    80004600:	ec86                	sd	ra,88(sp)
    80004602:	e8a2                	sd	s0,80(sp)
    80004604:	e4a6                	sd	s1,72(sp)
    80004606:	e0ca                	sd	s2,64(sp)
    80004608:	fc4e                	sd	s3,56(sp)
    8000460a:	f852                	sd	s4,48(sp)
    8000460c:	f456                	sd	s5,40(sp)
    8000460e:	1080                	addi	s0,sp,96
    80004610:	84aa                	mv	s1,a0
    80004612:	8aae                	mv	s5,a1
    80004614:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004616:	b62fd0ef          	jal	80001978 <myproc>
    8000461a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000461c:	8526                	mv	a0,s1
    8000461e:	e2efc0ef          	jal	80000c4c <acquire>
  while (i < n) {
    80004622:	0d405e63          	blez	s4,800046fe <pipewrite+0x100>
    80004626:	f05a                	sd	s6,32(sp)
    80004628:	ec5e                	sd	s7,24(sp)
    8000462a:	e862                	sd	s8,16(sp)
  int i = 0;
    8000462c:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000462e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004630:	21848c13          	addi	s8,s1,536
      sleep_prepare(&pi->nwrite);
    80004634:	21c48b93          	addi	s7,s1,540
    80004638:	a091                	j	8000467c <pipewrite+0x7e>
      release(&pi->lock);
    8000463a:	8526                	mv	a0,s1
    8000463c:	e9cfc0ef          	jal	80000cd8 <release>
      return -1;
    80004640:	597d                	li	s2,-1
    80004642:	7b02                	ld	s6,32(sp)
    80004644:	6be2                	ld	s7,24(sp)
    80004646:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004648:	854a                	mv	a0,s2
    8000464a:	60e6                	ld	ra,88(sp)
    8000464c:	6446                	ld	s0,80(sp)
    8000464e:	64a6                	ld	s1,72(sp)
    80004650:	6906                	ld	s2,64(sp)
    80004652:	79e2                	ld	s3,56(sp)
    80004654:	7a42                	ld	s4,48(sp)
    80004656:	7aa2                	ld	s5,40(sp)
    80004658:	6125                	addi	sp,sp,96
    8000465a:	8082                	ret
      wakeup(&pi->nread);
    8000465c:	8562                	mv	a0,s8
    8000465e:	98bfd0ef          	jal	80001fe8 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004662:	855e                	mv	a0,s7
    80004664:	919fd0ef          	jal	80001f7c <sleep_prepare>
      release(&pi->lock);
    80004668:	8526                	mv	a0,s1
    8000466a:	e6efc0ef          	jal	80000cd8 <release>
      sleep();
    8000466e:	94bfd0ef          	jal	80001fb8 <sleep>
      acquire(&pi->lock);
    80004672:	8526                	mv	a0,s1
    80004674:	dd8fc0ef          	jal	80000c4c <acquire>
  while (i < n) {
    80004678:	07495863          	bge	s2,s4,800046e8 <pipewrite+0xea>
    if (pi->readopen == 0 || killed(pr)) {
    8000467c:	2204a783          	lw	a5,544(s1)
    80004680:	dfcd                	beqz	a5,8000463a <pipewrite+0x3c>
    80004682:	854e                	mv	a0,s3
    80004684:	b53fd0ef          	jal	800021d6 <killed>
    80004688:	f94d                	bnez	a0,8000463a <pipewrite+0x3c>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000468a:	2184a783          	lw	a5,536(s1)
    8000468e:	21c4a703          	lw	a4,540(s1)
    80004692:	2007879b          	addiw	a5,a5,512
    80004696:	fcf703e3          	beq	a4,a5,8000465c <pipewrite+0x5e>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    8000469a:	4705                	li	a4,1
    8000469c:	015906b3          	add	a3,s2,s5
    800046a0:	faf40613          	addi	a2,s0,-81
    800046a4:	0489b583          	ld	a1,72(s3)
    800046a8:	0509b503          	ld	a0,80(s3)
    800046ac:	feffc0ef          	jal	8000169a <copyin>
    800046b0:	03650163          	beq	a0,s6,800046d2 <pipewrite+0xd4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800046b4:	21c4a783          	lw	a5,540(s1)
    800046b8:	0017871b          	addiw	a4,a5,1
    800046bc:	20e4ae23          	sw	a4,540(s1)
    800046c0:	1ff7f793          	andi	a5,a5,511
    800046c4:	97a6                	add	a5,a5,s1
    800046c6:	faf44703          	lbu	a4,-81(s0)
    800046ca:	00e78c23          	sb	a4,24(a5)
      i++;
    800046ce:	2905                	addiw	s2,s2,1
    800046d0:	b765                	j	80004678 <pipewrite+0x7a>
        if (i == 0)
    800046d2:	00090663          	beqz	s2,800046de <pipewrite+0xe0>
    800046d6:	7b02                	ld	s6,32(sp)
    800046d8:	6be2                	ld	s7,24(sp)
    800046da:	6c42                	ld	s8,16(sp)
    800046dc:	a809                	j	800046ee <pipewrite+0xf0>
          i = -1;
    800046de:	892a                	mv	s2,a0
        break;
    800046e0:	7b02                	ld	s6,32(sp)
    800046e2:	6be2                	ld	s7,24(sp)
    800046e4:	6c42                	ld	s8,16(sp)
    800046e6:	a021                	j	800046ee <pipewrite+0xf0>
    800046e8:	7b02                	ld	s6,32(sp)
    800046ea:	6be2                	ld	s7,24(sp)
    800046ec:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800046ee:	21848513          	addi	a0,s1,536
    800046f2:	8f7fd0ef          	jal	80001fe8 <wakeup>
  release(&pi->lock);
    800046f6:	8526                	mv	a0,s1
    800046f8:	de0fc0ef          	jal	80000cd8 <release>
  return i;
    800046fc:	b7b1                	j	80004648 <pipewrite+0x4a>
  int i = 0;
    800046fe:	4901                	li	s2,0
    80004700:	b7fd                	j	800046ee <pipewrite+0xf0>

0000000080004702 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004702:	715d                	addi	sp,sp,-80
    80004704:	e486                	sd	ra,72(sp)
    80004706:	e0a2                	sd	s0,64(sp)
    80004708:	fc26                	sd	s1,56(sp)
    8000470a:	f84a                	sd	s2,48(sp)
    8000470c:	f44e                	sd	s3,40(sp)
    8000470e:	f052                	sd	s4,32(sp)
    80004710:	ec56                	sd	s5,24(sp)
    80004712:	0880                	addi	s0,sp,80
    80004714:	84aa                	mv	s1,a0
    80004716:	89ae                	mv	s3,a1
    80004718:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000471a:	a5efd0ef          	jal	80001978 <myproc>
    8000471e:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004720:	8526                	mv	a0,s1
    80004722:	d2afc0ef          	jal	80000c4c <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004726:	2184a703          	lw	a4,536(s1)
    8000472a:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    8000472e:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004732:	02f71c63          	bne	a4,a5,8000476a <piperead+0x68>
    80004736:	2244a783          	lw	a5,548(s1)
    8000473a:	cf9d                	beqz	a5,80004778 <piperead+0x76>
    if (killed(pr)) {
    8000473c:	854a                	mv	a0,s2
    8000473e:	a99fd0ef          	jal	800021d6 <killed>
    80004742:	e515                	bnez	a0,8000476e <piperead+0x6c>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004744:	8552                	mv	a0,s4
    80004746:	837fd0ef          	jal	80001f7c <sleep_prepare>
    release(&pi->lock);
    8000474a:	8526                	mv	a0,s1
    8000474c:	d8cfc0ef          	jal	80000cd8 <release>
    sleep();
    80004750:	869fd0ef          	jal	80001fb8 <sleep>
    acquire(&pi->lock);
    80004754:	8526                	mv	a0,s1
    80004756:	cf6fc0ef          	jal	80000c4c <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000475a:	2184a703          	lw	a4,536(s1)
    8000475e:	21c4a783          	lw	a5,540(s1)
    80004762:	fcf70ae3          	beq	a4,a5,80004736 <piperead+0x34>
    80004766:	e85a                	sd	s6,16(sp)
    80004768:	a809                	j	8000477a <piperead+0x78>
    8000476a:	e85a                	sd	s6,16(sp)
    8000476c:	a039                	j	8000477a <piperead+0x78>
      release(&pi->lock);
    8000476e:	8526                	mv	a0,s1
    80004770:	d68fc0ef          	jal	80000cd8 <release>
      return -1;
    80004774:	5a7d                	li	s4,-1
    80004776:	a08d                	j	800047d8 <piperead+0xd6>
    80004778:	e85a                	sd	s6,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000477a:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000477c:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    8000477e:	05505563          	blez	s5,800047c8 <piperead+0xc6>
    if (pi->nread == pi->nwrite)
    80004782:	2184a783          	lw	a5,536(s1)
    80004786:	21c4a703          	lw	a4,540(s1)
    8000478a:	02f70f63          	beq	a4,a5,800047c8 <piperead+0xc6>
    ch = pi->data[pi->nread % PIPESIZE];
    8000478e:	1ff7f793          	andi	a5,a5,511
    80004792:	97a6                	add	a5,a5,s1
    80004794:	0187c783          	lbu	a5,24(a5)
    80004798:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    8000479c:	4705                	li	a4,1
    8000479e:	fbf40693          	addi	a3,s0,-65
    800047a2:	864e                	mv	a2,s3
    800047a4:	04893583          	ld	a1,72(s2)
    800047a8:	05093503          	ld	a0,80(s2)
    800047ac:	e03fc0ef          	jal	800015ae <copyout>
    800047b0:	03650e63          	beq	a0,s6,800047ec <piperead+0xea>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800047b4:	2184a783          	lw	a5,536(s1)
    800047b8:	2785                	addiw	a5,a5,1
    800047ba:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800047be:	2a05                	addiw	s4,s4,1
    800047c0:	0985                	addi	s3,s3,1
    800047c2:	fd4a90e3          	bne	s5,s4,80004782 <piperead+0x80>
    800047c6:	8a56                	mv	s4,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800047c8:	21c48513          	addi	a0,s1,540
    800047cc:	81dfd0ef          	jal	80001fe8 <wakeup>
  release(&pi->lock);
    800047d0:	8526                	mv	a0,s1
    800047d2:	d06fc0ef          	jal	80000cd8 <release>
    800047d6:	6b42                	ld	s6,16(sp)
  return i;
}
    800047d8:	8552                	mv	a0,s4
    800047da:	60a6                	ld	ra,72(sp)
    800047dc:	6406                	ld	s0,64(sp)
    800047de:	74e2                	ld	s1,56(sp)
    800047e0:	7942                	ld	s2,48(sp)
    800047e2:	79a2                	ld	s3,40(sp)
    800047e4:	7a02                	ld	s4,32(sp)
    800047e6:	6ae2                	ld	s5,24(sp)
    800047e8:	6161                	addi	sp,sp,80
    800047ea:	8082                	ret
      if (i == 0)
    800047ec:	fc0a1ee3          	bnez	s4,800047c8 <piperead+0xc6>
        i = -1;
    800047f0:	8a2a                	mv	s4,a0
    800047f2:	bfd9                	j	800047c8 <piperead+0xc6>

00000000800047f4 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    800047f4:	1141                	addi	sp,sp,-16
    800047f6:	e422                	sd	s0,8(sp)
    800047f8:	0800                	addi	s0,sp,16
    800047fa:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    800047fc:	8905                	andi	a0,a0,1
    800047fe:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004800:	8b89                	andi	a5,a5,2
    80004802:	c399                	beqz	a5,80004808 <flags2perm+0x14>
    perm |= PTE_W;
    80004804:	00456513          	ori	a0,a0,4
  return perm;
}
    80004808:	6422                	ld	s0,8(sp)
    8000480a:	0141                	addi	sp,sp,16
    8000480c:	8082                	ret

000000008000480e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000480e:	df010113          	addi	sp,sp,-528
    80004812:	20113423          	sd	ra,520(sp)
    80004816:	20813023          	sd	s0,512(sp)
    8000481a:	ffa6                	sd	s1,504(sp)
    8000481c:	fbca                	sd	s2,496(sp)
    8000481e:	0c00                	addi	s0,sp,528
    80004820:	892a                	mv	s2,a0
    80004822:	dea43c23          	sd	a0,-520(s0)
    80004826:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000482a:	94efd0ef          	jal	80001978 <myproc>
    8000482e:	84aa                	mv	s1,a0

  begin_op();
    80004830:	ce2ff0ef          	jal	80003d12 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004834:	854a                	mv	a0,s2
    80004836:	b08ff0ef          	jal	80003b3e <namei>
    8000483a:	c931                	beqz	a0,8000488e <kexec+0x80>
    8000483c:	f3d2                	sd	s4,480(sp)
    8000483e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004840:	a89fe0ef          	jal	800032c8 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004844:	04000713          	li	a4,64
    80004848:	4681                	li	a3,0
    8000484a:	e5040613          	addi	a2,s0,-432
    8000484e:	4581                	li	a1,0
    80004850:	8552                	mv	a0,s4
    80004852:	e4ffe0ef          	jal	800036a0 <readi>
    80004856:	04000793          	li	a5,64
    8000485a:	00f51a63          	bne	a0,a5,8000486e <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    8000485e:	e5042703          	lw	a4,-432(s0)
    80004862:	464c47b7          	lui	a5,0x464c4
    80004866:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000486a:	02f70663          	beq	a4,a5,80004896 <kexec+0x88>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    8000486e:	8552                	mv	a0,s4
    80004870:	cabfe0ef          	jal	8000351a <iunlockput>
    end_op();
    80004874:	d24ff0ef          	jal	80003d98 <end_op>
  }
  return -1;
    80004878:	557d                	li	a0,-1
    8000487a:	7a1e                	ld	s4,480(sp)
}
    8000487c:	20813083          	ld	ra,520(sp)
    80004880:	20013403          	ld	s0,512(sp)
    80004884:	74fe                	ld	s1,504(sp)
    80004886:	795e                	ld	s2,496(sp)
    80004888:	21010113          	addi	sp,sp,528
    8000488c:	8082                	ret
    end_op();
    8000488e:	d0aff0ef          	jal	80003d98 <end_op>
    return -1;
    80004892:	557d                	li	a0,-1
    80004894:	b7e5                	j	8000487c <kexec+0x6e>
    80004896:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004898:	8526                	mv	a0,s1
    8000489a:	9e0fd0ef          	jal	80001a7a <proc_pagetable>
    8000489e:	8b2a                	mv	s6,a0
    800048a0:	2c050963          	beqz	a0,80004b72 <kexec+0x364>
    800048a4:	f7ce                	sd	s3,488(sp)
    800048a6:	efd6                	sd	s5,472(sp)
    800048a8:	e7de                	sd	s7,456(sp)
    800048aa:	e3e2                	sd	s8,448(sp)
    800048ac:	ff66                	sd	s9,440(sp)
    800048ae:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800048b0:	e7042d03          	lw	s10,-400(s0)
    800048b4:	e8845783          	lhu	a5,-376(s0)
    800048b8:	12078863          	beqz	a5,800049e8 <kexec+0x1da>
    800048bc:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048be:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800048c0:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    800048c2:	6c85                	lui	s9,0x1
    800048c4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800048c8:	def43823          	sd	a5,-528(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800048cc:	6a85                	lui	s5,0x1
    800048ce:	a085                	j	8000492e <kexec+0x120>
      panic("loadseg: address should exist");
    800048d0:	00003517          	auipc	a0,0x3
    800048d4:	cf050513          	addi	a0,a0,-784 # 800075c0 <etext+0x5c0>
    800048d8:	f19fb0ef          	jal	800007f0 <panic>
    if (sz - i < PGSIZE)
    800048dc:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    800048de:	8726                	mv	a4,s1
    800048e0:	012c06bb          	addw	a3,s8,s2
    800048e4:	4581                	li	a1,0
    800048e6:	8552                	mv	a0,s4
    800048e8:	db9fe0ef          	jal	800036a0 <readi>
    800048ec:	2501                	sext.w	a0,a0
    800048ee:	24a49863          	bne	s1,a0,80004b3e <kexec+0x330>
  for (i = 0; i < sz; i += PGSIZE) {
    800048f2:	012a893b          	addw	s2,s5,s2
    800048f6:	03397363          	bgeu	s2,s3,8000491c <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800048fa:	02091593          	slli	a1,s2,0x20
    800048fe:	9181                	srli	a1,a1,0x20
    80004900:	95de                	add	a1,a1,s7
    80004902:	855a                	mv	a0,s6
    80004904:	f22fc0ef          	jal	80001026 <walkaddr>
    80004908:	862a                	mv	a2,a0
    if (pa == 0)
    8000490a:	d179                	beqz	a0,800048d0 <kexec+0xc2>
    if (sz - i < PGSIZE)
    8000490c:	412984bb          	subw	s1,s3,s2
    80004910:	0004879b          	sext.w	a5,s1
    80004914:	fcfcf4e3          	bgeu	s9,a5,800048dc <kexec+0xce>
    80004918:	84d6                	mv	s1,s5
    8000491a:	b7c9                	j	800048dc <kexec+0xce>
    sz = sz1;
    8000491c:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004920:	2d85                	addiw	s11,s11,1
    80004922:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004926:	e8845783          	lhu	a5,-376(s0)
    8000492a:	08fdd063          	bge	s11,a5,800049aa <kexec+0x19c>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000492e:	2d01                	sext.w	s10,s10
    80004930:	03800713          	li	a4,56
    80004934:	86ea                	mv	a3,s10
    80004936:	e1840613          	addi	a2,s0,-488
    8000493a:	4581                	li	a1,0
    8000493c:	8552                	mv	a0,s4
    8000493e:	d63fe0ef          	jal	800036a0 <readi>
    80004942:	03800793          	li	a5,56
    80004946:	1cf51463          	bne	a0,a5,80004b0e <kexec+0x300>
    if (ph.type != ELF_PROG_LOAD)
    8000494a:	e1842783          	lw	a5,-488(s0)
    8000494e:	4705                	li	a4,1
    80004950:	fce798e3          	bne	a5,a4,80004920 <kexec+0x112>
    if (ph.memsz < ph.filesz)
    80004954:	e4043483          	ld	s1,-448(s0)
    80004958:	e3843783          	ld	a5,-456(s0)
    8000495c:	1af4ed63          	bltu	s1,a5,80004b16 <kexec+0x308>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004960:	e2843783          	ld	a5,-472(s0)
    80004964:	94be                	add	s1,s1,a5
    80004966:	1af4ec63          	bltu	s1,a5,80004b1e <kexec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    8000496a:	df043703          	ld	a4,-528(s0)
    8000496e:	8ff9                	and	a5,a5,a4
    80004970:	1a079b63          	bnez	a5,80004b26 <kexec+0x318>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004974:	e1c42503          	lw	a0,-484(s0)
    80004978:	e7dff0ef          	jal	800047f4 <flags2perm>
    8000497c:	86aa                	mv	a3,a0
    8000497e:	8626                	mv	a2,s1
    80004980:	85ca                	mv	a1,s2
    80004982:	855a                	mv	a0,s6
    80004984:	98ffc0ef          	jal	80001312 <uvmalloc>
    80004988:	e0a43423          	sd	a0,-504(s0)
    8000498c:	1a050163          	beqz	a0,80004b2e <kexec+0x320>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004990:	e2843b83          	ld	s7,-472(s0)
    80004994:	e2042c03          	lw	s8,-480(s0)
    80004998:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    8000499c:	00098463          	beqz	s3,800049a4 <kexec+0x196>
    800049a0:	4901                	li	s2,0
    800049a2:	bfa1                	j	800048fa <kexec+0xec>
    sz = sz1;
    800049a4:	e0843903          	ld	s2,-504(s0)
    800049a8:	bfa5                	j	80004920 <kexec+0x112>
    800049aa:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800049ac:	8552                	mv	a0,s4
    800049ae:	b6dfe0ef          	jal	8000351a <iunlockput>
  end_op();
    800049b2:	be6ff0ef          	jal	80003d98 <end_op>
  p = myproc();
    800049b6:	fc3fc0ef          	jal	80001978 <myproc>
    800049ba:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    800049bc:	04853a03          	ld	s4,72(a0)
  sz = PGROUNDUP(sz);
    800049c0:	6b85                	lui	s7,0x1
    800049c2:	1bfd                	addi	s7,s7,-1 # fff <_entry-0x7ffff001>
    800049c4:	9bca                	add	s7,s7,s2
    800049c6:	77fd                	lui	a5,0xfffff
    800049c8:	00fbfbb3          	and	s7,s7,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    800049cc:	4691                	li	a3,4
    800049ce:	6609                	lui	a2,0x2
    800049d0:	965e                	add	a2,a2,s7
    800049d2:	85de                	mv	a1,s7
    800049d4:	855a                	mv	a0,s6
    800049d6:	93dfc0ef          	jal	80001312 <uvmalloc>
    800049da:	e0a43423          	sd	a0,-504(s0)
    800049de:	e519                	bnez	a0,800049ec <kexec+0x1de>
  if (pagetable)
    800049e0:	e1743423          	sd	s7,-504(s0)
    800049e4:	4a01                	li	s4,0
    800049e6:	aaa9                	j	80004b40 <kexec+0x332>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049e8:	4901                	li	s2,0
    800049ea:	b7c9                	j	800049ac <kexec+0x19e>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    800049ec:	75f9                	lui	a1,0xffffe
    800049ee:	8baa                	mv	s7,a0
    800049f0:	95aa                	add	a1,a1,a0
    800049f2:	855a                	mv	a0,s6
    800049f4:	af5fc0ef          	jal	800014e8 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    800049f8:	7afd                	lui	s5,0xfffff
    800049fa:	9ade                	add	s5,s5,s7
  for (argc = 0; argv[argc]; argc++) {
    800049fc:	e0043783          	ld	a5,-512(s0)
    80004a00:	6388                	ld	a0,0(a5)
    80004a02:	c15d                	beqz	a0,80004aa8 <kexec+0x29a>
    80004a04:	e9040913          	addi	s2,s0,-368
    80004a08:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004a0a:	c76fc0ef          	jal	80000e80 <strlen>
    80004a0e:	0015079b          	addiw	a5,a0,1
    80004a12:	40fb87b3          	sub	a5,s7,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a16:	ff07fb93          	andi	s7,a5,-16
    if (sp < stackbase)
    80004a1a:	115bee63          	bltu	s7,s5,80004b36 <kexec+0x328>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a1e:	e0043c83          	ld	s9,-512(s0)
    80004a22:	000cbc03          	ld	s8,0(s9)
    80004a26:	8562                	mv	a0,s8
    80004a28:	c58fc0ef          	jal	80000e80 <strlen>
    80004a2c:	0015071b          	addiw	a4,a0,1
    80004a30:	86e2                	mv	a3,s8
    80004a32:	865e                	mv	a2,s7
    80004a34:	e0843583          	ld	a1,-504(s0)
    80004a38:	855a                	mv	a0,s6
    80004a3a:	b75fc0ef          	jal	800015ae <copyout>
    80004a3e:	0e054e63          	bltz	a0,80004b3a <kexec+0x32c>
    ustack[argc] = sp;
    80004a42:	01793023          	sd	s7,0(s2)
  for (argc = 0; argv[argc]; argc++) {
    80004a46:	0485                	addi	s1,s1,1
    80004a48:	008c8793          	addi	a5,s9,8
    80004a4c:	e0f43023          	sd	a5,-512(s0)
    80004a50:	008cb503          	ld	a0,8(s9)
    80004a54:	0921                	addi	s2,s2,8
    80004a56:	f955                	bnez	a0,80004a0a <kexec+0x1fc>
  ustack[argc] = 0;
    80004a58:	00349793          	slli	a5,s1,0x3
    80004a5c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde350>
    80004a60:	97a2                	add	a5,a5,s0
    80004a62:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004a66:	00148713          	addi	a4,s1,1
    80004a6a:	070e                	slli	a4,a4,0x3
    80004a6c:	40eb8933          	sub	s2,s7,a4
  sp -= sp % 16;
    80004a70:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004a74:	e0843583          	ld	a1,-504(s0)
    80004a78:	8bae                	mv	s7,a1
  if (sp < stackbase)
    80004a7a:	f75963e3          	bltu	s2,s5,800049e0 <kexec+0x1d2>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004a7e:	e9040693          	addi	a3,s0,-368
    80004a82:	864a                	mv	a2,s2
    80004a84:	855a                	mv	a0,s6
    80004a86:	b29fc0ef          	jal	800015ae <copyout>
    80004a8a:	0e054663          	bltz	a0,80004b76 <kexec+0x368>
  p->trapframe->a1 = sp;
    80004a8e:	0589b783          	ld	a5,88(s3)
    80004a92:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80004a96:	df843783          	ld	a5,-520(s0)
    80004a9a:	0007c703          	lbu	a4,0(a5)
    80004a9e:	c315                	beqz	a4,80004ac2 <kexec+0x2b4>
    80004aa0:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004aa2:	02f00693          	li	a3,47
    80004aa6:	a809                	j	80004ab8 <kexec+0x2aa>
  sp = sz;
    80004aa8:	e0843b83          	ld	s7,-504(s0)
  for (argc = 0; argv[argc]; argc++) {
    80004aac:	4481                	li	s1,0
    80004aae:	b76d                	j	80004a58 <kexec+0x24a>
  for (last = s = path; *s; s++)
    80004ab0:	0785                	addi	a5,a5,1
    80004ab2:	fff7c703          	lbu	a4,-1(a5)
    80004ab6:	c711                	beqz	a4,80004ac2 <kexec+0x2b4>
    if (*s == '/')
    80004ab8:	fed71ce3          	bne	a4,a3,80004ab0 <kexec+0x2a2>
      last = s + 1;
    80004abc:	def43c23          	sd	a5,-520(s0)
    80004ac0:	bfc5                	j	80004ab0 <kexec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ac2:	4641                	li	a2,16
    80004ac4:	df843583          	ld	a1,-520(s0)
    80004ac8:	15898513          	addi	a0,s3,344
    80004acc:	b82fc0ef          	jal	80000e4e <safestrcpy>
  oldpagetable = p->pagetable;
    80004ad0:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004ad4:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004ad8:	e0843783          	ld	a5,-504(s0)
    80004adc:	04f9b423          	sd	a5,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ae0:	0589b783          	ld	a5,88(s3)
    80004ae4:	e6843703          	ld	a4,-408(s0)
    80004ae8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004aea:	0589b783          	ld	a5,88(s3)
    80004aee:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004af2:	85d2                	mv	a1,s4
    80004af4:	80afd0ef          	jal	80001afe <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004af8:	0004851b          	sext.w	a0,s1
    80004afc:	79be                	ld	s3,488(sp)
    80004afe:	7a1e                	ld	s4,480(sp)
    80004b00:	6afe                	ld	s5,472(sp)
    80004b02:	6b5e                	ld	s6,464(sp)
    80004b04:	6bbe                	ld	s7,456(sp)
    80004b06:	6c1e                	ld	s8,448(sp)
    80004b08:	7cfa                	ld	s9,440(sp)
    80004b0a:	7d5a                	ld	s10,432(sp)
    80004b0c:	bb85                	j	8000487c <kexec+0x6e>
    80004b0e:	e1243423          	sd	s2,-504(s0)
    80004b12:	7dba                	ld	s11,424(sp)
    80004b14:	a035                	j	80004b40 <kexec+0x332>
    80004b16:	e1243423          	sd	s2,-504(s0)
    80004b1a:	7dba                	ld	s11,424(sp)
    80004b1c:	a015                	j	80004b40 <kexec+0x332>
    80004b1e:	e1243423          	sd	s2,-504(s0)
    80004b22:	7dba                	ld	s11,424(sp)
    80004b24:	a831                	j	80004b40 <kexec+0x332>
    80004b26:	e1243423          	sd	s2,-504(s0)
    80004b2a:	7dba                	ld	s11,424(sp)
    80004b2c:	a811                	j	80004b40 <kexec+0x332>
    80004b2e:	e1243423          	sd	s2,-504(s0)
    80004b32:	7dba                	ld	s11,424(sp)
    80004b34:	a031                	j	80004b40 <kexec+0x332>
  ip = 0;
    80004b36:	4a01                	li	s4,0
    80004b38:	a021                	j	80004b40 <kexec+0x332>
    80004b3a:	4a01                	li	s4,0
  if (pagetable)
    80004b3c:	a011                	j	80004b40 <kexec+0x332>
    80004b3e:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004b40:	e0843583          	ld	a1,-504(s0)
    80004b44:	855a                	mv	a0,s6
    80004b46:	fb9fc0ef          	jal	80001afe <proc_freepagetable>
  return -1;
    80004b4a:	557d                	li	a0,-1
  if (ip) {
    80004b4c:	000a1b63          	bnez	s4,80004b62 <kexec+0x354>
    80004b50:	79be                	ld	s3,488(sp)
    80004b52:	7a1e                	ld	s4,480(sp)
    80004b54:	6afe                	ld	s5,472(sp)
    80004b56:	6b5e                	ld	s6,464(sp)
    80004b58:	6bbe                	ld	s7,456(sp)
    80004b5a:	6c1e                	ld	s8,448(sp)
    80004b5c:	7cfa                	ld	s9,440(sp)
    80004b5e:	7d5a                	ld	s10,432(sp)
    80004b60:	bb31                	j	8000487c <kexec+0x6e>
    80004b62:	79be                	ld	s3,488(sp)
    80004b64:	6afe                	ld	s5,472(sp)
    80004b66:	6b5e                	ld	s6,464(sp)
    80004b68:	6bbe                	ld	s7,456(sp)
    80004b6a:	6c1e                	ld	s8,448(sp)
    80004b6c:	7cfa                	ld	s9,440(sp)
    80004b6e:	7d5a                	ld	s10,432(sp)
    80004b70:	b9fd                	j	8000486e <kexec+0x60>
    80004b72:	6b5e                	ld	s6,464(sp)
    80004b74:	b9ed                	j	8000486e <kexec+0x60>
  sz = sz1;
    80004b76:	e0843b83          	ld	s7,-504(s0)
    80004b7a:	b59d                	j	800049e0 <kexec+0x1d2>

0000000080004b7c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b7c:	7179                	addi	sp,sp,-48
    80004b7e:	f406                	sd	ra,40(sp)
    80004b80:	f022                	sd	s0,32(sp)
    80004b82:	ec26                	sd	s1,24(sp)
    80004b84:	e84a                	sd	s2,16(sp)
    80004b86:	1800                	addi	s0,sp,48
    80004b88:	892e                	mv	s2,a1
    80004b8a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b8c:	fdc40593          	addi	a1,s0,-36
    80004b90:	d23fd0ef          	jal	800028b2 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004b94:	fdc42703          	lw	a4,-36(s0)
    80004b98:	47bd                	li	a5,15
    80004b9a:	02e7e963          	bltu	a5,a4,80004bcc <argfd+0x50>
    80004b9e:	ddbfc0ef          	jal	80001978 <myproc>
    80004ba2:	fdc42703          	lw	a4,-36(s0)
    80004ba6:	01a70793          	addi	a5,a4,26
    80004baa:	078e                	slli	a5,a5,0x3
    80004bac:	953e                	add	a0,a0,a5
    80004bae:	611c                	ld	a5,0(a0)
    80004bb0:	c385                	beqz	a5,80004bd0 <argfd+0x54>
    return -1;
  if (pfd)
    80004bb2:	00090463          	beqz	s2,80004bba <argfd+0x3e>
    *pfd = fd;
    80004bb6:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004bba:	4501                	li	a0,0
  if (pf)
    80004bbc:	c091                	beqz	s1,80004bc0 <argfd+0x44>
    *pf = f;
    80004bbe:	e09c                	sd	a5,0(s1)
}
    80004bc0:	70a2                	ld	ra,40(sp)
    80004bc2:	7402                	ld	s0,32(sp)
    80004bc4:	64e2                	ld	s1,24(sp)
    80004bc6:	6942                	ld	s2,16(sp)
    80004bc8:	6145                	addi	sp,sp,48
    80004bca:	8082                	ret
    return -1;
    80004bcc:	557d                	li	a0,-1
    80004bce:	bfcd                	j	80004bc0 <argfd+0x44>
    80004bd0:	557d                	li	a0,-1
    80004bd2:	b7fd                	j	80004bc0 <argfd+0x44>

0000000080004bd4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004bd4:	1101                	addi	sp,sp,-32
    80004bd6:	ec06                	sd	ra,24(sp)
    80004bd8:	e822                	sd	s0,16(sp)
    80004bda:	e426                	sd	s1,8(sp)
    80004bdc:	1000                	addi	s0,sp,32
    80004bde:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004be0:	d99fc0ef          	jal	80001978 <myproc>
    80004be4:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004be6:	0d050793          	addi	a5,a0,208
    80004bea:	4501                	li	a0,0
    80004bec:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004bee:	6398                	ld	a4,0(a5)
    80004bf0:	cb19                	beqz	a4,80004c06 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004bf2:	2505                	addiw	a0,a0,1
    80004bf4:	07a1                	addi	a5,a5,8
    80004bf6:	fed51ce3          	bne	a0,a3,80004bee <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004bfa:	557d                	li	a0,-1
}
    80004bfc:	60e2                	ld	ra,24(sp)
    80004bfe:	6442                	ld	s0,16(sp)
    80004c00:	64a2                	ld	s1,8(sp)
    80004c02:	6105                	addi	sp,sp,32
    80004c04:	8082                	ret
      p->ofile[fd] = f;
    80004c06:	01a50793          	addi	a5,a0,26
    80004c0a:	078e                	slli	a5,a5,0x3
    80004c0c:	963e                	add	a2,a2,a5
    80004c0e:	e204                	sd	s1,0(a2)
      return fd;
    80004c10:	b7f5                	j	80004bfc <fdalloc+0x28>

0000000080004c12 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004c12:	715d                	addi	sp,sp,-80
    80004c14:	e486                	sd	ra,72(sp)
    80004c16:	e0a2                	sd	s0,64(sp)
    80004c18:	fc26                	sd	s1,56(sp)
    80004c1a:	f84a                	sd	s2,48(sp)
    80004c1c:	f44e                	sd	s3,40(sp)
    80004c1e:	f052                	sd	s4,32(sp)
    80004c20:	ec56                	sd	s5,24(sp)
    80004c22:	0880                	addi	s0,sp,80
    80004c24:	892e                	mv	s2,a1
    80004c26:	89b2                	mv	s3,a2
    80004c28:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004c2a:	fb040593          	addi	a1,s0,-80
    80004c2e:	f2bfe0ef          	jal	80003b58 <nameiparent>
    80004c32:	8aaa                	mv	s5,a0
    80004c34:	cd45                	beqz	a0,80004cec <create+0xda>
    return 0;

  ilock(dp);
    80004c36:	e92fe0ef          	jal	800032c8 <ilock>

  if (dp->nlink == 0) {
    80004c3a:	04aa9783          	lh	a5,74(s5) # fffffffffffff04a <end+0xffffffff7ffde40a>
    80004c3e:	cf8d                	beqz	a5,80004c78 <create+0x66>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004c40:	4705                	li	a4,1
    80004c42:	04e91563          	bne	s2,a4,80004c8c <create+0x7a>
    80004c46:	6721                	lui	a4,0x8
    80004c48:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004c4a:	02e78c63          	beq	a5,a4,80004c82 <create+0x70>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004c4e:	4601                	li	a2,0
    80004c50:	fb040593          	addi	a1,s0,-80
    80004c54:	8556                	mv	a0,s5
    80004c56:	c71fe0ef          	jal	800038c6 <dirlookup>
    80004c5a:	84aa                	mv	s1,a0
    80004c5c:	e951                	bnez	a0,80004cf0 <create+0xde>
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004c5e:	85ca                	mv	a1,s2
    80004c60:	000aa503          	lw	a0,0(s5)
    80004c64:	cf4fe0ef          	jal	80003158 <ialloc>
    80004c68:	84aa                	mv	s1,a0
    80004c6a:	0c051e63          	bnez	a0,80004d46 <create+0x134>
    iunlockput(dp);
    80004c6e:	8556                	mv	a0,s5
    80004c70:	8abfe0ef          	jal	8000351a <iunlockput>
    return 0;
    80004c74:	4481                	li	s1,0
    80004c76:	a0a1                	j	80004cbe <create+0xac>
    iunlockput(dp);
    80004c78:	8556                	mv	a0,s5
    80004c7a:	8a1fe0ef          	jal	8000351a <iunlockput>
    return 0;
    80004c7e:	4481                	li	s1,0
    80004c80:	a83d                	j	80004cbe <create+0xac>
    iunlockput(dp);
    80004c82:	8556                	mv	a0,s5
    80004c84:	897fe0ef          	jal	8000351a <iunlockput>
    return 0;
    80004c88:	4481                	li	s1,0
    80004c8a:	a815                	j	80004cbe <create+0xac>
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004c8c:	4601                	li	a2,0
    80004c8e:	fb040593          	addi	a1,s0,-80
    80004c92:	8556                	mv	a0,s5
    80004c94:	c33fe0ef          	jal	800038c6 <dirlookup>
    80004c98:	84aa                	mv	s1,a0
    80004c9a:	c535                	beqz	a0,80004d06 <create+0xf4>
    iunlockput(dp);
    80004c9c:	8556                	mv	a0,s5
    80004c9e:	87dfe0ef          	jal	8000351a <iunlockput>
    ilock(ip);
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	e24fe0ef          	jal	800032c8 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ca8:	4789                	li	a5,2
    80004caa:	04f91963          	bne	s2,a5,80004cfc <create+0xea>
    80004cae:	0444d783          	lhu	a5,68(s1)
    80004cb2:	37f9                	addiw	a5,a5,-2
    80004cb4:	17c2                	slli	a5,a5,0x30
    80004cb6:	93c1                	srli	a5,a5,0x30
    80004cb8:	4705                	li	a4,1
    80004cba:	04f76163          	bltu	a4,a5,80004cfc <create+0xea>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004cbe:	8526                	mv	a0,s1
    80004cc0:	60a6                	ld	ra,72(sp)
    80004cc2:	6406                	ld	s0,64(sp)
    80004cc4:	74e2                	ld	s1,56(sp)
    80004cc6:	7942                	ld	s2,48(sp)
    80004cc8:	79a2                	ld	s3,40(sp)
    80004cca:	7a02                	ld	s4,32(sp)
    80004ccc:	6ae2                	ld	s5,24(sp)
    80004cce:	6161                	addi	sp,sp,80
    80004cd0:	8082                	ret
  ip->nlink = 0;
    80004cd2:	04049523          	sh	zero,74(s1)
  iupdate(ip);
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	d3cfe0ef          	jal	80003214 <iupdate>
  iunlockput(ip);
    80004cdc:	8526                	mv	a0,s1
    80004cde:	83dfe0ef          	jal	8000351a <iunlockput>
  iunlockput(dp);
    80004ce2:	8556                	mv	a0,s5
    80004ce4:	837fe0ef          	jal	8000351a <iunlockput>
  return 0;
    80004ce8:	4481                	li	s1,0
    80004cea:	bfd1                	j	80004cbe <create+0xac>
    return 0;
    80004cec:	84aa                	mv	s1,a0
    80004cee:	bfc1                	j	80004cbe <create+0xac>
    iunlockput(dp);
    80004cf0:	8556                	mv	a0,s5
    80004cf2:	829fe0ef          	jal	8000351a <iunlockput>
    ilock(ip);
    80004cf6:	8526                	mv	a0,s1
    80004cf8:	dd0fe0ef          	jal	800032c8 <ilock>
    iunlockput(ip);
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	81dfe0ef          	jal	8000351a <iunlockput>
    return 0;
    80004d02:	4481                	li	s1,0
    80004d04:	bf6d                	j	80004cbe <create+0xac>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004d06:	85ca                	mv	a1,s2
    80004d08:	000aa503          	lw	a0,0(s5)
    80004d0c:	c4cfe0ef          	jal	80003158 <ialloc>
    80004d10:	84aa                	mv	s1,a0
    80004d12:	dd31                	beqz	a0,80004c6e <create+0x5c>
  ilock(ip);
    80004d14:	8526                	mv	a0,s1
    80004d16:	db2fe0ef          	jal	800032c8 <ilock>
  ip->major = major;
    80004d1a:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004d1e:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004d22:	4785                	li	a5,1
    80004d24:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d28:	8526                	mv	a0,s1
    80004d2a:	ceafe0ef          	jal	80003214 <iupdate>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d2e:	40d0                	lw	a2,4(s1)
    80004d30:	fb040593          	addi	a1,s0,-80
    80004d34:	8556                	mv	a0,s5
    80004d36:	d6ffe0ef          	jal	80003aa4 <dirlink>
    80004d3a:	f8054ce3          	bltz	a0,80004cd2 <create+0xc0>
  iunlockput(dp);
    80004d3e:	8556                	mv	a0,s5
    80004d40:	fdafe0ef          	jal	8000351a <iunlockput>
  return ip;
    80004d44:	bfad                	j	80004cbe <create+0xac>
  ilock(ip);
    80004d46:	8526                	mv	a0,s1
    80004d48:	d80fe0ef          	jal	800032c8 <ilock>
  ip->major = major;
    80004d4c:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004d50:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004d54:	4785                	li	a5,1
    80004d56:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d5a:	8526                	mv	a0,s1
    80004d5c:	cb8fe0ef          	jal	80003214 <iupdate>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d60:	40d0                	lw	a2,4(s1)
    80004d62:	00003597          	auipc	a1,0x3
    80004d66:	88658593          	addi	a1,a1,-1914 # 800075e8 <etext+0x5e8>
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	d39fe0ef          	jal	80003aa4 <dirlink>
    80004d70:	f60541e3          	bltz	a0,80004cd2 <create+0xc0>
    80004d74:	004aa603          	lw	a2,4(s5)
    80004d78:	00003597          	auipc	a1,0x3
    80004d7c:	86858593          	addi	a1,a1,-1944 # 800075e0 <etext+0x5e0>
    80004d80:	8526                	mv	a0,s1
    80004d82:	d23fe0ef          	jal	80003aa4 <dirlink>
    80004d86:	f40546e3          	bltz	a0,80004cd2 <create+0xc0>
  if (dirlink(dp, name, ip->inum) < 0)
    80004d8a:	40d0                	lw	a2,4(s1)
    80004d8c:	fb040593          	addi	a1,s0,-80
    80004d90:	8556                	mv	a0,s5
    80004d92:	d13fe0ef          	jal	80003aa4 <dirlink>
    80004d96:	f2054ee3          	bltz	a0,80004cd2 <create+0xc0>
    dp->nlink++; // for ".."
    80004d9a:	04aad783          	lhu	a5,74(s5)
    80004d9e:	2785                	addiw	a5,a5,1
    80004da0:	04fa9523          	sh	a5,74(s5)
    iupdate(dp);
    80004da4:	8556                	mv	a0,s5
    80004da6:	c6efe0ef          	jal	80003214 <iupdate>
    80004daa:	bf51                	j	80004d3e <create+0x12c>

0000000080004dac <sys_dup>:
{
    80004dac:	7179                	addi	sp,sp,-48
    80004dae:	f406                	sd	ra,40(sp)
    80004db0:	f022                	sd	s0,32(sp)
    80004db2:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004db4:	fd840613          	addi	a2,s0,-40
    80004db8:	4581                	li	a1,0
    80004dba:	4501                	li	a0,0
    80004dbc:	dc1ff0ef          	jal	80004b7c <argfd>
    return -1;
    80004dc0:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004dc2:	02054363          	bltz	a0,80004de8 <sys_dup+0x3c>
    80004dc6:	ec26                	sd	s1,24(sp)
    80004dc8:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004dca:	fd843903          	ld	s2,-40(s0)
    80004dce:	854a                	mv	a0,s2
    80004dd0:	e05ff0ef          	jal	80004bd4 <fdalloc>
    80004dd4:	84aa                	mv	s1,a0
    return -1;
    80004dd6:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004dd8:	00054d63          	bltz	a0,80004df2 <sys_dup+0x46>
  filedup(f);
    80004ddc:	854a                	mv	a0,s2
    80004dde:	b9aff0ef          	jal	80004178 <filedup>
  return fd;
    80004de2:	87a6                	mv	a5,s1
    80004de4:	64e2                	ld	s1,24(sp)
    80004de6:	6942                	ld	s2,16(sp)
}
    80004de8:	853e                	mv	a0,a5
    80004dea:	70a2                	ld	ra,40(sp)
    80004dec:	7402                	ld	s0,32(sp)
    80004dee:	6145                	addi	sp,sp,48
    80004df0:	8082                	ret
    80004df2:	64e2                	ld	s1,24(sp)
    80004df4:	6942                	ld	s2,16(sp)
    80004df6:	bfcd                	j	80004de8 <sys_dup+0x3c>

0000000080004df8 <sys_read>:
{
    80004df8:	7179                	addi	sp,sp,-48
    80004dfa:	f406                	sd	ra,40(sp)
    80004dfc:	f022                	sd	s0,32(sp)
    80004dfe:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e00:	fd840593          	addi	a1,s0,-40
    80004e04:	4505                	li	a0,1
    80004e06:	ac9fd0ef          	jal	800028ce <argaddr>
  argint(2, &n);
    80004e0a:	fe440593          	addi	a1,s0,-28
    80004e0e:	4509                	li	a0,2
    80004e10:	aa3fd0ef          	jal	800028b2 <argint>
  if (argfd(0, 0, &f) < 0)
    80004e14:	fe840613          	addi	a2,s0,-24
    80004e18:	4581                	li	a1,0
    80004e1a:	4501                	li	a0,0
    80004e1c:	d61ff0ef          	jal	80004b7c <argfd>
    80004e20:	87aa                	mv	a5,a0
    return -1;
    80004e22:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e24:	0007ca63          	bltz	a5,80004e38 <sys_read+0x40>
  return fileread(f, p, n);
    80004e28:	fe442603          	lw	a2,-28(s0)
    80004e2c:	fd843583          	ld	a1,-40(s0)
    80004e30:	fe843503          	ld	a0,-24(s0)
    80004e34:	caeff0ef          	jal	800042e2 <fileread>
}
    80004e38:	70a2                	ld	ra,40(sp)
    80004e3a:	7402                	ld	s0,32(sp)
    80004e3c:	6145                	addi	sp,sp,48
    80004e3e:	8082                	ret

0000000080004e40 <sys_write>:
{
    80004e40:	7179                	addi	sp,sp,-48
    80004e42:	f406                	sd	ra,40(sp)
    80004e44:	f022                	sd	s0,32(sp)
    80004e46:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e48:	fd840593          	addi	a1,s0,-40
    80004e4c:	4505                	li	a0,1
    80004e4e:	a81fd0ef          	jal	800028ce <argaddr>
  argint(2, &n);
    80004e52:	fe440593          	addi	a1,s0,-28
    80004e56:	4509                	li	a0,2
    80004e58:	a5bfd0ef          	jal	800028b2 <argint>
  if (argfd(0, 0, &f) < 0)
    80004e5c:	fe840613          	addi	a2,s0,-24
    80004e60:	4581                	li	a1,0
    80004e62:	4501                	li	a0,0
    80004e64:	d19ff0ef          	jal	80004b7c <argfd>
    80004e68:	87aa                	mv	a5,a0
    return -1;
    80004e6a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e6c:	0007ca63          	bltz	a5,80004e80 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e70:	fe442603          	lw	a2,-28(s0)
    80004e74:	fd843583          	ld	a1,-40(s0)
    80004e78:	fe843503          	ld	a0,-24(s0)
    80004e7c:	d30ff0ef          	jal	800043ac <filewrite>
}
    80004e80:	70a2                	ld	ra,40(sp)
    80004e82:	7402                	ld	s0,32(sp)
    80004e84:	6145                	addi	sp,sp,48
    80004e86:	8082                	ret

0000000080004e88 <sys_close>:
{
    80004e88:	1101                	addi	sp,sp,-32
    80004e8a:	ec06                	sd	ra,24(sp)
    80004e8c:	e822                	sd	s0,16(sp)
    80004e8e:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004e90:	fe040613          	addi	a2,s0,-32
    80004e94:	fec40593          	addi	a1,s0,-20
    80004e98:	4501                	li	a0,0
    80004e9a:	ce3ff0ef          	jal	80004b7c <argfd>
    return -1;
    80004e9e:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004ea0:	02054063          	bltz	a0,80004ec0 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004ea4:	ad5fc0ef          	jal	80001978 <myproc>
    80004ea8:	fec42783          	lw	a5,-20(s0)
    80004eac:	07e9                	addi	a5,a5,26
    80004eae:	078e                	slli	a5,a5,0x3
    80004eb0:	953e                	add	a0,a0,a5
    80004eb2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004eb6:	fe043503          	ld	a0,-32(s0)
    80004eba:	b04ff0ef          	jal	800041be <fileclose>
  return 0;
    80004ebe:	4781                	li	a5,0
}
    80004ec0:	853e                	mv	a0,a5
    80004ec2:	60e2                	ld	ra,24(sp)
    80004ec4:	6442                	ld	s0,16(sp)
    80004ec6:	6105                	addi	sp,sp,32
    80004ec8:	8082                	ret

0000000080004eca <sys_fstat>:
{
    80004eca:	1101                	addi	sp,sp,-32
    80004ecc:	ec06                	sd	ra,24(sp)
    80004ece:	e822                	sd	s0,16(sp)
    80004ed0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ed2:	fe040593          	addi	a1,s0,-32
    80004ed6:	4505                	li	a0,1
    80004ed8:	9f7fd0ef          	jal	800028ce <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004edc:	fe840613          	addi	a2,s0,-24
    80004ee0:	4581                	li	a1,0
    80004ee2:	4501                	li	a0,0
    80004ee4:	c99ff0ef          	jal	80004b7c <argfd>
    80004ee8:	87aa                	mv	a5,a0
    return -1;
    80004eea:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004eec:	0007c863          	bltz	a5,80004efc <sys_fstat+0x32>
  return filestat(f, st);
    80004ef0:	fe043583          	ld	a1,-32(s0)
    80004ef4:	fe843503          	ld	a0,-24(s0)
    80004ef8:	b88ff0ef          	jal	80004280 <filestat>
}
    80004efc:	60e2                	ld	ra,24(sp)
    80004efe:	6442                	ld	s0,16(sp)
    80004f00:	6105                	addi	sp,sp,32
    80004f02:	8082                	ret

0000000080004f04 <sys_link>:
{
    80004f04:	7169                	addi	sp,sp,-304
    80004f06:	f606                	sd	ra,296(sp)
    80004f08:	f222                	sd	s0,288(sp)
    80004f0a:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f0c:	08000613          	li	a2,128
    80004f10:	ed040593          	addi	a1,s0,-304
    80004f14:	4501                	li	a0,0
    80004f16:	9d5fd0ef          	jal	800028ea <argstr>
    return -1;
    80004f1a:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f1c:	10054163          	bltz	a0,8000501e <sys_link+0x11a>
    80004f20:	08000613          	li	a2,128
    80004f24:	f5040593          	addi	a1,s0,-176
    80004f28:	4505                	li	a0,1
    80004f2a:	9c1fd0ef          	jal	800028ea <argstr>
    return -1;
    80004f2e:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f30:	0e054763          	bltz	a0,8000501e <sys_link+0x11a>
    80004f34:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f36:	dddfe0ef          	jal	80003d12 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004f3a:	ed040513          	addi	a0,s0,-304
    80004f3e:	c01fe0ef          	jal	80003b3e <namei>
    80004f42:	84aa                	mv	s1,a0
    80004f44:	cd35                	beqz	a0,80004fc0 <sys_link+0xbc>
  ilock(ip);
    80004f46:	b82fe0ef          	jal	800032c8 <ilock>
  if (ip->type == T_DIR) {
    80004f4a:	04449703          	lh	a4,68(s1)
    80004f4e:	4785                	li	a5,1
    80004f50:	06f70d63          	beq	a4,a5,80004fca <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004f54:	04a49783          	lh	a5,74(s1)
    80004f58:	6721                	lui	a4,0x8
    80004f5a:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004f5c:	06e78f63          	beq	a5,a4,80004fda <sys_link+0xd6>
    80004f60:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f62:	2785                	addiw	a5,a5,1
    80004f64:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f68:	8526                	mv	a0,s1
    80004f6a:	aaafe0ef          	jal	80003214 <iupdate>
  iunlock(ip);
    80004f6e:	8526                	mv	a0,s1
    80004f70:	c06fe0ef          	jal	80003376 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004f74:	fd040593          	addi	a1,s0,-48
    80004f78:	f5040513          	addi	a0,s0,-176
    80004f7c:	bddfe0ef          	jal	80003b58 <nameiparent>
    80004f80:	892a                	mv	s2,a0
    80004f82:	c93d                	beqz	a0,80004ff8 <sys_link+0xf4>
  ilock(dp);
    80004f84:	b44fe0ef          	jal	800032c8 <ilock>
  if (dp->nlink == 0) {
    80004f88:	04a91783          	lh	a5,74(s2)
    80004f8c:	cfb9                	beqz	a5,80004fea <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004f8e:	00092703          	lw	a4,0(s2)
    80004f92:	409c                	lw	a5,0(s1)
    80004f94:	04f71f63          	bne	a4,a5,80004ff2 <sys_link+0xee>
    80004f98:	40d0                	lw	a2,4(s1)
    80004f9a:	fd040593          	addi	a1,s0,-48
    80004f9e:	854a                	mv	a0,s2
    80004fa0:	b05fe0ef          	jal	80003aa4 <dirlink>
    80004fa4:	04054763          	bltz	a0,80004ff2 <sys_link+0xee>
  iunlockput(dp);
    80004fa8:	854a                	mv	a0,s2
    80004faa:	d70fe0ef          	jal	8000351a <iunlockput>
  iput(ip);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	c9afe0ef          	jal	8000344a <iput>
  end_op();
    80004fb4:	de5fe0ef          	jal	80003d98 <end_op>
  return 0;
    80004fb8:	4781                	li	a5,0
    80004fba:	64f2                	ld	s1,280(sp)
    80004fbc:	6952                	ld	s2,272(sp)
    80004fbe:	a085                	j	8000501e <sys_link+0x11a>
    end_op();
    80004fc0:	dd9fe0ef          	jal	80003d98 <end_op>
    return -1;
    80004fc4:	57fd                	li	a5,-1
    80004fc6:	64f2                	ld	s1,280(sp)
    80004fc8:	a899                	j	8000501e <sys_link+0x11a>
    iunlockput(ip);
    80004fca:	8526                	mv	a0,s1
    80004fcc:	d4efe0ef          	jal	8000351a <iunlockput>
    end_op();
    80004fd0:	dc9fe0ef          	jal	80003d98 <end_op>
    return -1;
    80004fd4:	57fd                	li	a5,-1
    80004fd6:	64f2                	ld	s1,280(sp)
    80004fd8:	a099                	j	8000501e <sys_link+0x11a>
    iunlockput(ip);
    80004fda:	8526                	mv	a0,s1
    80004fdc:	d3efe0ef          	jal	8000351a <iunlockput>
    end_op();
    80004fe0:	db9fe0ef          	jal	80003d98 <end_op>
    return -1;
    80004fe4:	57fd                	li	a5,-1
    80004fe6:	64f2                	ld	s1,280(sp)
    80004fe8:	a81d                	j	8000501e <sys_link+0x11a>
    iunlockput(dp);
    80004fea:	854a                	mv	a0,s2
    80004fec:	d2efe0ef          	jal	8000351a <iunlockput>
    goto bad;
    80004ff0:	a021                	j	80004ff8 <sys_link+0xf4>
    iunlockput(dp);
    80004ff2:	854a                	mv	a0,s2
    80004ff4:	d26fe0ef          	jal	8000351a <iunlockput>
  ilock(ip);
    80004ff8:	8526                	mv	a0,s1
    80004ffa:	acefe0ef          	jal	800032c8 <ilock>
  ip->nlink--;
    80004ffe:	04a4d783          	lhu	a5,74(s1)
    80005002:	37fd                	addiw	a5,a5,-1
    80005004:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005008:	8526                	mv	a0,s1
    8000500a:	a0afe0ef          	jal	80003214 <iupdate>
  iunlockput(ip);
    8000500e:	8526                	mv	a0,s1
    80005010:	d0afe0ef          	jal	8000351a <iunlockput>
  end_op();
    80005014:	d85fe0ef          	jal	80003d98 <end_op>
  return -1;
    80005018:	57fd                	li	a5,-1
    8000501a:	64f2                	ld	s1,280(sp)
    8000501c:	6952                	ld	s2,272(sp)
}
    8000501e:	853e                	mv	a0,a5
    80005020:	70b2                	ld	ra,296(sp)
    80005022:	7412                	ld	s0,288(sp)
    80005024:	6155                	addi	sp,sp,304
    80005026:	8082                	ret

0000000080005028 <sys_unlink>:
{
    80005028:	7151                	addi	sp,sp,-240
    8000502a:	f586                	sd	ra,232(sp)
    8000502c:	f1a2                	sd	s0,224(sp)
    8000502e:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005030:	08000613          	li	a2,128
    80005034:	f3040593          	addi	a1,s0,-208
    80005038:	4501                	li	a0,0
    8000503a:	8b1fd0ef          	jal	800028ea <argstr>
    8000503e:	16054063          	bltz	a0,8000519e <sys_unlink+0x176>
    80005042:	eda6                	sd	s1,216(sp)
  begin_op();
    80005044:	ccffe0ef          	jal	80003d12 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005048:	fb040593          	addi	a1,s0,-80
    8000504c:	f3040513          	addi	a0,s0,-208
    80005050:	b09fe0ef          	jal	80003b58 <nameiparent>
    80005054:	84aa                	mv	s1,a0
    80005056:	c945                	beqz	a0,80005106 <sys_unlink+0xde>
  ilock(dp);
    80005058:	a70fe0ef          	jal	800032c8 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000505c:	00002597          	auipc	a1,0x2
    80005060:	58c58593          	addi	a1,a1,1420 # 800075e8 <etext+0x5e8>
    80005064:	fb040513          	addi	a0,s0,-80
    80005068:	849fe0ef          	jal	800038b0 <namecmp>
    8000506c:	10050e63          	beqz	a0,80005188 <sys_unlink+0x160>
    80005070:	00002597          	auipc	a1,0x2
    80005074:	57058593          	addi	a1,a1,1392 # 800075e0 <etext+0x5e0>
    80005078:	fb040513          	addi	a0,s0,-80
    8000507c:	835fe0ef          	jal	800038b0 <namecmp>
    80005080:	10050463          	beqz	a0,80005188 <sys_unlink+0x160>
    80005084:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005086:	f2c40613          	addi	a2,s0,-212
    8000508a:	fb040593          	addi	a1,s0,-80
    8000508e:	8526                	mv	a0,s1
    80005090:	837fe0ef          	jal	800038c6 <dirlookup>
    80005094:	892a                	mv	s2,a0
    80005096:	0e050863          	beqz	a0,80005186 <sys_unlink+0x15e>
  ilock(ip);
    8000509a:	a2efe0ef          	jal	800032c8 <ilock>
  if (ip->nlink < 1)
    8000509e:	04a91783          	lh	a5,74(s2)
    800050a2:	06f05763          	blez	a5,80005110 <sys_unlink+0xe8>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800050a6:	04491703          	lh	a4,68(s2)
    800050aa:	4785                	li	a5,1
    800050ac:	06f70963          	beq	a4,a5,8000511e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800050b0:	4641                	li	a2,16
    800050b2:	4581                	li	a1,0
    800050b4:	fc040513          	addi	a0,s0,-64
    800050b8:	c59fb0ef          	jal	80000d10 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050bc:	4741                	li	a4,16
    800050be:	f2c42683          	lw	a3,-212(s0)
    800050c2:	fc040613          	addi	a2,s0,-64
    800050c6:	4581                	li	a1,0
    800050c8:	8526                	mv	a0,s1
    800050ca:	ed2fe0ef          	jal	8000379c <writei>
    800050ce:	47c1                	li	a5,16
    800050d0:	08f51b63          	bne	a0,a5,80005166 <sys_unlink+0x13e>
  if (ip->type == T_DIR) {
    800050d4:	04491703          	lh	a4,68(s2)
    800050d8:	4785                	li	a5,1
    800050da:	08f70d63          	beq	a4,a5,80005174 <sys_unlink+0x14c>
  iunlockput(dp);
    800050de:	8526                	mv	a0,s1
    800050e0:	c3afe0ef          	jal	8000351a <iunlockput>
  ip->nlink--;
    800050e4:	04a95783          	lhu	a5,74(s2)
    800050e8:	37fd                	addiw	a5,a5,-1
    800050ea:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050ee:	854a                	mv	a0,s2
    800050f0:	924fe0ef          	jal	80003214 <iupdate>
  iunlockput(ip);
    800050f4:	854a                	mv	a0,s2
    800050f6:	c24fe0ef          	jal	8000351a <iunlockput>
  end_op();
    800050fa:	c9ffe0ef          	jal	80003d98 <end_op>
  return 0;
    800050fe:	4501                	li	a0,0
    80005100:	64ee                	ld	s1,216(sp)
    80005102:	694e                	ld	s2,208(sp)
    80005104:	a849                	j	80005196 <sys_unlink+0x16e>
    end_op();
    80005106:	c93fe0ef          	jal	80003d98 <end_op>
    return -1;
    8000510a:	557d                	li	a0,-1
    8000510c:	64ee                	ld	s1,216(sp)
    8000510e:	a061                	j	80005196 <sys_unlink+0x16e>
    80005110:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005112:	00002517          	auipc	a0,0x2
    80005116:	4de50513          	addi	a0,a0,1246 # 800075f0 <etext+0x5f0>
    8000511a:	ed6fb0ef          	jal	800007f0 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000511e:	04c92703          	lw	a4,76(s2)
    80005122:	02000793          	li	a5,32
    80005126:	f8e7f5e3          	bgeu	a5,a4,800050b0 <sys_unlink+0x88>
    8000512a:	e5ce                	sd	s3,200(sp)
    8000512c:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005130:	4741                	li	a4,16
    80005132:	86ce                	mv	a3,s3
    80005134:	f1840613          	addi	a2,s0,-232
    80005138:	4581                	li	a1,0
    8000513a:	854a                	mv	a0,s2
    8000513c:	d64fe0ef          	jal	800036a0 <readi>
    80005140:	47c1                	li	a5,16
    80005142:	00f51c63          	bne	a0,a5,8000515a <sys_unlink+0x132>
    if (de.inum != 0)
    80005146:	f1845783          	lhu	a5,-232(s0)
    8000514a:	efa1                	bnez	a5,800051a2 <sys_unlink+0x17a>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000514c:	29c1                	addiw	s3,s3,16
    8000514e:	04c92783          	lw	a5,76(s2)
    80005152:	fcf9efe3          	bltu	s3,a5,80005130 <sys_unlink+0x108>
    80005156:	69ae                	ld	s3,200(sp)
    80005158:	bfa1                	j	800050b0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000515a:	00002517          	auipc	a0,0x2
    8000515e:	4ae50513          	addi	a0,a0,1198 # 80007608 <etext+0x608>
    80005162:	e8efb0ef          	jal	800007f0 <panic>
    80005166:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005168:	00002517          	auipc	a0,0x2
    8000516c:	4b850513          	addi	a0,a0,1208 # 80007620 <etext+0x620>
    80005170:	e80fb0ef          	jal	800007f0 <panic>
    dp->nlink--;
    80005174:	04a4d783          	lhu	a5,74(s1)
    80005178:	37fd                	addiw	a5,a5,-1
    8000517a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000517e:	8526                	mv	a0,s1
    80005180:	894fe0ef          	jal	80003214 <iupdate>
    80005184:	bfa9                	j	800050de <sys_unlink+0xb6>
    80005186:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005188:	8526                	mv	a0,s1
    8000518a:	b90fe0ef          	jal	8000351a <iunlockput>
  end_op();
    8000518e:	c0bfe0ef          	jal	80003d98 <end_op>
  return -1;
    80005192:	557d                	li	a0,-1
    80005194:	64ee                	ld	s1,216(sp)
}
    80005196:	70ae                	ld	ra,232(sp)
    80005198:	740e                	ld	s0,224(sp)
    8000519a:	616d                	addi	sp,sp,240
    8000519c:	8082                	ret
    return -1;
    8000519e:	557d                	li	a0,-1
    800051a0:	bfdd                	j	80005196 <sys_unlink+0x16e>
    iunlockput(ip);
    800051a2:	854a                	mv	a0,s2
    800051a4:	b76fe0ef          	jal	8000351a <iunlockput>
    goto bad;
    800051a8:	694e                	ld	s2,208(sp)
    800051aa:	69ae                	ld	s3,200(sp)
    800051ac:	bff1                	j	80005188 <sys_unlink+0x160>

00000000800051ae <sys_open>:

uint64
sys_open(void)
{
    800051ae:	7131                	addi	sp,sp,-192
    800051b0:	fd06                	sd	ra,184(sp)
    800051b2:	f922                	sd	s0,176(sp)
    800051b4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051b6:	f4c40593          	addi	a1,s0,-180
    800051ba:	4505                	li	a0,1
    800051bc:	ef6fd0ef          	jal	800028b2 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800051c0:	08000613          	li	a2,128
    800051c4:	f5040593          	addi	a1,s0,-176
    800051c8:	4501                	li	a0,0
    800051ca:	f20fd0ef          	jal	800028ea <argstr>
    800051ce:	87aa                	mv	a5,a0
    return -1;
    800051d0:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800051d2:	0a07c263          	bltz	a5,80005276 <sys_open+0xc8>
    800051d6:	f526                	sd	s1,168(sp)

  begin_op();
    800051d8:	b3bfe0ef          	jal	80003d12 <begin_op>

  if (omode & O_CREATE) {
    800051dc:	f4c42783          	lw	a5,-180(s0)
    800051e0:	2007f793          	andi	a5,a5,512
    800051e4:	c3d5                	beqz	a5,80005288 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800051e6:	4681                	li	a3,0
    800051e8:	4601                	li	a2,0
    800051ea:	4589                	li	a1,2
    800051ec:	f5040513          	addi	a0,s0,-176
    800051f0:	a23ff0ef          	jal	80004c12 <create>
    800051f4:	84aa                	mv	s1,a0
    if (ip == 0) {
    800051f6:	c541                	beqz	a0,8000527e <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800051f8:	04449703          	lh	a4,68(s1)
    800051fc:	478d                	li	a5,3
    800051fe:	00f71763          	bne	a4,a5,8000520c <sys_open+0x5e>
    80005202:	0464d703          	lhu	a4,70(s1)
    80005206:	47a5                	li	a5,9
    80005208:	0ae7ed63          	bltu	a5,a4,800052c2 <sys_open+0x114>
    8000520c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    8000520e:	f0dfe0ef          	jal	8000411a <filealloc>
    80005212:	892a                	mv	s2,a0
    80005214:	c179                	beqz	a0,800052da <sys_open+0x12c>
    80005216:	ed4e                	sd	s3,152(sp)
    80005218:	9bdff0ef          	jal	80004bd4 <fdalloc>
    8000521c:	89aa                	mv	s3,a0
    8000521e:	0a054a63          	bltz	a0,800052d2 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005222:	04449703          	lh	a4,68(s1)
    80005226:	478d                	li	a5,3
    80005228:	0cf70263          	beq	a4,a5,800052ec <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000522c:	4789                	li	a5,2
    8000522e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005232:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005236:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000523a:	f4c42783          	lw	a5,-180(s0)
    8000523e:	0017c713          	xori	a4,a5,1
    80005242:	8b05                	andi	a4,a4,1
    80005244:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005248:	0037f713          	andi	a4,a5,3
    8000524c:	00e03733          	snez	a4,a4
    80005250:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005254:	4007f793          	andi	a5,a5,1024
    80005258:	c791                	beqz	a5,80005264 <sys_open+0xb6>
    8000525a:	04449703          	lh	a4,68(s1)
    8000525e:	4789                	li	a5,2
    80005260:	08f70d63          	beq	a4,a5,800052fa <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005264:	8526                	mv	a0,s1
    80005266:	910fe0ef          	jal	80003376 <iunlock>
  end_op();
    8000526a:	b2ffe0ef          	jal	80003d98 <end_op>

  return fd;
    8000526e:	854e                	mv	a0,s3
    80005270:	74aa                	ld	s1,168(sp)
    80005272:	790a                	ld	s2,160(sp)
    80005274:	69ea                	ld	s3,152(sp)
}
    80005276:	70ea                	ld	ra,184(sp)
    80005278:	744a                	ld	s0,176(sp)
    8000527a:	6129                	addi	sp,sp,192
    8000527c:	8082                	ret
      end_op();
    8000527e:	b1bfe0ef          	jal	80003d98 <end_op>
      return -1;
    80005282:	557d                	li	a0,-1
    80005284:	74aa                	ld	s1,168(sp)
    80005286:	bfc5                	j	80005276 <sys_open+0xc8>
    if ((ip = namei(path)) == 0) {
    80005288:	f5040513          	addi	a0,s0,-176
    8000528c:	8b3fe0ef          	jal	80003b3e <namei>
    80005290:	84aa                	mv	s1,a0
    80005292:	c11d                	beqz	a0,800052b8 <sys_open+0x10a>
    ilock(ip);
    80005294:	834fe0ef          	jal	800032c8 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005298:	04449703          	lh	a4,68(s1)
    8000529c:	4785                	li	a5,1
    8000529e:	f4f71de3          	bne	a4,a5,800051f8 <sys_open+0x4a>
    800052a2:	f4c42783          	lw	a5,-180(s0)
    800052a6:	d3bd                	beqz	a5,8000520c <sys_open+0x5e>
      iunlockput(ip);
    800052a8:	8526                	mv	a0,s1
    800052aa:	a70fe0ef          	jal	8000351a <iunlockput>
      end_op();
    800052ae:	aebfe0ef          	jal	80003d98 <end_op>
      return -1;
    800052b2:	557d                	li	a0,-1
    800052b4:	74aa                	ld	s1,168(sp)
    800052b6:	b7c1                	j	80005276 <sys_open+0xc8>
      end_op();
    800052b8:	ae1fe0ef          	jal	80003d98 <end_op>
      return -1;
    800052bc:	557d                	li	a0,-1
    800052be:	74aa                	ld	s1,168(sp)
    800052c0:	bf5d                	j	80005276 <sys_open+0xc8>
    iunlockput(ip);
    800052c2:	8526                	mv	a0,s1
    800052c4:	a56fe0ef          	jal	8000351a <iunlockput>
    end_op();
    800052c8:	ad1fe0ef          	jal	80003d98 <end_op>
    return -1;
    800052cc:	557d                	li	a0,-1
    800052ce:	74aa                	ld	s1,168(sp)
    800052d0:	b75d                	j	80005276 <sys_open+0xc8>
      fileclose(f);
    800052d2:	854a                	mv	a0,s2
    800052d4:	eebfe0ef          	jal	800041be <fileclose>
    800052d8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800052da:	8526                	mv	a0,s1
    800052dc:	a3efe0ef          	jal	8000351a <iunlockput>
    end_op();
    800052e0:	ab9fe0ef          	jal	80003d98 <end_op>
    return -1;
    800052e4:	557d                	li	a0,-1
    800052e6:	74aa                	ld	s1,168(sp)
    800052e8:	790a                	ld	s2,160(sp)
    800052ea:	b771                	j	80005276 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800052ec:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800052f0:	04649783          	lh	a5,70(s1)
    800052f4:	02f91223          	sh	a5,36(s2)
    800052f8:	bf3d                	j	80005236 <sys_open+0x88>
    itrunc(ip);
    800052fa:	8526                	mv	a0,s1
    800052fc:	8bafe0ef          	jal	800033b6 <itrunc>
    80005300:	b795                	j	80005264 <sys_open+0xb6>

0000000080005302 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005302:	7175                	addi	sp,sp,-144
    80005304:	e506                	sd	ra,136(sp)
    80005306:	e122                	sd	s0,128(sp)
    80005308:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000530a:	a09fe0ef          	jal	80003d12 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    8000530e:	08000613          	li	a2,128
    80005312:	f7040593          	addi	a1,s0,-144
    80005316:	4501                	li	a0,0
    80005318:	dd2fd0ef          	jal	800028ea <argstr>
    8000531c:	02054363          	bltz	a0,80005342 <sys_mkdir+0x40>
    80005320:	4681                	li	a3,0
    80005322:	4601                	li	a2,0
    80005324:	4585                	li	a1,1
    80005326:	f7040513          	addi	a0,s0,-144
    8000532a:	8e9ff0ef          	jal	80004c12 <create>
    8000532e:	c911                	beqz	a0,80005342 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005330:	9eafe0ef          	jal	8000351a <iunlockput>
  end_op();
    80005334:	a65fe0ef          	jal	80003d98 <end_op>
  return 0;
    80005338:	4501                	li	a0,0
}
    8000533a:	60aa                	ld	ra,136(sp)
    8000533c:	640a                	ld	s0,128(sp)
    8000533e:	6149                	addi	sp,sp,144
    80005340:	8082                	ret
    end_op();
    80005342:	a57fe0ef          	jal	80003d98 <end_op>
    return -1;
    80005346:	557d                	li	a0,-1
    80005348:	bfcd                	j	8000533a <sys_mkdir+0x38>

000000008000534a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000534a:	7135                	addi	sp,sp,-160
    8000534c:	ed06                	sd	ra,152(sp)
    8000534e:	e922                	sd	s0,144(sp)
    80005350:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005352:	9c1fe0ef          	jal	80003d12 <begin_op>
  argint(1, &major);
    80005356:	f6c40593          	addi	a1,s0,-148
    8000535a:	4505                	li	a0,1
    8000535c:	d56fd0ef          	jal	800028b2 <argint>
  argint(2, &minor);
    80005360:	f6840593          	addi	a1,s0,-152
    80005364:	4509                	li	a0,2
    80005366:	d4cfd0ef          	jal	800028b2 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000536a:	08000613          	li	a2,128
    8000536e:	f7040593          	addi	a1,s0,-144
    80005372:	4501                	li	a0,0
    80005374:	d76fd0ef          	jal	800028ea <argstr>
    80005378:	02054563          	bltz	a0,800053a2 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    8000537c:	f6841683          	lh	a3,-152(s0)
    80005380:	f6c41603          	lh	a2,-148(s0)
    80005384:	458d                	li	a1,3
    80005386:	f7040513          	addi	a0,s0,-144
    8000538a:	889ff0ef          	jal	80004c12 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000538e:	c911                	beqz	a0,800053a2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005390:	98afe0ef          	jal	8000351a <iunlockput>
  end_op();
    80005394:	a05fe0ef          	jal	80003d98 <end_op>
  return 0;
    80005398:	4501                	li	a0,0
}
    8000539a:	60ea                	ld	ra,152(sp)
    8000539c:	644a                	ld	s0,144(sp)
    8000539e:	610d                	addi	sp,sp,160
    800053a0:	8082                	ret
    end_op();
    800053a2:	9f7fe0ef          	jal	80003d98 <end_op>
    return -1;
    800053a6:	557d                	li	a0,-1
    800053a8:	bfcd                	j	8000539a <sys_mknod+0x50>

00000000800053aa <sys_chdir>:

uint64
sys_chdir(void)
{
    800053aa:	7135                	addi	sp,sp,-160
    800053ac:	ed06                	sd	ra,152(sp)
    800053ae:	e922                	sd	s0,144(sp)
    800053b0:	e14a                	sd	s2,128(sp)
    800053b2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053b4:	dc4fc0ef          	jal	80001978 <myproc>
    800053b8:	892a                	mv	s2,a0

  begin_op();
    800053ba:	959fe0ef          	jal	80003d12 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800053be:	08000613          	li	a2,128
    800053c2:	f6040593          	addi	a1,s0,-160
    800053c6:	4501                	li	a0,0
    800053c8:	d22fd0ef          	jal	800028ea <argstr>
    800053cc:	04054363          	bltz	a0,80005412 <sys_chdir+0x68>
    800053d0:	e526                	sd	s1,136(sp)
    800053d2:	f6040513          	addi	a0,s0,-160
    800053d6:	f68fe0ef          	jal	80003b3e <namei>
    800053da:	84aa                	mv	s1,a0
    800053dc:	c915                	beqz	a0,80005410 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800053de:	eebfd0ef          	jal	800032c8 <ilock>
  if (ip->type != T_DIR) {
    800053e2:	04449703          	lh	a4,68(s1)
    800053e6:	4785                	li	a5,1
    800053e8:	02f71963          	bne	a4,a5,8000541a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800053ec:	8526                	mv	a0,s1
    800053ee:	f89fd0ef          	jal	80003376 <iunlock>
  iput(p->cwd);
    800053f2:	15093503          	ld	a0,336(s2)
    800053f6:	854fe0ef          	jal	8000344a <iput>
  end_op();
    800053fa:	99ffe0ef          	jal	80003d98 <end_op>
  p->cwd = ip;
    800053fe:	14993823          	sd	s1,336(s2)
  return 0;
    80005402:	4501                	li	a0,0
    80005404:	64aa                	ld	s1,136(sp)
}
    80005406:	60ea                	ld	ra,152(sp)
    80005408:	644a                	ld	s0,144(sp)
    8000540a:	690a                	ld	s2,128(sp)
    8000540c:	610d                	addi	sp,sp,160
    8000540e:	8082                	ret
    80005410:	64aa                	ld	s1,136(sp)
    end_op();
    80005412:	987fe0ef          	jal	80003d98 <end_op>
    return -1;
    80005416:	557d                	li	a0,-1
    80005418:	b7fd                	j	80005406 <sys_chdir+0x5c>
    iunlockput(ip);
    8000541a:	8526                	mv	a0,s1
    8000541c:	8fefe0ef          	jal	8000351a <iunlockput>
    end_op();
    80005420:	979fe0ef          	jal	80003d98 <end_op>
    return -1;
    80005424:	557d                	li	a0,-1
    80005426:	64aa                	ld	s1,136(sp)
    80005428:	bff9                	j	80005406 <sys_chdir+0x5c>

000000008000542a <sys_exec>:

uint64
sys_exec(void)
{
    8000542a:	7121                	addi	sp,sp,-448
    8000542c:	ff06                	sd	ra,440(sp)
    8000542e:	fb22                	sd	s0,432(sp)
    80005430:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005432:	e4840593          	addi	a1,s0,-440
    80005436:	4505                	li	a0,1
    80005438:	c96fd0ef          	jal	800028ce <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000543c:	08000613          	li	a2,128
    80005440:	f5040593          	addi	a1,s0,-176
    80005444:	4501                	li	a0,0
    80005446:	ca4fd0ef          	jal	800028ea <argstr>
    8000544a:	87aa                	mv	a5,a0
    return -1;
    8000544c:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    8000544e:	0c07c463          	bltz	a5,80005516 <sys_exec+0xec>
    80005452:	f726                	sd	s1,424(sp)
    80005454:	f34a                	sd	s2,416(sp)
    80005456:	ef4e                	sd	s3,408(sp)
    80005458:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000545a:	10000613          	li	a2,256
    8000545e:	4581                	li	a1,0
    80005460:	e5040513          	addi	a0,s0,-432
    80005464:	8adfb0ef          	jal	80000d10 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005468:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000546c:	89a6                	mv	s3,s1
    8000546e:	4901                	li	s2,0
    if (i >= NELEM(argv)) {
    80005470:	02000a13          	li	s4,32
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005474:	00391513          	slli	a0,s2,0x3
    80005478:	e4040593          	addi	a1,s0,-448
    8000547c:	e4843783          	ld	a5,-440(s0)
    80005480:	953e                	add	a0,a0,a5
    80005482:	ba4fd0ef          	jal	80002826 <fetchaddr>
    80005486:	02054663          	bltz	a0,800054b2 <sys_exec+0x88>
      goto bad;
    }
    if (uarg == 0) {
    8000548a:	e4043783          	ld	a5,-448(s0)
    8000548e:	c3a9                	beqz	a5,800054d0 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005490:	e3afb0ef          	jal	80000aca <kalloc>
    80005494:	85aa                	mv	a1,a0
    80005496:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    8000549a:	cd01                	beqz	a0,800054b2 <sys_exec+0x88>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000549c:	6605                	lui	a2,0x1
    8000549e:	e4043503          	ld	a0,-448(s0)
    800054a2:	bcefd0ef          	jal	80002870 <fetchstr>
    800054a6:	00054663          	bltz	a0,800054b2 <sys_exec+0x88>
    if (i >= NELEM(argv)) {
    800054aa:	0905                	addi	s2,s2,1
    800054ac:	09a1                	addi	s3,s3,8
    800054ae:	fd4913e3          	bne	s2,s4,80005474 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054b2:	f5040913          	addi	s2,s0,-176
    800054b6:	6088                	ld	a0,0(s1)
    800054b8:	c931                	beqz	a0,8000550c <sys_exec+0xe2>
    kfree(argv[i]);
    800054ba:	d2efb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054be:	04a1                	addi	s1,s1,8
    800054c0:	ff249be3          	bne	s1,s2,800054b6 <sys_exec+0x8c>
  return -1;
    800054c4:	557d                	li	a0,-1
    800054c6:	74ba                	ld	s1,424(sp)
    800054c8:	791a                	ld	s2,416(sp)
    800054ca:	69fa                	ld	s3,408(sp)
    800054cc:	6a5a                	ld	s4,400(sp)
    800054ce:	a0a1                	j	80005516 <sys_exec+0xec>
      argv[i] = 0;
    800054d0:	0009079b          	sext.w	a5,s2
    800054d4:	078e                	slli	a5,a5,0x3
    800054d6:	fd078793          	addi	a5,a5,-48
    800054da:	97a2                	add	a5,a5,s0
    800054dc:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800054e0:	e5040593          	addi	a1,s0,-432
    800054e4:	f5040513          	addi	a0,s0,-176
    800054e8:	b26ff0ef          	jal	8000480e <kexec>
    800054ec:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054ee:	f5040993          	addi	s3,s0,-176
    800054f2:	6088                	ld	a0,0(s1)
    800054f4:	c511                	beqz	a0,80005500 <sys_exec+0xd6>
    kfree(argv[i]);
    800054f6:	cf2fb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054fa:	04a1                	addi	s1,s1,8
    800054fc:	ff349be3          	bne	s1,s3,800054f2 <sys_exec+0xc8>
  return ret;
    80005500:	854a                	mv	a0,s2
    80005502:	74ba                	ld	s1,424(sp)
    80005504:	791a                	ld	s2,416(sp)
    80005506:	69fa                	ld	s3,408(sp)
    80005508:	6a5a                	ld	s4,400(sp)
    8000550a:	a031                	j	80005516 <sys_exec+0xec>
  return -1;
    8000550c:	557d                	li	a0,-1
    8000550e:	74ba                	ld	s1,424(sp)
    80005510:	791a                	ld	s2,416(sp)
    80005512:	69fa                	ld	s3,408(sp)
    80005514:	6a5a                	ld	s4,400(sp)
}
    80005516:	70fa                	ld	ra,440(sp)
    80005518:	745a                	ld	s0,432(sp)
    8000551a:	6139                	addi	sp,sp,448
    8000551c:	8082                	ret

000000008000551e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000551e:	7139                	addi	sp,sp,-64
    80005520:	fc06                	sd	ra,56(sp)
    80005522:	f822                	sd	s0,48(sp)
    80005524:	f426                	sd	s1,40(sp)
    80005526:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005528:	c50fc0ef          	jal	80001978 <myproc>
    8000552c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000552e:	fd840593          	addi	a1,s0,-40
    80005532:	4501                	li	a0,0
    80005534:	b9afd0ef          	jal	800028ce <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005538:	fc840593          	addi	a1,s0,-56
    8000553c:	fd040513          	addi	a0,s0,-48
    80005540:	f9ffe0ef          	jal	800044de <pipealloc>
    return -1;
    80005544:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005546:	0a054663          	bltz	a0,800055f2 <sys_pipe+0xd4>
  fd0 = -1;
    8000554a:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    8000554e:	fd043503          	ld	a0,-48(s0)
    80005552:	e82ff0ef          	jal	80004bd4 <fdalloc>
    80005556:	fca42223          	sw	a0,-60(s0)
    8000555a:	08054363          	bltz	a0,800055e0 <sys_pipe+0xc2>
    8000555e:	fc843503          	ld	a0,-56(s0)
    80005562:	e72ff0ef          	jal	80004bd4 <fdalloc>
    80005566:	fca42023          	sw	a0,-64(s0)
    8000556a:	06054263          	bltz	a0,800055ce <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000556e:	4711                	li	a4,4
    80005570:	fc440693          	addi	a3,s0,-60
    80005574:	fd843603          	ld	a2,-40(s0)
    80005578:	64ac                	ld	a1,72(s1)
    8000557a:	68a8                	ld	a0,80(s1)
    8000557c:	832fc0ef          	jal	800015ae <copyout>
    80005580:	00054f63          	bltz	a0,8000559e <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005584:	4711                	li	a4,4
    80005586:	fc040693          	addi	a3,s0,-64
    8000558a:	fd843603          	ld	a2,-40(s0)
    8000558e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005590:	64ac                	ld	a1,72(s1)
    80005592:	68a8                	ld	a0,80(s1)
    80005594:	81afc0ef          	jal	800015ae <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005598:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    8000559a:	04055c63          	bgez	a0,800055f2 <sys_pipe+0xd4>
    p->ofile[fd0] = 0;
    8000559e:	fc442783          	lw	a5,-60(s0)
    800055a2:	07e9                	addi	a5,a5,26
    800055a4:	078e                	slli	a5,a5,0x3
    800055a6:	97a6                	add	a5,a5,s1
    800055a8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800055ac:	fc042783          	lw	a5,-64(s0)
    800055b0:	07e9                	addi	a5,a5,26
    800055b2:	078e                	slli	a5,a5,0x3
    800055b4:	94be                	add	s1,s1,a5
    800055b6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800055ba:	fd043503          	ld	a0,-48(s0)
    800055be:	c01fe0ef          	jal	800041be <fileclose>
    fileclose(wf);
    800055c2:	fc843503          	ld	a0,-56(s0)
    800055c6:	bf9fe0ef          	jal	800041be <fileclose>
    return -1;
    800055ca:	57fd                	li	a5,-1
    800055cc:	a01d                	j	800055f2 <sys_pipe+0xd4>
    if (fd0 >= 0)
    800055ce:	fc442783          	lw	a5,-60(s0)
    800055d2:	0007c763          	bltz	a5,800055e0 <sys_pipe+0xc2>
      p->ofile[fd0] = 0;
    800055d6:	07e9                	addi	a5,a5,26
    800055d8:	078e                	slli	a5,a5,0x3
    800055da:	97a6                	add	a5,a5,s1
    800055dc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800055e0:	fd043503          	ld	a0,-48(s0)
    800055e4:	bdbfe0ef          	jal	800041be <fileclose>
    fileclose(wf);
    800055e8:	fc843503          	ld	a0,-56(s0)
    800055ec:	bd3fe0ef          	jal	800041be <fileclose>
    return -1;
    800055f0:	57fd                	li	a5,-1
}
    800055f2:	853e                	mv	a0,a5
    800055f4:	70e2                	ld	ra,56(sp)
    800055f6:	7442                	ld	s0,48(sp)
    800055f8:	74a2                	ld	s1,40(sp)
    800055fa:	6121                	addi	sp,sp,64
    800055fc:	8082                	ret
	...

0000000080005600 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005600:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005602:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005604:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005606:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005608:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000560a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000560c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000560e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005610:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005612:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005614:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005616:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005618:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000561a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000561c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000561e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005620:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005622:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005624:	912fd0ef          	jal	80002736 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005628:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000562a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000562c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000562e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005630:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005632:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005634:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005636:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005638:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000563a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000563c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000563e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005640:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005642:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005644:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005646:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005648:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000564a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000564c:	10200073          	sret
	...

000000008000565e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000565e:	1141                	addi	sp,sp,-16
    80005660:	e422                	sd	s0,8(sp)
    80005662:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(volatile uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005664:	0c0007b7          	lui	a5,0xc000
    80005668:	4705                	li	a4,1
    8000566a:	d798                	sw	a4,40(a5)
  *(volatile uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000566c:	0c0007b7          	lui	a5,0xc000
    80005670:	c3d8                	sw	a4,4(a5)
}
    80005672:	6422                	ld	s0,8(sp)
    80005674:	0141                	addi	sp,sp,16
    80005676:	8082                	ret

0000000080005678 <plicinithart>:

void
plicinithart(void)
{
    80005678:	1141                	addi	sp,sp,-16
    8000567a:	e406                	sd	ra,8(sp)
    8000567c:	e022                	sd	s0,0(sp)
    8000567e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005680:	accfc0ef          	jal	8000194c <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(volatile uint32 *)PLIC_SENABLE(hart) =
    80005684:	0085179b          	slliw	a5,a0,0x8
    80005688:	0c002737          	lui	a4,0xc002
    8000568c:	08070713          	addi	a4,a4,128 # c002080 <_entry-0x73ffdf80>
    80005690:	97ba                	add	a5,a5,a4
    80005692:	40200713          	li	a4,1026
    80005696:	c398                	sw	a4,0(a5)
    (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(volatile uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005698:	00d5151b          	slliw	a0,a0,0xd
    8000569c:	0c2017b7          	lui	a5,0xc201
    800056a0:	953e                	add	a0,a0,a5
    800056a2:	00052023          	sw	zero,0(a0)
}
    800056a6:	60a2                	ld	ra,8(sp)
    800056a8:	6402                	ld	s0,0(sp)
    800056aa:	0141                	addi	sp,sp,16
    800056ac:	8082                	ret

00000000800056ae <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800056ae:	1141                	addi	sp,sp,-16
    800056b0:	e406                	sd	ra,8(sp)
    800056b2:	e022                	sd	s0,0(sp)
    800056b4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056b6:	a96fc0ef          	jal	8000194c <cpuid>
  int irq = *(volatile uint32 *)PLIC_SCLAIM(hart);
    800056ba:	00d5151b          	slliw	a0,a0,0xd
    800056be:	0c2017b7          	lui	a5,0xc201
    800056c2:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    800056c4:	953e                	add	a0,a0,a5
    800056c6:	4108                	lw	a0,0(a0)
  return irq;
}
    800056c8:	60a2                	ld	ra,8(sp)
    800056ca:	6402                	ld	s0,0(sp)
    800056cc:	0141                	addi	sp,sp,16
    800056ce:	8082                	ret

00000000800056d0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800056d0:	1101                	addi	sp,sp,-32
    800056d2:	ec06                	sd	ra,24(sp)
    800056d4:	e822                	sd	s0,16(sp)
    800056d6:	e426                	sd	s1,8(sp)
    800056d8:	1000                	addi	s0,sp,32
    800056da:	84aa                	mv	s1,a0
  int hart = cpuid();
    800056dc:	a70fc0ef          	jal	8000194c <cpuid>
  *(volatile uint32 *)PLIC_SCLAIM(hart) = irq;
    800056e0:	00d5179b          	slliw	a5,a0,0xd
    800056e4:	0c201737          	lui	a4,0xc201
    800056e8:	0711                	addi	a4,a4,4 # c201004 <_entry-0x73dfeffc>
    800056ea:	97ba                	add	a5,a5,a4
    800056ec:	2481                	sext.w	s1,s1
    800056ee:	c384                	sw	s1,0(a5)
}
    800056f0:	60e2                	ld	ra,24(sp)
    800056f2:	6442                	ld	s0,16(sp)
    800056f4:	64a2                	ld	s1,8(sp)
    800056f6:	6105                	addi	sp,sp,32
    800056f8:	8082                	ret

00000000800056fa <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056fa:	1141                	addi	sp,sp,-16
    800056fc:	e406                	sd	ra,8(sp)
    800056fe:	e022                	sd	s0,0(sp)
    80005700:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005702:	479d                	li	a5,7
    80005704:	04a7ca63          	blt	a5,a0,80005758 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005708:	0001b797          	auipc	a5,0x1b
    8000570c:	3f878793          	addi	a5,a5,1016 # 80020b00 <disk>
    80005710:	97aa                	add	a5,a5,a0
    80005712:	0187c783          	lbu	a5,24(a5)
    80005716:	e7b9                	bnez	a5,80005764 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005718:	00451693          	slli	a3,a0,0x4
    8000571c:	0001b797          	auipc	a5,0x1b
    80005720:	3e478793          	addi	a5,a5,996 # 80020b00 <disk>
    80005724:	6398                	ld	a4,0(a5)
    80005726:	9736                	add	a4,a4,a3
    80005728:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000572c:	6398                	ld	a4,0(a5)
    8000572e:	9736                	add	a4,a4,a3
    80005730:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005734:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005738:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000573c:	97aa                	add	a5,a5,a0
    8000573e:	4705                	li	a4,1
    80005740:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005744:	0001b517          	auipc	a0,0x1b
    80005748:	3d450513          	addi	a0,a0,980 # 80020b18 <disk+0x18>
    8000574c:	89dfc0ef          	jal	80001fe8 <wakeup>
}
    80005750:	60a2                	ld	ra,8(sp)
    80005752:	6402                	ld	s0,0(sp)
    80005754:	0141                	addi	sp,sp,16
    80005756:	8082                	ret
    panic("free_desc 1");
    80005758:	00002517          	auipc	a0,0x2
    8000575c:	ed850513          	addi	a0,a0,-296 # 80007630 <etext+0x630>
    80005760:	890fb0ef          	jal	800007f0 <panic>
    panic("free_desc 2");
    80005764:	00002517          	auipc	a0,0x2
    80005768:	edc50513          	addi	a0,a0,-292 # 80007640 <etext+0x640>
    8000576c:	884fb0ef          	jal	800007f0 <panic>

0000000080005770 <virtio_disk_init>:
{
    80005770:	1101                	addi	sp,sp,-32
    80005772:	ec06                	sd	ra,24(sp)
    80005774:	e822                	sd	s0,16(sp)
    80005776:	e426                	sd	s1,8(sp)
    80005778:	e04a                	sd	s2,0(sp)
    8000577a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000577c:	00002597          	auipc	a1,0x2
    80005780:	ed458593          	addi	a1,a1,-300 # 80007650 <etext+0x650>
    80005784:	0001b517          	auipc	a0,0x1b
    80005788:	4a450513          	addi	a0,a0,1188 # 80020c28 <disk+0x128>
    8000578c:	c4afb0ef          	jal	80000bd6 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005790:	100017b7          	lui	a5,0x10001
    80005794:	4398                	lw	a4,0(a5)
    80005796:	2701                	sext.w	a4,a4
    80005798:	747277b7          	lui	a5,0x74727
    8000579c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800057a0:	18f71063          	bne	a4,a5,80005920 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057a4:	100017b7          	lui	a5,0x10001
    800057a8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800057aa:	439c                	lw	a5,0(a5)
    800057ac:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057ae:	4709                	li	a4,2
    800057b0:	16e79863          	bne	a5,a4,80005920 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057b4:	100017b7          	lui	a5,0x10001
    800057b8:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800057ba:	439c                	lw	a5,0(a5)
    800057bc:	2781                	sext.w	a5,a5
    800057be:	16e79163          	bne	a5,a4,80005920 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800057c2:	100017b7          	lui	a5,0x10001
    800057c6:	47d8                	lw	a4,12(a5)
    800057c8:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057ca:	554d47b7          	lui	a5,0x554d4
    800057ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800057d2:	14f71763          	bne	a4,a5,80005920 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057d6:	100017b7          	lui	a5,0x10001
    800057da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057de:	4705                	li	a4,1
    800057e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057e2:	470d                	li	a4,3
    800057e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800057e6:	10001737          	lui	a4,0x10001
    800057ea:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800057ec:	c7ffe737          	lui	a4,0xc7ffe
    800057f0:	55f70713          	addi	a4,a4,1375 # ffffffffc7ffe55f <end+0xffffffff47fdd91f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800057f4:	8ef9                	and	a3,a3,a4
    800057f6:	10001737          	lui	a4,0x10001
    800057fa:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057fc:	472d                	li	a4,11
    800057fe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005800:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005804:	439c                	lw	a5,0(a5)
    80005806:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000580a:	8ba1                	andi	a5,a5,8
    8000580c:	12078063          	beqz	a5,8000592c <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005810:	100017b7          	lui	a5,0x10001
    80005814:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005818:	100017b7          	lui	a5,0x10001
    8000581c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005820:	439c                	lw	a5,0(a5)
    80005822:	2781                	sext.w	a5,a5
    80005824:	10079a63          	bnez	a5,80005938 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005828:	100017b7          	lui	a5,0x10001
    8000582c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005830:	439c                	lw	a5,0(a5)
    80005832:	2781                	sext.w	a5,a5
  if (max == 0)
    80005834:	10078863          	beqz	a5,80005944 <virtio_disk_init+0x1d4>
  if (max < NUM)
    80005838:	471d                	li	a4,7
    8000583a:	10f77b63          	bgeu	a4,a5,80005950 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    8000583e:	a8cfb0ef          	jal	80000aca <kalloc>
    80005842:	0001b497          	auipc	s1,0x1b
    80005846:	2be48493          	addi	s1,s1,702 # 80020b00 <disk>
    8000584a:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000584c:	a7efb0ef          	jal	80000aca <kalloc>
    80005850:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005852:	a78fb0ef          	jal	80000aca <kalloc>
    80005856:	87aa                	mv	a5,a0
    80005858:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    8000585a:	6088                	ld	a0,0(s1)
    8000585c:	10050063          	beqz	a0,8000595c <virtio_disk_init+0x1ec>
    80005860:	0001b717          	auipc	a4,0x1b
    80005864:	2a873703          	ld	a4,680(a4) # 80020b08 <disk+0x8>
    80005868:	0e070a63          	beqz	a4,8000595c <virtio_disk_init+0x1ec>
    8000586c:	0e078863          	beqz	a5,8000595c <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005870:	6605                	lui	a2,0x1
    80005872:	4581                	li	a1,0
    80005874:	c9cfb0ef          	jal	80000d10 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005878:	0001b497          	auipc	s1,0x1b
    8000587c:	28848493          	addi	s1,s1,648 # 80020b00 <disk>
    80005880:	6605                	lui	a2,0x1
    80005882:	4581                	li	a1,0
    80005884:	6488                	ld	a0,8(s1)
    80005886:	c8afb0ef          	jal	80000d10 <memset>
  memset(disk.used, 0, PGSIZE);
    8000588a:	6605                	lui	a2,0x1
    8000588c:	4581                	li	a1,0
    8000588e:	6888                	ld	a0,16(s1)
    80005890:	c80fb0ef          	jal	80000d10 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005894:	100017b7          	lui	a5,0x10001
    80005898:	4721                	li	a4,8
    8000589a:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000589c:	4098                	lw	a4,0(s1)
    8000589e:	100017b7          	lui	a5,0x10001
    800058a2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800058a6:	40d8                	lw	a4,4(s1)
    800058a8:	100017b7          	lui	a5,0x10001
    800058ac:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800058b0:	649c                	ld	a5,8(s1)
    800058b2:	0007869b          	sext.w	a3,a5
    800058b6:	10001737          	lui	a4,0x10001
    800058ba:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800058be:	9781                	srai	a5,a5,0x20
    800058c0:	10001737          	lui	a4,0x10001
    800058c4:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058c8:	689c                	ld	a5,16(s1)
    800058ca:	0007869b          	sext.w	a3,a5
    800058ce:	10001737          	lui	a4,0x10001
    800058d2:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058d6:	9781                	srai	a5,a5,0x20
    800058d8:	10001737          	lui	a4,0x10001
    800058dc:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800058e0:	10001737          	lui	a4,0x10001
    800058e4:	4785                	li	a5,1
    800058e6:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058e8:	00f48c23          	sb	a5,24(s1)
    800058ec:	00f48ca3          	sb	a5,25(s1)
    800058f0:	00f48d23          	sb	a5,26(s1)
    800058f4:	00f48da3          	sb	a5,27(s1)
    800058f8:	00f48e23          	sb	a5,28(s1)
    800058fc:	00f48ea3          	sb	a5,29(s1)
    80005900:	00f48f23          	sb	a5,30(s1)
    80005904:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005908:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000590c:	100017b7          	lui	a5,0x10001
    80005910:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005914:	60e2                	ld	ra,24(sp)
    80005916:	6442                	ld	s0,16(sp)
    80005918:	64a2                	ld	s1,8(sp)
    8000591a:	6902                	ld	s2,0(sp)
    8000591c:	6105                	addi	sp,sp,32
    8000591e:	8082                	ret
    panic("could not find virtio disk");
    80005920:	00002517          	auipc	a0,0x2
    80005924:	d4050513          	addi	a0,a0,-704 # 80007660 <etext+0x660>
    80005928:	ec9fa0ef          	jal	800007f0 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000592c:	00002517          	auipc	a0,0x2
    80005930:	d5450513          	addi	a0,a0,-684 # 80007680 <etext+0x680>
    80005934:	ebdfa0ef          	jal	800007f0 <panic>
    panic("virtio disk should not be ready");
    80005938:	00002517          	auipc	a0,0x2
    8000593c:	d6850513          	addi	a0,a0,-664 # 800076a0 <etext+0x6a0>
    80005940:	eb1fa0ef          	jal	800007f0 <panic>
    panic("virtio disk has no queue 0");
    80005944:	00002517          	auipc	a0,0x2
    80005948:	d7c50513          	addi	a0,a0,-644 # 800076c0 <etext+0x6c0>
    8000594c:	ea5fa0ef          	jal	800007f0 <panic>
    panic("virtio disk max queue too short");
    80005950:	00002517          	auipc	a0,0x2
    80005954:	d9050513          	addi	a0,a0,-624 # 800076e0 <etext+0x6e0>
    80005958:	e99fa0ef          	jal	800007f0 <panic>
    panic("virtio disk kalloc");
    8000595c:	00002517          	auipc	a0,0x2
    80005960:	da450513          	addi	a0,a0,-604 # 80007700 <etext+0x700>
    80005964:	e8dfa0ef          	jal	800007f0 <panic>

0000000080005968 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005968:	7159                	addi	sp,sp,-112
    8000596a:	f486                	sd	ra,104(sp)
    8000596c:	f0a2                	sd	s0,96(sp)
    8000596e:	eca6                	sd	s1,88(sp)
    80005970:	e8ca                	sd	s2,80(sp)
    80005972:	e4ce                	sd	s3,72(sp)
    80005974:	e0d2                	sd	s4,64(sp)
    80005976:	fc56                	sd	s5,56(sp)
    80005978:	f85a                	sd	s6,48(sp)
    8000597a:	f45e                	sd	s7,40(sp)
    8000597c:	f062                	sd	s8,32(sp)
    8000597e:	ec66                	sd	s9,24(sp)
    80005980:	1880                	addi	s0,sp,112
    80005982:	8a2a                	mv	s4,a0
    80005984:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005986:	00c52c83          	lw	s9,12(a0)
    8000598a:	001c9c9b          	slliw	s9,s9,0x1
    8000598e:	1c82                	slli	s9,s9,0x20
    80005990:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005994:	0001b517          	auipc	a0,0x1b
    80005998:	29450513          	addi	a0,a0,660 # 80020c28 <disk+0x128>
    8000599c:	ab0fb0ef          	jal	80000c4c <acquire>
  for (int i = 0; i < 3; i++) {
    800059a0:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++) {
    800059a2:	44a1                	li	s1,8
      disk.free[i] = 0;
    800059a4:	0001bb17          	auipc	s6,0x1b
    800059a8:	15cb0b13          	addi	s6,s6,348 # 80020b00 <disk>
  for (int i = 0; i < 3; i++) {
    800059ac:	4a8d                	li	s5,3
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    800059ae:	0001bc17          	auipc	s8,0x1b
    800059b2:	16ac0c13          	addi	s8,s8,362 # 80020b18 <disk+0x18>
    800059b6:	a0bd                	j	80005a24 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800059b8:	00fb0733          	add	a4,s6,a5
    800059bc:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800059c0:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    800059c2:	0207c563          	bltz	a5,800059ec <virtio_disk_rw+0x84>
  for (int i = 0; i < 3; i++) {
    800059c6:	2905                	addiw	s2,s2,1
    800059c8:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059ca:	07590163          	beq	s2,s5,80005a2c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800059ce:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    800059d0:	0001b717          	auipc	a4,0x1b
    800059d4:	13070713          	addi	a4,a4,304 # 80020b00 <disk>
    800059d8:	87ce                	mv	a5,s3
    if (disk.free[i]) {
    800059da:	01874683          	lbu	a3,24(a4)
    800059de:	fee9                	bnez	a3,800059b8 <virtio_disk_rw+0x50>
  for (int i = 0; i < NUM; i++) {
    800059e0:	2785                	addiw	a5,a5,1
    800059e2:	0705                	addi	a4,a4,1
    800059e4:	fe979be3          	bne	a5,s1,800059da <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800059e8:	57fd                	li	a5,-1
    800059ea:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    800059ec:	01205d63          	blez	s2,80005a06 <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059f0:	f9042503          	lw	a0,-112(s0)
    800059f4:	d07ff0ef          	jal	800056fa <free_desc>
      for (int j = 0; j < i; j++)
    800059f8:	4785                	li	a5,1
    800059fa:	0127d663          	bge	a5,s2,80005a06 <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059fe:	f9442503          	lw	a0,-108(s0)
    80005a02:	cf9ff0ef          	jal	800056fa <free_desc>
    sleep_prepare(&disk.free[0]);
    80005a06:	8562                	mv	a0,s8
    80005a08:	d74fc0ef          	jal	80001f7c <sleep_prepare>
    release(&disk.vdisk_lock);
    80005a0c:	0001b917          	auipc	s2,0x1b
    80005a10:	21c90913          	addi	s2,s2,540 # 80020c28 <disk+0x128>
    80005a14:	854a                	mv	a0,s2
    80005a16:	ac2fb0ef          	jal	80000cd8 <release>
    sleep();
    80005a1a:	d9efc0ef          	jal	80001fb8 <sleep>
    acquire(&disk.vdisk_lock);
    80005a1e:	854a                	mv	a0,s2
    80005a20:	a2cfb0ef          	jal	80000c4c <acquire>
  for (int i = 0; i < 3; i++) {
    80005a24:	f9040613          	addi	a2,s0,-112
    80005a28:	894e                	mv	s2,s3
    80005a2a:	b755                	j	800059ce <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a2c:	f9042503          	lw	a0,-112(s0)
    80005a30:	00451693          	slli	a3,a0,0x4

  if (write)
    80005a34:	0001b797          	auipc	a5,0x1b
    80005a38:	0cc78793          	addi	a5,a5,204 # 80020b00 <disk>
    80005a3c:	00a50713          	addi	a4,a0,10
    80005a40:	0712                	slli	a4,a4,0x4
    80005a42:	973e                	add	a4,a4,a5
    80005a44:	01703633          	snez	a2,s7
    80005a48:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a4a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a4e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a52:	6398                	ld	a4,0(a5)
    80005a54:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a56:	0a868613          	addi	a2,a3,168
    80005a5a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005a5c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a5e:	6390                	ld	a2,0(a5)
    80005a60:	00d605b3          	add	a1,a2,a3
    80005a64:	4741                	li	a4,16
    80005a66:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a68:	4805                	li	a6,1
    80005a6a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005a6e:	f9442703          	lw	a4,-108(s0)
    80005a72:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005a76:	0712                	slli	a4,a4,0x4
    80005a78:	963a                	add	a2,a2,a4
    80005a7a:	058a0593          	addi	a1,s4,88
    80005a7e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a80:	0007b883          	ld	a7,0(a5)
    80005a84:	9746                	add	a4,a4,a7
    80005a86:	40000613          	li	a2,1024
    80005a8a:	c710                	sw	a2,8(a4)
  if (write)
    80005a8c:	001bb613          	seqz	a2,s7
    80005a90:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a94:	00166613          	ori	a2,a2,1
    80005a98:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a9c:	f9842583          	lw	a1,-104(s0)
    80005aa0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005aa4:	00250613          	addi	a2,a0,2
    80005aa8:	0612                	slli	a2,a2,0x4
    80005aaa:	963e                	add	a2,a2,a5
    80005aac:	577d                	li	a4,-1
    80005aae:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005ab2:	0592                	slli	a1,a1,0x4
    80005ab4:	98ae                	add	a7,a7,a1
    80005ab6:	03068713          	addi	a4,a3,48
    80005aba:	973e                	add	a4,a4,a5
    80005abc:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005ac0:	6398                	ld	a4,0(a5)
    80005ac2:	972e                	add	a4,a4,a1
    80005ac4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005ac8:	4689                	li	a3,2
    80005aca:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005ace:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005ad2:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005ad6:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ada:	6794                	ld	a3,8(a5)
    80005adc:	0026d703          	lhu	a4,2(a3)
    80005ae0:	8b1d                	andi	a4,a4,7
    80005ae2:	0706                	slli	a4,a4,0x1
    80005ae4:	96ba                	add	a3,a3,a4
    80005ae6:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005aea:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005aee:	6798                	ld	a4,8(a5)
    80005af0:	00275783          	lhu	a5,2(a4)
    80005af4:	2785                	addiw	a5,a5,1
    80005af6:	00f71123          	sh	a5,2(a4)
    80005afa:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005afe:	100017b7          	lui	a5,0x10001
    80005b02:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005b06:	004a2783          	lw	a5,4(s4)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005b0a:	0001b497          	auipc	s1,0x1b
    80005b0e:	11e48493          	addi	s1,s1,286 # 80020c28 <disk+0x128>
  while (b->disk == 1) {
    80005b12:	4905                	li	s2,1
    80005b14:	03079163          	bne	a5,a6,80005b36 <virtio_disk_rw+0x1ce>
    sleep_prepare(b);
    80005b18:	8552                	mv	a0,s4
    80005b1a:	c62fc0ef          	jal	80001f7c <sleep_prepare>
    release(&disk.vdisk_lock);
    80005b1e:	8526                	mv	a0,s1
    80005b20:	9b8fb0ef          	jal	80000cd8 <release>
    sleep();
    80005b24:	c94fc0ef          	jal	80001fb8 <sleep>
    acquire(&disk.vdisk_lock);
    80005b28:	8526                	mv	a0,s1
    80005b2a:	922fb0ef          	jal	80000c4c <acquire>
  while (b->disk == 1) {
    80005b2e:	004a2783          	lw	a5,4(s4)
    80005b32:	ff2783e3          	beq	a5,s2,80005b18 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80005b36:	f9042903          	lw	s2,-112(s0)
    80005b3a:	00290713          	addi	a4,s2,2
    80005b3e:	0712                	slli	a4,a4,0x4
    80005b40:	0001b797          	auipc	a5,0x1b
    80005b44:	fc078793          	addi	a5,a5,-64 # 80020b00 <disk>
    80005b48:	97ba                	add	a5,a5,a4
    80005b4a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b4e:	0001b997          	auipc	s3,0x1b
    80005b52:	fb298993          	addi	s3,s3,-78 # 80020b00 <disk>
    80005b56:	00491713          	slli	a4,s2,0x4
    80005b5a:	0009b783          	ld	a5,0(s3)
    80005b5e:	97ba                	add	a5,a5,a4
    80005b60:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b64:	854a                	mv	a0,s2
    80005b66:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b6a:	b91ff0ef          	jal	800056fa <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005b6e:	8885                	andi	s1,s1,1
    80005b70:	f0fd                	bnez	s1,80005b56 <virtio_disk_rw+0x1ee>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b72:	0001b517          	auipc	a0,0x1b
    80005b76:	0b650513          	addi	a0,a0,182 # 80020c28 <disk+0x128>
    80005b7a:	95efb0ef          	jal	80000cd8 <release>
}
    80005b7e:	70a6                	ld	ra,104(sp)
    80005b80:	7406                	ld	s0,96(sp)
    80005b82:	64e6                	ld	s1,88(sp)
    80005b84:	6946                	ld	s2,80(sp)
    80005b86:	69a6                	ld	s3,72(sp)
    80005b88:	6a06                	ld	s4,64(sp)
    80005b8a:	7ae2                	ld	s5,56(sp)
    80005b8c:	7b42                	ld	s6,48(sp)
    80005b8e:	7ba2                	ld	s7,40(sp)
    80005b90:	7c02                	ld	s8,32(sp)
    80005b92:	6ce2                	ld	s9,24(sp)
    80005b94:	6165                	addi	sp,sp,112
    80005b96:	8082                	ret

0000000080005b98 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b98:	1101                	addi	sp,sp,-32
    80005b9a:	ec06                	sd	ra,24(sp)
    80005b9c:	e822                	sd	s0,16(sp)
    80005b9e:	e426                	sd	s1,8(sp)
    80005ba0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005ba2:	0001b497          	auipc	s1,0x1b
    80005ba6:	f5e48493          	addi	s1,s1,-162 # 80020b00 <disk>
    80005baa:	0001b517          	auipc	a0,0x1b
    80005bae:	07e50513          	addi	a0,a0,126 # 80020c28 <disk+0x128>
    80005bb2:	89afb0ef          	jal	80000c4c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005bb6:	100017b7          	lui	a5,0x10001
    80005bba:	53b8                	lw	a4,96(a5)
    80005bbc:	8b0d                	andi	a4,a4,3
    80005bbe:	100017b7          	lui	a5,0x10001
    80005bc2:	d3f8                	sw	a4,100(a5)
    80005bc4:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005bc8:	689c                	ld	a5,16(s1)
    80005bca:	0204d703          	lhu	a4,32(s1)
    80005bce:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005bd2:	04f70663          	beq	a4,a5,80005c1e <virtio_disk_intr+0x86>
    80005bd6:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005bda:	6898                	ld	a4,16(s1)
    80005bdc:	0204d783          	lhu	a5,32(s1)
    80005be0:	8b9d                	andi	a5,a5,7
    80005be2:	078e                	slli	a5,a5,0x3
    80005be4:	97ba                	add	a5,a5,a4
    80005be6:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005be8:	00278713          	addi	a4,a5,2
    80005bec:	0712                	slli	a4,a4,0x4
    80005bee:	9726                	add	a4,a4,s1
    80005bf0:	01074703          	lbu	a4,16(a4)
    80005bf4:	e321                	bnez	a4,80005c34 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005bf6:	0789                	addi	a5,a5,2
    80005bf8:	0792                	slli	a5,a5,0x4
    80005bfa:	97a6                	add	a5,a5,s1
    80005bfc:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005bfe:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c02:	be6fc0ef          	jal	80001fe8 <wakeup>

    disk.used_idx += 1;
    80005c06:	0204d783          	lhu	a5,32(s1)
    80005c0a:	2785                	addiw	a5,a5,1
    80005c0c:	17c2                	slli	a5,a5,0x30
    80005c0e:	93c1                	srli	a5,a5,0x30
    80005c10:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005c14:	6898                	ld	a4,16(s1)
    80005c16:	00275703          	lhu	a4,2(a4)
    80005c1a:	faf71ee3          	bne	a4,a5,80005bd6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c1e:	0001b517          	auipc	a0,0x1b
    80005c22:	00a50513          	addi	a0,a0,10 # 80020c28 <disk+0x128>
    80005c26:	8b2fb0ef          	jal	80000cd8 <release>
}
    80005c2a:	60e2                	ld	ra,24(sp)
    80005c2c:	6442                	ld	s0,16(sp)
    80005c2e:	64a2                	ld	s1,8(sp)
    80005c30:	6105                	addi	sp,sp,32
    80005c32:	8082                	ret
      panic("virtio_disk_intr status");
    80005c34:	00002517          	auipc	a0,0x2
    80005c38:	ae450513          	addi	a0,a0,-1308 # 80007718 <etext+0x718>
    80005c3c:	bb5fa0ef          	jal	800007f0 <panic>

0000000080005c40 <pci_init>:
    return (volatile uint16 *)addr;
}

void
pci_init(void)
{
    80005c40:	7119                	addi	sp,sp,-128
    80005c42:	fc86                	sd	ra,120(sp)
    80005c44:	f8a2                	sd	s0,112(sp)
    80005c46:	f4a6                	sd	s1,104(sp)
    80005c48:	f0ca                	sd	s2,96(sp)
    80005c4a:	ecce                	sd	s3,88(sp)
    80005c4c:	e8d2                	sd	s4,80(sp)
    80005c4e:	e4d6                	sd	s5,72(sp)
    80005c50:	e0da                	sd	s6,64(sp)
    80005c52:	fc5e                	sd	s7,56(sp)
    80005c54:	f862                	sd	s8,48(sp)
    80005c56:	f466                	sd	s9,40(sp)
    80005c58:	f06a                	sd	s10,32(sp)
    80005c5a:	ec6e                	sd	s11,24(sp)
    80005c5c:	0100                	addi	s0,sp,128
    int dev, func;
    uint16 vendor, device;
    int found = 0;

    printk("PCI: scanning bus 0\n");
    80005c5e:	00002517          	auipc	a0,0x2
    80005c62:	ad250513          	addi	a0,a0,-1326 # 80007730 <etext+0x730>
    80005c66:	8a5fa0ef          	jal	8000050a <printk>
    80005c6a:	30000db7          	lui	s11,0x30000
    int found = 0;
    80005c6e:	f8043023          	sd	zero,-128(s0)

    for (dev = 0; dev < 32; dev++) {
    80005c72:	4c01                	li	s8,0
        for (func = 0; func < 8; func++) {
            vendor = *pci_config_addr(dev, func, PCI_VENDOR_ID);

            if (vendor == 0xffff || vendor == 0x0000)
    80005c74:	6ac1                	lui	s5,0x10
    80005c76:	1af5                	addi	s5,s5,-3 # fffd <_entry-0x7fff0003>
                continue;

            device = *pci_config_addr(dev, func, PCI_DEVICE_ID);

            printk("PCI: bus 0 dev %d func %d vendor 0x%x device 0x%x\n",
    80005c78:	00002d17          	auipc	s10,0x2
    80005c7c:	ad0d0d13          	addi	s10,s10,-1328 # 80007748 <etext+0x748>
                   dev, func, vendor, device);

            if (vendor == PCI_VENDOR_INTEL &&
    80005c80:	6ca1                	lui	s9,0x8
    80005c82:	086c8c93          	addi	s9,s9,134 # 8086 <_entry-0x7fff7f7a>
    80005c86:	6785                	lui	a5,0x1
    80005c88:	07b9                	addi	a5,a5,14 # 100e <_entry-0x7fffeff2>
    80005c8a:	f8f43423          	sd	a5,-120(s0)
        for (func = 0; func < 8; func++) {
    80005c8e:	6b85                	lui	s7,0x1
    80005c90:	a0ad                	j	80005cfa <pci_init+0xba>
    80005c92:	2485                	addiw	s1,s1,1
    80005c94:	995e                	add	s2,s2,s7
    80005c96:	05448b63          	beq	s1,s4,80005cec <pci_init+0xac>
            vendor = *pci_config_addr(dev, func, PCI_VENDOR_ID);
    80005c9a:	00095783          	lhu	a5,0(s2)
    80005c9e:	03079993          	slli	s3,a5,0x30
    80005ca2:	0309d993          	srli	s3,s3,0x30
            if (vendor == 0xffff || vendor == 0x0000)
    80005ca6:	37fd                	addiw	a5,a5,-1
    80005ca8:	17c2                	slli	a5,a5,0x30
    80005caa:	93c1                	srli	a5,a5,0x30
    80005cac:	fefae3e3          	bltu	s5,a5,80005c92 <pci_init+0x52>
            device = *pci_config_addr(dev, func, PCI_DEVICE_ID);
    80005cb0:	00295703          	lhu	a4,2(s2)
    80005cb4:	03071b13          	slli	s6,a4,0x30
    80005cb8:	030b5b13          	srli	s6,s6,0x30
            printk("PCI: bus 0 dev %d func %d vendor 0x%x device 0x%x\n",
    80005cbc:	2981                	sext.w	s3,s3
    80005cbe:	86ce                	mv	a3,s3
    80005cc0:	8626                	mv	a2,s1
    80005cc2:	85e2                	mv	a1,s8
    80005cc4:	856a                	mv	a0,s10
    80005cc6:	845fa0ef          	jal	8000050a <printk>
            if (vendor == PCI_VENDOR_INTEL &&
    80005cca:	fd9994e3          	bne	s3,s9,80005c92 <pci_init+0x52>
    80005cce:	2b01                	sext.w	s6,s6
    80005cd0:	f8843783          	ld	a5,-120(s0)
    80005cd4:	fafb1fe3          	bne	s6,a5,80005c92 <pci_init+0x52>
                device == PCI_DEVICE_E1000) {
                printk("PCI: E1000 detected!\n");
    80005cd8:	00002517          	auipc	a0,0x2
    80005cdc:	aa850513          	addi	a0,a0,-1368 # 80007780 <etext+0x780>
    80005ce0:	82bfa0ef          	jal	8000050a <printk>
                found = 1;
    80005ce4:	4785                	li	a5,1
    80005ce6:	f8f43023          	sd	a5,-128(s0)
    80005cea:	b765                	j	80005c92 <pci_init+0x52>
    for (dev = 0; dev < 32; dev++) {
    80005cec:	2c05                	addiw	s8,s8,1
    80005cee:	67a1                	lui	a5,0x8
    80005cf0:	9dbe                	add	s11,s11,a5
    80005cf2:	02000793          	li	a5,32
    80005cf6:	00fc0663          	beq	s8,a5,80005d02 <pci_init+0xc2>
{
    80005cfa:	896e                	mv	s2,s11
        for (func = 0; func < 8; func++) {
    80005cfc:	4481                	li	s1,0
    80005cfe:	4a21                	li	s4,8
    80005d00:	bf69                	j	80005c9a <pci_init+0x5a>
            }
        }
    }

    if (!found)
    80005d02:	f8043783          	ld	a5,-128(s0)
    80005d06:	c385                	beqz	a5,80005d26 <pci_init+0xe6>
        printk("PCI: E1000 8086:100e not found on bus 0\n");
}
    80005d08:	70e6                	ld	ra,120(sp)
    80005d0a:	7446                	ld	s0,112(sp)
    80005d0c:	74a6                	ld	s1,104(sp)
    80005d0e:	7906                	ld	s2,96(sp)
    80005d10:	69e6                	ld	s3,88(sp)
    80005d12:	6a46                	ld	s4,80(sp)
    80005d14:	6aa6                	ld	s5,72(sp)
    80005d16:	6b06                	ld	s6,64(sp)
    80005d18:	7be2                	ld	s7,56(sp)
    80005d1a:	7c42                	ld	s8,48(sp)
    80005d1c:	7ca2                	ld	s9,40(sp)
    80005d1e:	7d02                	ld	s10,32(sp)
    80005d20:	6de2                	ld	s11,24(sp)
    80005d22:	6109                	addi	sp,sp,128
    80005d24:	8082                	ret
        printk("PCI: E1000 8086:100e not found on bus 0\n");
    80005d26:	00002517          	auipc	a0,0x2
    80005d2a:	a7250513          	addi	a0,a0,-1422 # 80007798 <etext+0x798>
    80005d2e:	fdcfa0ef          	jal	8000050a <printk>
}
    80005d32:	bfd9                	j	80005d08 <pci_init+0xc8>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
