CC ?= gcc
CFLAGS = -Wall -Wextra -Werror -O1 -I../../kernel -I.
TESTS = test_net_headers week3_arp_test week4_ip_test

test: $(TESTS)
	@for t in $(TESTS); do echo "== $$t =="; ./$$t || exit 1; done

vectors.h: gen_vectors.py
	python3 gen_vectors.py > /dev/null

test_net_headers: test_net_headers.c ../../kernel/net.c ../../kernel/net.h vectors.h
	$(CC) $(CFLAGS) -o $@ test_net_headers.c ../../kernel/net.c

week3_arp_test: week3_arp_test.c ../../kernel/net.c ../../kernel/week3_arp.c ../../kernel/net.h vectors.h
	$(CC) $(CFLAGS) -o $@ week3_arp_test.c ../../kernel/net.c ../../kernel/week3_arp.c

week4_ip_test: week4_ip_test.c ../../kernel/net.c ../../kernel/week4_ip.c ../../kernel/net.h ../../kernel/week4_ip.h vectors.h
	$(CC) $(CFLAGS) -o $@ week4_ip_test.c ../../kernel/net.c ../../kernel/week4_ip.c

# --- week 5 (role B) additions: nothing above this line was changed ---------------------------
# Same unit tests under AddressSanitizer + UBSan (catches out-of-bounds reads in the parsers).
week4_ip_asan: week4_ip_test.c ../../kernel/net.c ../../kernel/week4_ip.c ../../kernel/net.h ../../kernel/week4_ip.h
	$(CC) $(CFLAGS) -g -fsanitize=address,undefined -fno-sanitize-recover=all -o $@ week4_ip_test.c ../../kernel/net.c ../../kernel/week4_ip.c
	./$@

# Live ICMP/IPv4 tests against xv6 on tap0 (needs root, xv6 already running with NET=tap).
tap-icmp:
	sudo python3 tap_icmp_errors.py $(LIVE_ARGS)

# One command: host ping + malformed-packet tests + capture audit (xv6 running with NET=tap).
tap-check:
	bash tap_ping_check.sh

# Audit a capture (default: the packets.pcap QEMU writes in the repo root): make pcap-check [PCAP=file]
PCAP ?= ../../packets.pcap
pcap-check:
	python3 pcap_icmp_check.py $(PCAP)

clean:
	rm -f $(TESTS) week4_ip_asan
.PHONY: test clean week4_ip_asan tap-icmp tap-check pcap-check
