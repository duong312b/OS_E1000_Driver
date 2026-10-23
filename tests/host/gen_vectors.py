#!/usr/bin/env python3
"""Sinh khung mau bang cai dat checksum DOC LAP (Python) de doi chieu voi net.c."""
import os
import struct

def cksum(data: bytes) -> int:
    if len(data) % 2: data += b"\0"
    s = sum(struct.unpack("!%dH" % (len(data)//2), data))
    while s >> 16: s = (s & 0xffff) + (s >> 16)
    return ~s & 0xffff

def mac(s): return bytes(int(x, 16) for x in s.split(":"))
def ip(s):  return bytes(int(x) for x in s.split("."))

def ping_frame(payload=b"abcdefgh"):
    icmp = struct.pack("!BBHHH", 8, 0, 0, 0x0001, 0x0001) + payload
    icmp = icmp[:2] + struct.pack("!H", cksum(icmp)) + icmp[4:]
    iph = struct.pack("!BBHHHBBH4s4s", 0x45, 0, 20 + len(icmp), 0x1234, 0x4000, 64, 1, 0,
                      ip("10.0.2.15"), ip("10.0.2.2"))
    iph = iph[:10] + struct.pack("!H", cksum(iph)) + iph[12:]
    eth = mac("52:55:0a:00:02:02") + mac("52:54:00:12:34:56") + struct.pack("!H", 0x0800)
    return eth + iph + icmp

def arp_request():
    eth = mac("ff:ff:ff:ff:ff:ff") + mac("52:54:00:12:34:56") + struct.pack("!H", 0x0806)
    arp = struct.pack("!HHBBH6s4s6s4s", 1, 0x0800, 6, 4, 1, mac("52:54:00:12:34:56"),
                      ip("10.0.2.15"), b"\0"*6, ip("10.0.2.2"))
    return eth + arp

def c_array(name, b):
    body = ", ".join("0x%02x" % x for x in b)
    return "static const unsigned char %s[%d] = {\n  %s\n};\n" % (name, len(b), body)

if __name__ == "__main__":
    out = "// SINH TU DONG boi gen_vectors.py - khong sua tay.\n"
    out += c_array("PING_FRAME", ping_frame())
    out += c_array("ARP_REQ_FRAME", arp_request())
    open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "vectors.h"), "w").write(out)
    print(out)
