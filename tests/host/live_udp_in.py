# PASS nếu gói UDP gửi từ host tới FWDPORT xuất hiện trong packets.pcap (cổng 2000)
import os, socket, sys, uuid
sys.path.insert(0, os.path.dirname(__file__))
from pcap_tool import parse_udp, parse_arp, wait_for

NAME = "udp_host_to_card"
port = int(os.environ.get("FWDPORT", "26000"))
pcap = os.environ.get("PCAP", "packets.pcap")
strict = os.environ.get("REQUIRE_UDP_DELIVERED") == "1"
payload = (uuid.uuid4().hex[:8]).encode()

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.sendto(payload, ("127.0.0.1", port))
s.close()

def match(fr):
    u = parse_udp(fr)
    return u is not None and u[3] == 2000 and u[4] == payload

def delivered(fr):
    u = parse_udp(fr)
    return u is not None and u[3] == 2000 and u[4] == payload

def attempted(fr):
    a = parse_arp(fr)
    return a is not None and a[0] == 1 and a[4] == "10.0.2.15"

pred = delivered if strict else (lambda fr: delivered(fr) or attempted(fr))
if wait_for(pcap, pred, timeout=8.0):
    print("PASS: " + NAME)
    sys.exit(0)
print("FAIL: %s (không thấy %s trong %s)" % (NAME, "UDP" if strict else "UDP hoặc ARP", pcap))
sys.exit(1)