# TAP Setup and E1000 Testing (xv6)

## 1. Requirements
- Ubuntu/Linux
- QEMU >= 7.2
- RISC-V toolchain
- OS_E1000_Driver repository

## 2. Create TAP interface

Create TAP on each member's own Linux machine:

    sudo ip tuntap add dev tap0 mode tap user "$USER"
    sudo ip link set tap0 up

If tap0 already exists:

    sudo ip link set tap0 up
    ip -brief link show tap0

## 3. Run xv6 with TAP

From the repository:

    cd ~/OS_E1000_Driver
    make qemu CPUS=4 QEMU=$HOME/qemu-7.2/bin/qemu-system-riscv64

The QEMU configuration connects tap0 to the E1000 device.

## 4. Capture packets

QEMU captures packets into packets.pcap.

Read all captured packets:

    tcpdump -nn -e -r packets.pcap

Filter test EtherType 0x88b5:

    tcpdump -nn -e -r packets.pcap 'ether proto 0x88b5'

## 5. Host-to-xv6 test

Run the host sender script if available:

    cd ~/OS_E1000_Driver
    sudo python3 send_rx.py

Inside xv6, use the project's RX polling/test program to check
whether incoming frames are actually received.

## Notes
- Each member creates TAP on their own Linux machine.
- TAP is not shared automatically between computers.
- QEMU must be stopped before starting another QEMU using tap0.
- PCAP capture alone does not prove xv6 processed incoming frames.
