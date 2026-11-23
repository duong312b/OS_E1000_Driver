#!/usr/bin/env python3
# Client UDP echo chay tay (khong phai test tu dong).
#   trong xv6 : udp_echo 2000
#   tren host : python3 tests/host/udp_echo_client.py [--host 127.0.0.1] [--port 26000] [msg...]
# Che do slirp (mac dinh): gui toi 127.0.0.1:FWDPORT, hostfwd chuyen vao 10.0.2.15:2000.
# Che do TAP (make qemu NET=tap): --host 192.168.100.2 --port 2000.
# Ma thoat: 0 neu moi msg deu duoc echo dung, 1 neu co timeout/sai noi dung.
import argparse, socket, sys, time

ap = argparse.ArgumentParser()
ap.add_argument("--host", default="127.0.0.1")
ap.add_argument("--port", type=int, default=26000)
ap.add_argument("--timeout", type=float, default=2.0)
ap.add_argument("msg", nargs="*", default=["hello xv6"])
a = ap.parse_args()

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(a.timeout)
bad = 0
for m in a.msg:
    t0 = time.perf_counter()
    s.sendto(m.encode(), (a.host, a.port))
    try:
        data, _ = s.recvfrom(4096)
        rtt = (time.perf_counter() - t0) * 1000
        ok = data == m.encode()
        print("%s %r  (%.2f ms)" % ("echo:" if ok else "MISMATCH:",
                                    data.decode(errors="replace"), rtt))
        bad += not ok
    except socket.timeout:
        print("timeout: %r" % m)
        bad += 1
sys.exit(1 if bad else 0)
