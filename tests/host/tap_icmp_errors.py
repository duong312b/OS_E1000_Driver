#!/usr/bin/env python3
"""Live ICMP / IPv4 tests against a running xv6 over a TAP interface (week 5, role B).

NAME NOTE: deliberately NOT called live_*.py / test_*.py. tests/run_all.sh runs every live_*.py
automatically during `make test` (slirp mode, no tap0, no root) - this script would fail there.
Run it only through `make -C tests/host tap-icmp` or tests/host/tap_ping_check.sh.

Setup (host, once):
    sudo ip tuntap add dev tap0 mode tap user $USER
    sudo ip addr add 192.168.100.1/24 dev tap0 && sudo ip link set tap0 up
Run xv6 in TAP mode (xv6 must have IP 192.168.100.2), then, as root (AF_PACKET needs it):
    sudo python3 tests/host/tap_icmp_errors.py [--iface tap0] [--host-ip ...] [--xv6-ip ...]

Every test prints "PASS name" or "FAIL name: reason"; exit status is 0 only if all passed.
Negative tests (malformed packets) check that xv6 stays SILENT and then that it still answers a
valid probe ("liveness"), so a crash/hang/leak after bad input is caught too.

`--dump-frames` prints the frames the tests would send as hex (no root, no xv6); it is used to
cross-check these builders against the kernel's own parser (week4_ip_parse) on the host.
"""
import argparse
import os
import select
import shutil
import socket
import struct
import subprocess
import sys
import time

ETH_P_ALL = 0x0003
QUIET_S = 0.8     # how long a negative test waits for a (wrongly) produced reply
REPLY_S = 1.5     # how long a positive test waits for a reply

cfg = argparse.Namespace()
sock = None
host_mac = b""
xv6_mac = b""
ident = [0x1000]


