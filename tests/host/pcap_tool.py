import struct

ETH_ARP, ETH_IP = 0x0806, 0x0800


def read_pcap(path):
    try:
        with open(path, "rb") as f:
            data = f.read()
    except FileNotFoundError:
        return []
    if len(data) < 24:
        return []
    magic = struct.unpack("<I", data[:4])[0]
    if magic == 0xA1B2C3D4:
        end = "<"
    elif magic == 0xD4C3B2A1:
        end = ">"
    else:
        raise ValueError("không phải file pcap (magic=%#x)" % magic)
    frames, off = [], 24
    while off + 16 <= len(data):
        _, _, incl, _ = struct.unpack(end + "IIII", data[off:off + 16])
        off += 16
        if off + incl > len(data):
            break
        frames.append(data[off:off + incl])
        off += incl
    return frames


def ethertype(fr):
    return struct.unpack("!H", fr[12:14])[0] if len(fr) >= 14 else None


def mac(b):
    return ":".join("%02x" % x for x in b)


def parse_udp(fr):
    if len(fr) < 14 + 20 + 8 or ethertype(fr) != ETH_IP or fr[14 + 9] != 17:
        return None
    ihl = (fr[14] & 0x0F) * 4
    src = ".".join(str(x) for x in fr[26:30])
    dst = ".".join(str(x) for x in fr[30:34])
    sport, dport, ulen, _ = struct.unpack("!HHHH", fr[14 + ihl:14 + ihl + 8])
    return src, dst, sport, dport, fr[14 + ihl + 8:14 + ihl + ulen]


def parse_arp(fr):
    if len(fr) < 14 + 28 or ethertype(fr) != ETH_ARP:
        return None
    op = struct.unpack("!H", fr[20:22])[0]
    ip = lambda b: ".".join(str(x) for x in b)
    return op, mac(fr[22:28]), ip(fr[28:32]), mac(fr[32:38]), ip(fr[38:42])


def wait_for(path, pred, timeout=5.0, interval=0.2):
    import time
    deadline = time.time() + timeout
    while time.time() < deadline:
        for fr in read_pcap(path):
            if pred(fr):
                return fr
        time.sleep(interval)
    return None