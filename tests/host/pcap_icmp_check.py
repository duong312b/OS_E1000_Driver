#!/usr/bin/env python3
"""Check the IPv4 / ICMP / ARP traffic in a QEMU filter-dump capture (week 5, role B).

    python3 tests/host/pcap_icmp_check.py packets.pcap [--xv6-mac 52:54:00:12:34:56]
                                          [--xv6-ip 192.168.100.2]

It answers "is what xv6 put on the wire correct?" without tcpdump/Wireshark:
  * every IPv4 frame xv6 sent has a valid header (version, IHL, length, checksum, no runt);
  * every ICMP message xv6 sent has a valid checksum;
  * every echo REPLY xv6 sent matches a valid echo REQUEST seen in the capture (same id/seq/
    payload, IP addresses and MACs swapped);
  * xv6 never answered a request it should have dropped (bad checksum, ttl 0, fragment, wrong
    destination, bad IHL/version, unsupported ICMP type...);
  * ARP replies from xv6 are well formed.

A capture alone does not prove xv6 PROCESSED anything (see TAP_SETUP.md), but a wrong frame on
the wire proves a bug, and this check also proves silence on malformed input.
Exit status: 0 = all checks passed, 1 = at least one FAIL, 2 = usage / unreadable capture.
"""
import argparse
import socket
import struct
import sys

MAX_SHOWN = 3


