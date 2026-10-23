# Chay: make -C tests/host     (can gcc + python3; dung kernel/types.h cua repo)
CC ?= gcc
CFLAGS = -Wall -Wextra -Werror -O1 -I../../kernel -I.

test: test_net_headers
	./test_net_headers

vectors.h: gen_vectors.py
	python3 gen_vectors.py > /dev/null

test_net_headers: test_net_headers.c ../../kernel/net.c ../../kernel/net.h vectors.h
	$(CC) $(CFLAGS) -o $@ test_net_headers.c ../../kernel/net.c

clean:
	rm -f test_net_headers
.PHONY: test clean
