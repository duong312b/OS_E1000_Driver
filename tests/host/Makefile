CC ?= gcc
CFLAGS = -Wall -Wextra -Werror -O1 -I../../kernel -I.
TESTS = test_net_headers week2_eth_arp_test

test: $(TESTS)
	@for t in $(TESTS); do echo "== $$t =="; ./$$t || exit 1; done

vectors.h: gen_vectors.py
	python3 gen_vectors.py > /dev/null

test_net_headers: test_net_headers.c ../../kernel/net.c ../../kernel/net.h vectors.h
	$(CC) $(CFLAGS) -o $@ test_net_headers.c ../../kernel/net.c

week2_eth_arp_test: week2_eth_arp_test.c ../../kernel/net.c ../../kernel/net.h vectors.h
	$(CC) $(CFLAGS) -o $@ week2_eth_arp_test.c ../../kernel/net.c

clean:
	rm -f $(TESTS)
.PHONY: test clean