def cksum_ok(b):
    """True if the RFC 1071 sum over b (checksum field included) verifies."""
    if len(b) & 1:
        b += b"\0"
    s = sum(struct.unpack("!%dH" % (len(b) // 2), b))
    while s >> 16:
        s = (s & 0xFFFF) + (s >> 16)
    return s == 0xFFFF


def read_pcap(path):
    """Classic libpcap (what QEMU filter-dump writes). Returns list of (index, frame, truncated)."""
    with open(path, "rb") as fh:
        d = fh.read()
    if len(d) < 24:
        raise ValueError("file too short for a pcap header")
    ends = {b"\xd4\xc3\xb2\xa1": "<", b"\xa1\xb2\xc3\xd4": ">",
            b"\x4d\x3c\xb2\xa1": "<", b"\xa1\xb2\x3c\x4d": ">"}
    end = ends.get(d[:4])
    if end is None:
        raise ValueError("not a classic pcap file (pcapng is not supported)")
    linktype = struct.unpack(end + "I", d[20:24])[0]
    if linktype != 1:
        raise ValueError("link type %d is not Ethernet" % linktype)
    out, off, i = [], 24, 0
    while off + 16 <= len(d):
        _s, _f, incl, orig = struct.unpack(end + "IIII", d[off: off + 16])
        off += 16
        if off + incl > len(d):
            break                         # partial last record (QEMU still running / killed)
        out.append((i, d[off: off + incl], incl < orig))
        off += incl
        i += 1
    return out


def ip_problem(f, xv6_ip):
    """Why xv6 must NOT answer this frame (None = it is a valid echo request for xv6).
    Mirrors week4_ip_parse + week4_icmp_parse; kept independent on purpose."""
    if len(f) < 34:
        return "shorter than Ethernet+IP"
    if f[12:14] != b"\x08\x00":
        return "not IPv4"
    vhl = f[14]
    if vhl >> 4 != 4:
        return "version %d" % (vhl >> 4)
    hl = (vhl & 15) * 4
    if hl < 20:
        return "IHL %d" % (vhl & 15)
    total = struct.unpack("!H", f[16:18])[0]
    if total < hl or total > len(f) - 14:
        return "IP total length %d inconsistent with frame (%d)" % (total, len(f))
    if not cksum_ok(f[14: 14 + hl]):
        return "bad IP header checksum"
    if struct.unpack("!H", f[20:22])[0] & 0x3FFF:
        return "fragment"
    src, dst = f[26:30], f[30:34]
    if dst != socket.inet_aton(xv6_ip):
        return "destination is not xv6"
    if src in (b"\0\0\0\0", b"\xff\xff\xff\xff") or (src[0] >> 4) == 0xE:
        return "bad source address"
    if f[22] == 0:
        return "ttl 0"
    if f[23] != 1:
        return "not ICMP"
    icmp = f[14 + hl: 14 + total]
    if len(icmp) < 8:
        return "ICMP shorter than 8 bytes"
    if not cksum_ok(icmp):
        return "bad ICMP checksum"
    if icmp[1] != 0 or icmp[0] != 8:
        return "ICMP type %d code %d unsupported" % (icmp[0], icmp[1])
    return None


def lenient_echo(f):
    """(id, seq, payload) of an ICMP echo-like frame even if it is malformed, else None."""
    if len(f) < 14 + 20 + 8 or f[12:14] != b"\x08\x00" or f[23] != 1:
        return None
    hl = max(20, (f[14] & 15) * 4)
    if len(f) < 14 + hl + 8:
        return None
    i, s = struct.unpack("!HH", f[14 + hl + 4: 14 + hl + 8])
    total = struct.unpack("!H", f[16:18])[0]
    end = 14 + total if hl <= total <= len(f) - 14 else len(f)
    return i, s, f[14 + hl + 8: end]


class Report:
    def __init__(self):
        self.names, self.fails = [], {}

    def declare(self, name):
        self.names.append(name)

    def fail(self, name, idx, why):
        self.fails.setdefault(name, []).append("frame #%d: %s" % (idx, why))

    def print(self):
        bad = 0
        for n in self.names:
            f = self.fails.get(n)
            if f:
                bad += 1
                shown = f[:MAX_SHOWN] + (["... and %d more" % (len(f) - MAX_SHOWN)] if len(f) > MAX_SHOWN else [])
                print("FAIL %s:\n    %s" % (n, "\n    ".join(shown)))
            else:
                print("PASS %s" % n)
        return bad


def analyse(frames, xv6_mac, xv6_ip, rep):
    for n in ("xv6_frames_present", "xv6_no_runt_or_oversize", "xv6_ip_headers_valid",
              "xv6_icmp_checksums_valid", "xv6_replies_match_requests",
              "xv6_silent_on_malformed_requests", "xv6_arp_replies_wellformed"):
        rep.declare(n)

    reqs = {}                    # (id, seq) -> list of (idx, frame, problem)
    stats = dict(from_xv6=0, req=0, req_good=0, replies=0, matched=0, arp_rep=0, ping_tx=0)

    for idx, f, trunc in frames:
        if trunc or len(f) < 14:
            continue
        if f[6:12] != xv6_mac:                              # sent by someone else
            e = lenient_echo(f)
            if e and f[14 + max(20, (f[14] & 15) * 4)] == 8:    # echo request towards xv6
                stats["req"] += 1
                p = ip_problem(f, xv6_ip)
                stats["req_good"] += p is None
                reqs.setdefault((e[0], e[1]), []).append((idx, f, p))
            continue

        stats["from_xv6"] += 1
        if len(f) < 60 or len(f) > 1514:
            rep.fail("xv6_no_runt_or_oversize", idx, "frame length %d" % len(f))
        et = f[12:14]
        if et == b"\x08\x06":                               # ARP
            if f[20:22] == b"\x00\x02":
                stats["arp_rep"] += 1
                hrd, pro, hln, pln = struct.unpack("!HHBB", f[14:20])
                if (hrd, pro, hln, pln) != (1, 0x0800, 6, 4) or f[22:28] != xv6_mac \
                        or f[28:32] != socket.inet_aton(xv6_ip) or f[0:6] != f[32:38]:
                    rep.fail("xv6_arp_replies_wellformed", idx, "malformed ARP reply")
            continue
        if et != b"\x08\x00":
            continue                                        # e.g. 0x88b5 test frames
        if len(f) < 34:
            rep.fail("xv6_ip_headers_valid", idx, "IPv4 frame shorter than 34 bytes")
            continue
        hl = (f[14] & 15) * 4
        total = struct.unpack("!H", f[16:18])[0]
        if f[14] >> 4 != 4 or hl < 20 or total < hl or total > len(f) - 14 \
                or not cksum_ok(f[14: 14 + hl]):
            rep.fail("xv6_ip_headers_valid", idx, "invalid IPv4 header (vhl=0x%02x len=%d)" % (f[14], total))
            continue
        if f[23] != 1:
            continue
        icmp = f[14 + hl: 14 + total]
        if len(icmp) < 8 or not cksum_ok(icmp):
            rep.fail("xv6_icmp_checksums_valid", idx, "bad ICMP checksum / too short")
            continue
        if icmp[0] == 8:
            stats["ping_tx"] += 1
            continue
        if icmp[0] != 0:
            continue
        stats["replies"] += 1
        i, s = struct.unpack("!HH", icmp[4:8])
        cands = reqs.get((i, s), [])
        if not cands:
            rep.fail("xv6_replies_match_requests", idx, "echo reply id=%d seq=%d without request" % (i, s))
            continue
        good = [c for c in cands if c[2] is None]
        if not good:
            rep.fail("xv6_silent_on_malformed_requests", idx,
                     "replied to id=%d seq=%d which is malformed (%s)" % (i, s, cands[-1][2]))
            continue
        ok = False
        for _ridx, rq, _p in good:
            rhl = (rq[14] & 15) * 4
            rq_icmp = rq[14 + rhl: 14 + struct.unpack("!H", rq[16:18])[0]]
            if rq_icmp[8:] == icmp[8:] and rq[26:30] == f[30:34] and rq[30:34] == f[26:30] \
                    and rq[6:12] == f[0:6]:
                ok = True
                break
        if ok:
            stats["matched"] += 1
        else:
            rep.fail("xv6_replies_match_requests", idx,
                     "reply id=%d seq=%d differs from request (payload/IPs/MAC)" % (i, s))

    if stats["from_xv6"] == 0:
        rep.fail("xv6_frames_present", -1, "no frame with source MAC %s: wrong MAC, or xv6 sent nothing"
                 % ":".join("%02x" % b for b in xv6_mac))
    return stats


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("pcap")
    ap.add_argument("--xv6-mac", default="52:54:00:12:34:56")
    ap.add_argument("--xv6-ip", default="192.168.100.2")
    a = ap.parse_args()
    try:
        frames = read_pcap(a.pcap)
        mac = bytes(int(x, 16) for x in a.xv6_mac.split(":"))
        assert len(mac) == 6
    except (OSError, ValueError, AssertionError) as e:
        print("pcap_icmp_check: %s" % e, file=sys.stderr)
        return 2
    rep = Report()
    st = analyse(frames, mac, a.xv6_ip, rep)
    bad = rep.print()
    print("INFO frames=%d from_xv6=%d | echo requests to xv6=%d (valid %d) | echo replies from xv6=%d "
          "(matched %d) | xv6-originated echo requests=%d | ARP replies=%d"
          % (len(frames), st["from_xv6"], st["req"], st["req_good"], st["replies"], st["matched"],
             st["ping_tx"], st["arp_rep"]))
    if st["req_good"] and st["replies"] < st["req_good"]:
        print("INFO %d valid request(s) have no reply in the capture (expected only under flood/burst)"
              % (st["req_good"] - st["replies"]))
    print("\n%d/%d checks passed" % (len(rep.names) - bad, len(rep.names)))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
