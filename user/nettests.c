// nettests.c – khung test mạng chạy trong xv6. Mỗi test tự kiểm tra, in PASS/FAIL.
// Thêm test mới: viết hàm `static int test_xxx(void)` (trả 0 = ok), rồi thêm vào bảng `tests[]`.
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static int npass, nfail;

// CHECK: kiểm tra điều kiện; sai thì in lý do và thoát test hiện tại.
#define CHECK(cond) do { if (!(cond)) { \
    printf("  check failed: %s (dòng %d)\n", #cond, __LINE__); return -1; } } while (0)

struct test { const char *name; int (*fn)(void); };

// ---- Các test (tuần 1 chỉ có khung; test thật thêm từ tuần 2) --------
static int test_harness_sanity(void) { CHECK(1 + 1 == 2); return 0; }

static int test_fork_wait(void) {      // chạy được tiến trình con (nền cho test đồng thời)
  int pid = fork();
  CHECK(pid >= 0);
  if (pid == 0) exit(7);
  int st = -1;
  CHECK(wait(&st) == pid);
  CHECK(st == 7);
  return 0;
}

// TODO(tuần 2+): socket/bind/sendto/recvfrom, bind trùng cổng, fd sai, close giải phóng cổng,
//                udp echo, leak check (số trang trống trước/sau).

static struct test tests[] = {
  { "harness_sanity", test_harness_sanity },
  { "fork_wait",      test_fork_wait },
};

int
main(void)
{
  int n = sizeof(tests) / sizeof(tests[0]);
  for (int i = 0; i < n; i++) {
    if (tests[i].fn() == 0) { printf("PASS: %s\n", tests[i].name); npass++; }
    else                    { printf("FAIL: %s\n", tests[i].name); nfail++; }
  }
  printf("NETTESTS: %d passed, %d failed\n", npass, nfail);
  printf("NETTESTS DONE\n");
  exit(nfail ? 1 : 0);
}