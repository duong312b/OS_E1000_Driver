import struct

ETH_ARP, ETH_IP = 0x0806, 0x0800    # ma dinh danh


def read_pcap(path):
    try:
        with open(path, "rb") as f:
            data = f.read()
    except FileNotFoundError:
        return []
    if len(data) < 24:
        return []
    magic = struct.unpack("<I", data[:4])[0]    # doc 4 byte dau tien cua file pcap va giai ma
    if magic == 0xA1B2C3D4:     
        end = "<"   # kieu little-endian
    elif magic == 0xD4C3B2A1:
        end = ">"   # kieu big-endian
    else:
        raise ValueError("không phải file pcap (magic=%#x)" % magic)
    # doc tung goi tin trong pcap
    frames, off = [], 24
    while off + 16 <= len(data):
        _, _, incl, _ = struct.unpack(end + "IIII", data[off:off + 16])
        off += 16
        if off + incl > len(data):
            break
        frames.append(data[off:off + incl])
        off += incl
    return frames

# trich xuat 2 file ether type
def ethertype(fr):
    return struct.unpack("!H", fr[12:14])[0] if len(fr) >= 14 else None

# convert 6 byte -> dia chi MAC
def mac(b):
    return ":".join("%02x" % x for x in b)

# phan tich goi udp
def parse_udp(fr):
    # kiem tra dieu kien
    if len(fr) < 14 + 20 + 8 or ethertype(fr) != ETH_IP or fr[14 + 9] != 17:
        return None
    # doc cac thong tin
    ihl = (fr[14] & 0x0F) * 4
    src = ".".join(str(x) for x in fr[26:30])
    dst = ".".join(str(x) for x in fr[30:34])
    sport, dport, ulen, _ = struct.unpack("!HHHH", fr[14 + ihl:14 + ihl + 8])
    return src, dst, sport, dport, fr[14 + ihl + 8:14 + ihl + ulen]
    # tra ve: ip nguon, ip dich, port nguon, port dich, payload(du lieu)

# phan tich goi ARP
def parse_arp(fr):
    # kiem tra dieu kien
    if len(fr) < 14 + 28 or ethertype(fr) != ETH_ARP:
        return None
    # doc opcode -> xac dinh loai hoat dong cua ARP (1-request, 2-reply)
    op = struct.unpack("!H", fr[20:22])[0]
    # convert 4 byte -> dia chi ipv4
    ip = lambda b: ".".join(str(x) for x in b)
    return op, mac(fr[22:28]), ip(fr[28:32]), mac(fr[32:38]), ip(fr[38:42])
    # 22:28: sender MAC address
    # 28:32: sender IP addr
    # 32:38: target MAC addr
    # 38:42: target IP addr

# doc pcap moi interval (s) cho den khi het timeout (s)
def wait_for(path, pred, timeout=5.0, interval=0.2):
    import time
    deadline = time.time() + timeout
    while time.time() < deadline:
        for fr in read_pcap(path):
            if pred(fr):
                return fr
        time.sleep(interval)
    return None