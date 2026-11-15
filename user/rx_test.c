#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
    printf("Starting E1000 RX test...\n");

    e1000_rx_test();

    exit(0);
}
