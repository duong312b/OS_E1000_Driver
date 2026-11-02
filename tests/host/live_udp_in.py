# PASS nếu gói UDP gửi từ host tới FWDPORT xuất hiện trong packets.pcap (cổng 2000)
import os, socket, sys, uuid
sys.path.insert(0, os.path.dirname(__file__))
from pcap_tool import parse_udp, wait_for

NAME = "udp_host_to_card"
port = int(os.environ.get("FWDPORT", "26000"))
pcap = os.environ.get("PCAP", "packets.pcap")
payload = (uuid.uuid4().hex[:8]).encode()

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.sendto(payload, ("127.0.0.1", port))
s.close()

def match(fr):
    u = parse_udp(fr)
    return u is not None and u[3] == 2000 and u[4] == payload

if wait_for(pcap, match, timeout=5.0):
    print("PASS: " + NAME)
    sys.exit(0)
print("FAIL: %s (không thấy %r trong %s)" % (NAME, payload, pcap))
sys.exit(1)