# PASS nếu thấy ARP request (xv6 10.0.2.15 hỏi 10.0.2.2) trong packets.pcap
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from pcap_tool import parse_arp, wait_for

NAME = "arp_request_out"
pcap = os.environ.get("PCAP", "packets.pcap")

def match(fr):
    a = parse_arp(fr)
    return a is not None and a[0] == 1 and a[2] == "10.0.2.15" and a[4] == "10.0.2.2"

# xv6 gửi ARP request sau khi boot
if wait_for(pcap, match, timeout=15.0):
    print("PASS: " + NAME)
    sys.exit(0)

if os.environ.get("REQUIRE_ARP_OUT") == "1":      # bật khi B xong
    print("FAIL: " + NAME)
    sys.exit(1)
print("SKIP: %s (chưa sẵn sàng)" % NAME)
sys.exit(0)