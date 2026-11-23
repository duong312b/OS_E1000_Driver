# Test UDP echo host <-> xv6. Yeu cau trong xv6 dang chay: udp_echo 2000
# (tests/run_all.sh tu go lenh nay truoc nettests).
# Host gui toi 127.0.0.1:FWDPORT, slirp chuyen vao 10.0.2.15:2000,
# udp_echo gui tra ve 10.0.2.2:<cong nguon> -> slirp tra lai socket nay.
import os, socket, sys, time

port = int(os.environ.get("FWDPORT", "26000"))
WARMUP = float(os.environ.get("ECHO_WARMUP", "20"))   # giay cho xv6 boot + ARP
nfail = 0

def report(name, ok, why=""):
    global nfail
    print(("PASS: " if ok else "FAIL: ") + name + ("" if ok else " (%s)" % why))
    if not ok:
        nfail += 1

def echo_once(s, payload, timeout=2.0):
    s.settimeout(timeout)
    s.sendto(payload, ("127.0.0.1", port))
    try:
        while True:
            data, _ = s.recvfrom(4096)
            if data == payload:
                return True
    except socket.timeout:
        return False

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# 1. Lan dau: lap lai cho den khi echo thanh cong (xv6 co the chua boot / chua ARP xong).
deadline = time.time() + WARMUP
ok = False
while time.time() < deadline and not ok:
    ok = echo_once(s, b"warmup", timeout=1.0)
report("udp_echo_first", ok, "khong nhan duoc echo sau %ds" % WARMUP)
if not ok:
    sys.exit(1)

# 2. Nhieu kich thuoc payload, kiem tra tung byte.
for n in (1, 64, 512, 1024, 1472):
    data = bytes((i * 31 + n) & 0xff for i in range(n))
    report("udp_echo_%d" % n, echo_once(s, data), "sai/mat echo %d byte" % n)

# 3. Datagram rong.
report("udp_echo_empty", echo_once(s, b""), "khong echo datagram 0 byte")

# 4. Burst 6 goi (RX ring 8 descriptor, poll 10 lan/giay): phai nhan du va dung noi dung.
s.settimeout(3.0)
sent = [("burst-%d" % i).encode() for i in range(6)]
for p in sent:
    s.sendto(p, ("127.0.0.1", port))
got = set()
try:
    while len(got) < len(sent):
        data, _ = s.recvfrom(4096)
        got.add(data)
except socket.timeout:
    pass
report("udp_echo_burst6", got == set(sent), "nhan %d/%d" % (len(got & set(sent)), len(sent)))

# 5. Hai socket host khac cong nguon: moi ben chi nhan echo cua minh.
s2 = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.sendto(b"from-s1", ("127.0.0.1", port))
s2.sendto(b"from-s2", ("127.0.0.1", port))
s.settimeout(2.0); s2.settimeout(2.0)
try:
    a = s.recvfrom(4096)[0]; b = s2.recvfrom(4096)[0]
    report("udp_echo_two_clients", a == b"from-s1" and b == b"from-s2", "a=%r b=%r" % (a, b))
except socket.timeout:
    report("udp_echo_two_clients", False, "timeout")

# 6. Do RTT. RX bang ngat E1000: RTT < 1 ms. Neu ngat hong va chi con net_poll() trong
#    clockintr (10 Hz) thi RTT ~ 50-100 ms -> test nay bat duoc (ngat phan cung, gian tiep).
RTT_MAX_MS = float(os.environ.get("RTT_MAX_MS", "20"))
rtts = []
for i in range(10):
    t0 = time.time()
    if echo_once(s, b"rtt-%d" % i):
        rtts.append((time.time() - t0) * 1000)
if rtts:
    mean = sum(rtts) / len(rtts)
    sd = (sum((x - mean) ** 2 for x in rtts) / len(rtts)) ** 0.5
    print("INFO: udp echo RTT %d mau: mean=%.1f ms sd=%.1f ms" % (len(rtts), mean, sd))
report("udp_rtt_interrupt_driven", len(rtts) == 10 and sum(rtts) / len(rtts) < RTT_MAX_MS,
       "%d/10 mau, mean=%.1f ms >= %.0f ms -> RX khong chay bang ngat?" %
       (len(rtts), (sum(rtts) / len(rtts)) if rtts else -1, RTT_MAX_MS))

s.close(); s2.close()
sys.exit(1 if nfail else 0)