# ----------------------------------------------------------------------------- packet building
def cksum(b):
    """RFC 1071 internet checksum; result is the value to store (network order when packed '!H')."""
    if len(b) & 1:
        b += b"\0"
    s = sum(struct.unpack("!%dH" % (len(b) // 2), b))
    while s >> 16:
        s = (s & 0xFFFF) + (s >> 16)
    return (~s) & 0xFFFF


def ip2b(a):
    return socket.inet_aton(a)


def pattern(n):
    # Differs from xv6's own i&0xff pattern on purpose: the reply must echo OUR bytes.
    return bytes(((i * 7 + 3) & 0xFF) for i in range(n))


def eth(dst, src, etype, payload, pad=True):
    f = dst + src + struct.pack("!H", etype) + payload
    if pad and len(f) < 60:
        f += b"\0" * (60 - len(f))
    return f


def icmp_msg(typ, code, id_, seq, data, bad_sum=False):
    h = struct.pack("!BBHHH", typ, code, 0, id_, seq)
    c = cksum(h + data)
    if bad_sum:
        c ^= 0x1234
    return struct.pack("!BBHHH", typ, code, c, id_, seq) + data


def ip_pkt(src, dst, proto, payload, ttl=64, off=0, opts=b"", vhl=None, total=None, bad_sum=False):
    ident[0] = (ident[0] + 1) & 0xFFFF
    ihl = 5 + len(opts) // 4
    if vhl is None:
        vhl = (4 << 4) | ihl
    if total is None:
        total = ihl * 4 + len(payload)
    hdr = struct.pack("!BBHHHBBH4s4s", vhl, 0, total, ident[0], off, ttl, proto, 0,
                      ip2b(src), ip2b(dst)) + opts
    c = cksum(hdr)                     # over the header bytes actually emitted (20 + options)
    if bad_sum:
        c ^= 0x00FF
    hdr = hdr[:10] + struct.pack("!H", c) + hdr[12:]
    return hdr + payload


def echo_frame(id_, seq, n, **kw):
    """Echo request host -> xv6. kw: ttl, off, opts, vhl, total, dst, bad_ip_sum, bad_icmp_sum,
    icmp_type, icmp_code, eth_dst, trailer, pad."""
    data = pattern(n)
    ic = icmp_msg(kw.get("icmp_type", 8), kw.get("icmp_code", 0), id_, seq, data,
                  kw.get("bad_icmp_sum", False))
    ipp = ip_pkt(cfg.host_ip, kw.get("dst", cfg.xv6_ip), 1, ic, kw.get("ttl", 64),
                 kw.get("off", 0), kw.get("opts", b""), kw.get("vhl"), kw.get("total"),
                 kw.get("bad_ip_sum", False))
    f = eth(kw.get("eth_dst", xv6_mac), host_mac, 0x0800, ipp, kw.get("pad", True))
    return f + kw.get("trailer", b"")


# ----------------------------------------------------------------------------- socket helpers
def drain():
    while select.select([sock], [], [], 0)[0]:
        sock.recv(4096)


def sniff(pred, timeout):
    """Return the first frame from xv6 for which pred(frame) is true, else None."""
    end = time.time() + timeout
    while True:
        left = end - time.time()
        if left <= 0:
            return None
        if not select.select([sock], [], [], left)[0]:
            return None
        f = sock.recv(4096)
        if len(f) >= 14 and f[6:12] == xv6_mac and pred(f):
            return f


def is_reply(id_, seq):
    def p(f):
        if f[12:14] != b"\x08\x00" or len(f) < 14 + 20 + 8:
            return False
        ihl = (f[14] & 15) * 4
        if f[14 + 9] != 1:
            return False
        t, _c, _s, i, s = struct.unpack("!BBHHH", f[14 + ihl: 14 + ihl + 8])
        return t == 0 and i == id_ and s == seq
    return p


def check_reply(f, id_, seq, n):
    """Return None if `f` is a perfect echo reply, else a reason string."""
    if f[0:6] != host_mac:
        return "wrong L2 destination"
    ihl = (f[14] & 15) * 4
    if f[14] >> 4 != 4 or ihl != 20:
        return "IP header not 20 bytes (options must be stripped): vhl=0x%02x" % f[14]
    if cksum(f[14:34]) != 0:
        return "bad IP header checksum"
    total = struct.unpack("!H", f[16:18])[0]
    if total != 20 + 8 + n:
        return "IP total length %d, expected %d" % (total, 28 + n)
    if f[14 + 8] != 64:
        return "ttl %d, expected 64" % f[22]
    if f[26:30] != ip2b(cfg.xv6_ip) or f[30:34] != ip2b(cfg.host_ip):
        return "IP src/dst wrong"
    icmp = f[34: 14 + total]
    if cksum(icmp) != 0:
        return "bad ICMP checksum"
    if icmp[0] != 0 or icmp[1] != 0:
        return "type/code != 0/0"
    if icmp[8:] != pattern(n):
        return "payload not echoed unchanged"
    return None


def probe(id_, seq, n=56, **kw):
    """Send a request and expect a perfect reply. Returns reason string or None."""
    drain()
    sock.send(echo_frame(id_, seq, n, **kw))
    f = sniff(is_reply(id_, seq), REPLY_S)
    if f is None:
        return "no reply (id=%d seq=%d len=%d)" % (id_, seq, n)
    return check_reply(f, id_, seq, n)


def silent(frame, id_, seq):
    """Send a malformed frame; True if xv6 produced NO echo reply for it."""
    drain()
    sock.send(frame)
    return sniff(is_reply(id_, seq), QUIET_S) is None


def alive(tag):
    r = probe(0x7777, tag)
    return r


# ----------------------------------------------------------------------------- tests
TESTS = []


def test(fn):
    TESTS.append(fn)
    return fn


@test
def echo_basic_56():
    return probe(1, 1, 56)


@test
def echo_all_sizes():
    for i, n in enumerate([0, 1, 2, 17, 56, 100, 512, 1000, 1472]):
        r = probe(2, i, n)
        if r:
            return "size %d: %s" % (n, r)


@test
def echo_ttl1_accepted():
    return probe(3, 1, 20, ttl=1)


@test
def echo_id_seq_extremes():
    for i, (a, b) in enumerate([(0, 0), (0xFFFF, 0xFFFF), (0x00FF, 0xFF00), (0x8000, 1)]):
        r = probe(a, b, 20)
        if r:
            return "id=%#x seq=%#x: %s" % (a, b, r)


@test
def echo_trailing_padding_ignored():
    return probe(4, 1, 10, trailer=b"\xEE" * 30)


@test
def ip_options_stripped_in_reply():
    return probe(5, 1, 16, opts=b"\x01\x01\x01\x00")      # IHL 6: NOP NOP NOP EOL


@test
def drop_bad_icmp_checksum():
    if not silent(echo_frame(10, 1, 56, bad_icmp_sum=True), 10, 1):
        return "xv6 answered a request with a bad ICMP checksum"
    return alive(1)


@test
def drop_bad_ip_checksum():
    if not silent(echo_frame(11, 1, 56, bad_ip_sum=True), 11, 1):
        return "xv6 answered a request with a bad IP header checksum"
    return alive(2)


@test
def drop_ttl0():
    if not silent(echo_frame(12, 1, 56, ttl=0), 12, 1):
        return "xv6 answered a request with ttl 0"
    return alive(3)


@test
def drop_fragments():
    for k, off in enumerate([0x2000, 0x0008, 0x2008]):     # MF, offset!=0, both
        if not silent(echo_frame(13, k, 56, off=off), 13, k):
            return "xv6 answered a fragment (off=%#06x)" % off
    return alive(4)


@test
def drop_wrong_destination_ip():
    if not silent(echo_frame(14, 1, 56, dst="192.168.100.99"), 14, 1):
        return "xv6 answered a packet addressed to another IP"
    return alive(5)


@test
def drop_broadcast_destination():
    f = echo_frame(15, 1, 56, dst="192.168.100.255", eth_dst=b"\xff" * 6)
    if not silent(f, 15, 1):
        return "xv6 answered an echo request to the subnet broadcast address"
    return alive(6)


@test
def drop_total_length_exceeds_frame():
    if not silent(echo_frame(16, 1, 56, total=200), 16, 1):
        return "xv6 answered a packet whose IP total length exceeds the frame"
    return alive(7)


@test
def drop_bad_version_and_ihl():
    for k, vhl in enumerate([0x65, 0x44, 0x40]):           # v6, IHL 4, IHL 0
        if not silent(echo_frame(17, k, 56, vhl=vhl), 17, k):
            return "xv6 answered vhl=0x%02x" % vhl
    return alive(8)


@test
def drop_unsupported_icmp():
    cases = [(3, 0), (13, 0), (8, 1), (11, 0), (255, 0)]    # unreach, timestamp, echo code 1, ...
    for k, (t, c) in enumerate(cases):
        if not silent(echo_frame(18, k, 8, icmp_type=t, icmp_code=c), 18, k):
            return "xv6 answered ICMP type %d code %d" % (t, c)
    return alive(9)


@test
def burst_then_alive():
    drain()
    n = 100
    for s in range(n):
        sock.send(echo_frame(19, s, 56))
    got = set()
    end = time.time() + 3.0
    while time.time() < end and len(got) < n:
        f = sniff(lambda fr: fr[12:14] == b"\x08\x00" and fr[14 + 9] == 1 and fr[34] == 0, 0.3)
        if f is not None:
            got.add(struct.unpack("!H", f[40:42])[0])
    print("INFO burst: %d/%d replies (loss %d%%)" % (len(got), n, 100 - 100 * len(got) // n))
    if not got:
        return "no reply at all to a 100-request burst"
    time.sleep(0.5)
    return alive(10)


@test
def host_ping_default_and_sizes():
    ping = shutil.which("ping")
    if not ping:
        print("SKIP host_ping_default_and_sizes: no ping binary")
        return None
    for args in (["-c", "3"], ["-c", "2", "-s", "0"], ["-c", "2", "-s", "1472", "-M", "do"]):
        p = subprocess.run([ping, "-W", "2", "-i", "0.3"] + args + [cfg.xv6_ip],
                           capture_output=True, text=True)
        if p.returncode != 0:
            return "ping %s failed:\n%s" % (" ".join(args), p.stdout[-400:])
    return None


@test
def host_ping_flood_then_alive():
    ping = shutil.which("ping")
    if not ping:
        print("SKIP host_ping_flood_then_alive: no ping binary")
        return None
    p = subprocess.run([ping, "-f", "-c", "500", "-W", "1", cfg.xv6_ip],
                       capture_output=True, text=True)
    tail = [ln for ln in p.stdout.splitlines() if "packet loss" in ln]
    print("INFO flood: %s" % (tail[0].strip() if tail else "n/a"))
    time.sleep(1.0)
    return alive(11)


# ----------------------------------------------------------------------------- main
def arp_resolve():
    global xv6_mac
    req = struct.pack("!HHBBH6s4s6s4s", 1, 0x0800, 6, 4, 1, host_mac, ip2b(cfg.host_ip),
                      b"\0" * 6, ip2b(cfg.xv6_ip))
    for _ in range(5):
        drain()
        sock.send(eth(b"\xff" * 6, host_mac, 0x0806, req))
        end = time.time() + 1.0
        while time.time() < end:
            if not select.select([sock], [], [], max(0, end - time.time()))[0]:
                break
            f = sock.recv(4096)
            if len(f) >= 42 and f[12:14] == b"\x08\x06" and f[20:22] == b"\x00\x02" \
                    and f[28:32] == ip2b(cfg.xv6_ip):
                xv6_mac = f[22:28]
                return True
    return False


def dump_frames():
    """Offline: print 'name verdict hex' for the frame builders (verdict = what xv6 must do)."""
    global host_mac, xv6_mac
    host_mac, xv6_mac = b"\xaa" * 6, b"\x52\x54\x00\x12\x34\x56"
    c = [
        ("good56", "ok", echo_frame(1, 1, 56)),
        ("good0", "ok", echo_frame(1, 1, 0)),
        ("good1472", "ok", echo_frame(1, 1, 1472)),
        ("ttl1", "ok", echo_frame(1, 1, 20, ttl=1)),
        ("opts", "ok", echo_frame(1, 1, 16, opts=b"\x01\x01\x01\x00")),
        ("trailer", "ok", echo_frame(1, 1, 10, trailer=b"\xEE" * 30)),
        ("badicmp", "drop", echo_frame(1, 1, 56, bad_icmp_sum=True)),
        ("badip", "drop", echo_frame(1, 1, 56, bad_ip_sum=True)),
        ("ttl0", "drop", echo_frame(1, 1, 56, ttl=0)),
        ("mf", "drop", echo_frame(1, 1, 56, off=0x2000)),
        ("fragoff", "drop", echo_frame(1, 1, 56, off=0x0008)),
        ("wrongdst", "drop", echo_frame(1, 1, 56, dst="192.168.100.99")),
        ("bcast", "drop", echo_frame(1, 1, 56, dst="192.168.100.255")),
        ("longtotal", "drop", echo_frame(1, 1, 56, total=200)),
        ("v6", "drop", echo_frame(1, 1, 56, vhl=0x65)),
        ("ihl4", "drop", echo_frame(1, 1, 56, vhl=0x44)),
        ("type3", "drop", echo_frame(1, 1, 8, icmp_type=3)),
        ("code1", "drop", echo_frame(1, 1, 8, icmp_code=1)),
    ]
    for name, v, f in c:
        print(name, v, f.hex())


def main():
    global sock, host_mac
    ap = argparse.ArgumentParser()
    ap.add_argument("--iface", default=os.environ.get("TAP_IF", "tap0"))
    ap.add_argument("--host-ip", default="192.168.100.1")
    ap.add_argument("--xv6-ip", default="192.168.100.2")
    ap.add_argument("--dump-frames", action="store_true")
    ap.parse_args(namespace=cfg)
    if cfg.dump_frames:
        dump_frames()
        return 0
    if os.geteuid() != 0:
        print("tap_icmp_errors.py needs root (AF_PACKET). Re-run with sudo.", file=sys.stderr)
        return 2
    try:
        sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
        sock.bind((cfg.iface, 0))
        with open("/sys/class/net/%s/address" % cfg.iface) as fh:
            host_mac = bytes(int(x, 16) for x in fh.read().strip().split(":"))
    except OSError as e:
        print("cannot use interface %s: %s" % (cfg.iface, e), file=sys.stderr)
        return 2
    if not arp_resolve():
        print("FAIL arp_resolve: no ARP reply from %s on %s (is xv6 running in TAP mode with "
              "that IP?)" % (cfg.xv6_ip, cfg.iface))
        return 1
    print("PASS arp_resolve (xv6 MAC %s)" % ":".join("%02x" % b for b in xv6_mac))
    fails = 0
    for t in TESTS:
        try:
            r = t()
        except Exception as e:           # a test bug must not hide the other results
            r = "exception: %r" % (e,)
        if r:
            print("FAIL %s: %s" % (t.__name__, r))
            fails += 1
        else:
            print("PASS %s" % t.__name__)
    print("\n%d/%d passed" % (len(TESTS) + 1 - fails, len(TESTS) + 1))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
