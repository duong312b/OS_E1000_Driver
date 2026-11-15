#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
    int count;

    printf("Starting E1000 RX polling...\n");
    count = e1000_poll_rx();
    printf("E1000 RX polling processed %d frame(s)\n", count);

    exit(0);
}
