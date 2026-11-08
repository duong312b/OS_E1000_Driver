# PASS nếu thấy ARP request (xv6 10.0.2.15 hỏi 10.0.2.2) trong packets.pcap
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from pcap_tool import parse_arp, wait_for

# NAME = "arp_request_out"
pcap = os.environ.get("PCAP", "packets.pcap")
require = os.environ.get("REQUIRE_ARP_OUT", "1") == "1"
bad = 0

# def match(fr):
#     a = parse_arp(fr)
#     return a is not None and a[0] == 1 and a[2] == "10.0.2.15" and a[4] == "10.0.2.2"

# # xv6 gửi ARP request sau khi boot
# if wait_for(pcap, match, timeout=15.0):
#     print("PASS: " + NAME)
#     sys.exit(0)

# if os.environ.get("REQUIRE_ARP_OUT") == "1":      # bật khi B xong
#     print("FAIL: " + NAME)
#     sys.exit(1)
# print("SKIP: %s (chưa sẵn sàng)" % NAME)
# sys.exit(0)

def req(fr):    # request 10.0.2.15 hoi 10.0.2.2
    a = parse_arp(fr)
    return a is not None and a[0] == 1 and a[2] == "10.0.2.15" and a[4] == "10.0.2.2"

def rep(fr):    # reply: 10.0.2.2 tra loi 10.0.2.15
    a = parse_arp(fr)
    return a is not None and a[0] == 2 and a[2] == "10.0.2.2" and a[4] == "10.0.2.15"

for name, pred in (("arp_request_out", req), ("arp_reply_from_gateway", rep)):
    if wait_for(pcap, pred, timeout=15.0):
        print("PASS: " + name)
    elif require:
        print("FAIL: " + name)
        bad += 1
    else:
        print("SKIP: " + name)
sys.exit(1 if bad else 0)