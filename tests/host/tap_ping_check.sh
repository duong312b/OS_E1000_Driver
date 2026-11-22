#!/usr/bin/env bash
# Role B end-to-end check over TAP: host <-> xv6 ping, malformed-packet tests, pcap audit.
#
#   1. start xv6 in TAP mode in another terminal (see docs/TAP_PING_TEST.md)
#   2. bash tests/host/tap_ping_check.sh
#
# Environment overrides: TAP_IF (tap0) HOST_IP (192.168.100.1) XV6_IP (192.168.100.2)
#                        XV6_MAC (52:54:00:12:34:56) PCAP (<repo>/packets.pcap) FLOOD=1 (adds ping -f)
# Exit status: 0 = everything passed, 1 = a check failed, 2 = environment not ready.
set -u
IFACE=${TAP_IF:-tap0}
HOST_IP=${HOST_IP:-192.168.100.1}
XV6_IP=${XV6_IP:-192.168.100.2}
XV6_MAC=${XV6_MAC:-52:54:00:12:34:56}
HERE=$(cd "$(dirname "$0")" && pwd)
# `make qemu` writes packets.pcap into the repo root (filter-dump in the root Makefile).
PCAP=${PCAP:-$HERE/../../packets.pcap}
failed=0

say()  { printf '\n== %s\n' "$1"; }
pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; failed=1; }

say "preflight"
for tool in ip ping python3; do
  command -v "$tool" >/dev/null 2>&1 || { echo "missing tool: $tool" >&2; exit 2; }
done
if ! ip -4 addr show dev "$IFACE" 2>/dev/null | grep -q "inet $HOST_IP/"; then
  echo "$IFACE has no address $HOST_IP/24. Fix with:" >&2
  echo "  sudo ip addr add $HOST_IP/24 dev $IFACE && sudo ip link set $IFACE up" >&2
  exit 2
fi
pass "$IFACE has $HOST_IP"
if ! ping -c 1 -W 2 "$XV6_IP" >/dev/null 2>&1; then
  echo "no reply from $XV6_IP. Check, in this order:" >&2
  echo "  - xv6 was started with: make qemu NET=tap   (this adds -DNET_TAP and rebuilds the kernel)" >&2
  echo "  - xv6 console shows MAC $XV6_MAC and boot did not panic" >&2
  echo "  - firewall: sudo iptables -L -n | grep -i drop   (host must accept ICMP on $IFACE)" >&2
  exit 2
fi
pass "xv6 answers ping at $XV6_IP"

say "host ping: sizes and MTU boundary"
for args in "-c 3" "-c 2 -s 0" "-c 2 -s 1472 -M do"; do
  # shellcheck disable=SC2086
  if ping -W 2 -i 0.3 $args "$XV6_IP" >/dev/null 2>&1; then pass "ping $args"; else fail "ping $args"; fi
done
# 1473 data bytes + 28 header bytes = 1501 > MTU 1500: the host must refuse locally with DF set.
if ping -c 1 -W 2 -s 1473 -M do "$XV6_IP" >/dev/null 2>&1; then
  fail "ping -s 1473 -M do should be refused by the host (MTU 1500)"
else
  pass "ping -s 1473 -M do refused (MTU respected)"
fi
if [ "${FLOOD:-0}" = 1 ]; then
  if ping -f -c 500 -W 1 "$XV6_IP" >/dev/null 2>&1; then pass "ping -f 500"; else
    echo "INFO ping -f lost packets (allowed); liveness is checked below"; fi
  sleep 1
  if ping -c 1 -W 2 "$XV6_IP" >/dev/null 2>&1; then pass "alive after flood"; else fail "dead after flood"; fi
fi

say "malformed / boundary packets (tap_icmp_errors.py)"
if sudo python3 "$HERE/tap_icmp_errors.py" --iface "$IFACE" --host-ip "$HOST_IP" --xv6-ip "$XV6_IP"; then
  pass "tap_icmp_errors"
else
  fail "tap_icmp_errors"
fi

say "capture audit ($PCAP)"
if [ -r "$PCAP" ]; then
  if python3 "$HERE/pcap_icmp_check.py" "$PCAP" --xv6-mac "$XV6_MAC" --xv6-ip "$XV6_IP"; then
    pass "pcap_icmp_check"
  else
    fail "pcap_icmp_check"
  fi
else
  echo "SKIP: $PCAP not found (QEMU writes it where `make qemu` was started; or set PCAP=...)"
fi

echo
if [ "$failed" = 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit "$failed"
