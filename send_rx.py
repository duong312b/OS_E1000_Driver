import socket
import time

# MAC của card E1000 trong QEMU
dst = bytes.fromhex("52 54 00 12 34 56")

# MAC nguồn giả lập của máy Ubuntu
src = bytes.fromhex("02 00 00 00 00 01")

# EtherType thử nghiệm
ethertype = bytes.fromhex("88 b5")

payload = b"HOST-TO-XV6-RX-TEST"
frame = dst + src + ethertype + payload

# Ethernet frame tối thiểu 60 byte, không tính FCS
frame += b"\x00" * max(0, 60 - len(frame))

sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW)
sock.bind(("tap0", 0))

print("Dang gui Ethernet frame vao tap0...")
print("Destination MAC: 52:54:00:12:34:56")
print("EtherType: 0x88b5")

end_time = time.time() + 30
count = 0

while time.time() < end_time:
    sock.send(frame)
    count += 1
    time.sleep(0.2)

print("Da gui", count, "frame")
sock.close()
