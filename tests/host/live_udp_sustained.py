# Tai keo dai: echo stop-and-wait lien tuc trong SUSTAIN_SECS giay (mac dinh 10). PASS neu ti le mat <= MAX_LOSS_PCT va khong co khoang lang > MAX_GAP giay
# (khoang lang dai = xv6 treo / RX ngung).
# Yeu cau trong xv6 dang chay: udp_echo 2000.
import os, socket, sys, time

port = int(os.environ.get("FWDPORT", "26000"))
SECS = float(os.environ.get("SUSTAIN_SECS", "10"))
MAX_LOSS = float(os.environ.get("MAX_LOSS_PCT", "1"))
MAX_GAP = float(os.environ.get("MAX_GAP", "3"))
NAME = "udp_echo_sustained"

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(0.5)
sent = recvd = 0
rtts = []
last_ok = t_start = time.time()
max_gap = 0.0
i = 0
while True:
    now = time.time()
    if now - t_start >= SECS:
        break
    p = b"sus-%d-" % i + bytes((i + k) & 0xff for k in range(i % 1400))
    i += 1
    t0 = time.time()
    s.sendto(p, ("127.0.0.1", port))
    sent += 1
    try:
        while True:
            data = s.recvfrom(4096)[0]
            if data == p:
                break
        recvd += 1
        rtts.append((time.time() - t0) * 1000)
        max_gap = max(max_gap, time.time() - last_ok)
        last_ok = time.time()
    except socket.timeout:
        pass
max_gap = max(max_gap, time.time() - last_ok)

dur = time.time() - t_start
loss = 100.0 * (sent - recvd) / sent if sent else 100.0
mean = sum(rtts) / len(rtts) if rtts else -1
print("INFO: %s %.0f s: %d/%d echo (mat %.2f%%), %.0f echo/s, RTT mean %.2f ms, "
      "khoang lang dai nhat %.2f s" % (NAME, dur, recvd, sent, loss, recvd / dur, mean, max_gap))
ok = sent > 0 and loss <= MAX_LOSS and max_gap <= MAX_GAP
print(("PASS: " if ok else "FAIL: ") + NAME +
      ("" if ok else " (mat %.2f%% > %.1f%% hoac lang %.1f s > %.1f s)" % (loss, MAX_LOSS, max_gap, MAX_GAP)))
sys.exit(0 if ok else 1)
