# Gửi UDP tới xv6 qua hostfwd. Ví dụ: ./udp_probe.py --msg hello --expect none
import argparse, socket, sys

ap = argparse.ArgumentParser()
ap.add_argument("--port", type=int, default=26000)
ap.add_argument("--msg", default="hello")
ap.add_argument("--timeout", type=float, default=2.0)
ap.add_argument("--expect", choices=["echo", "none"], default="none")
a = ap.parse_args()

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(a.timeout)
s.sendto(a.msg.encode(), ("127.0.0.1", a.port))
try:
    data, _ = s.recvfrom(2048)
    got = data.decode(errors="replace")
except socket.timeout:
    got = None

if a.expect == "echo":
    ok = got == a.msg
    print(("PASS" if ok else "FAIL") + ": udp_echo (nhận %r)" % got)
else:
    ok = got is None
    print(("PASS" if ok else "FAIL") + ": udp_no_reply (nhận %r)" % got)
sys.exit(0 if ok else 1)