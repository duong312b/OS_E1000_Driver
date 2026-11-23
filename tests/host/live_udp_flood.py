# Test chiu tai RX: ban dồn datagram vao xv6 nhanh hon nhieu so voi RX ring (8 descriptor)
# va hang doi socket (16). Cho phep mat goi (drop co dem), nhung xv6 khong duoc treo/panic
# va phai echo binh thuong lai ngay sau flood.
# Yeu cau trong xv6 dang chay: udp_echo 2000 (tests/run_all.sh tu go).
import os, socket, sys, time

port = int(os.environ.get("FWDPORT", "26000"))
NFLOOD = int(os.environ.get("FLOOD_N", "2000"))
nfail = 0

def report(name, ok, why=""):
    global nfail
    print(("PASS: " if ok else "FAIL: ") + name + ("" if ok else " (%s)" % why))
    if not ok:
        nfail += 1

def echo_once(s, payload, timeout=1.0):
    s.settimeout(timeout)
    s.sendto(payload, ("127.0.0.1", port))
    try:
        while True:
            data, _ = s.recvfrom(4096)
            if data == payload:
                return True
    except socket.timeout:
        return False

def alive(s, tag, tries=5):
    return any(echo_once(s, ("alive-%s-%d" % (tag, i)).encode()) for i in range(tries))

def drain(s, secs):
    """Doc het echo con lai trong `secs` giay, tra ve tap payload nhan duoc."""
    got = set()
    s.settimeout(0.2)
    end = time.time() + secs
    while time.time() < end:
        try:
            got.add(s.recvfrom(4096)[0])
        except socket.timeout:
            pass
    return got

def flood(s, size, n):
    sent = []
    for i in range(n):
        p = (b"f%d-%d-" % (size, i)).ljust(size, b"x")
        sent.append(p)
        s.sendto(p, ("127.0.0.1", port))
    got = drain(s, 3.0)
    return len(got & set(sent)), got - set(sent)

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4 << 20)

if not alive(s, "pre", tries=20):
    report("udp_flood_precondition", False, "xv6 khong echo truoc khi flood")
    sys.exit(1)

for size in (64, 1472):
    t0 = time.time()
    ok, junk = flood(s, size, NFLOOD)
    dt = time.time() - t0
    print("INFO: flood %d x %d B: echo %d/%d (mat %.1f%%), %.1f s" %
          (NFLOOD, size, ok, NFLOOD, 100.0 * (NFLOOD - ok) / NFLOOD, dt))
    report("udp_flood_%d_some_delivered" % size, ok > 0, "khong echo goi nao")
    report("udp_flood_%d_no_corruption" % size, not junk, "%d echo sai noi dung" % len(junk))
    report("udp_flood_%d_alive_after" % size, alive(s, str(size)), "xv6 khong echo sau flood")

# Toc do vua phai (lo 8 goi, nghi giua cac lo): vua RX ring, ky vong gan nhu khong mat.
sent, got = [], set()
for b in range(50):
    batch = [b"paced-%d-%d" % (b, k) for k in range(8)]
    for p in batch:
        s.sendto(p, ("127.0.0.1", port))
    sent += batch
    got |= drain(s, 0.05)
got |= drain(s, 1.0)
lost = len(set(sent) - got)
print("INFO: paced 50 lo x 8 goi: mat %d/%d" % (lost, len(sent)))
report("udp_paced_burst8_loss_le_1pct", lost * 100 <= len(sent), "mat %d/%d" % (lost, len(sent)))

s.close()
sys.exit(1 if nfail else 0)
