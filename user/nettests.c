// nettests.c – khung test mạng chạy trong xv6. Mỗi test tự kiểm tra, in PASS/FAIL.
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static int npass, nfail, nskip;

// CHECK: chi kiem tra dieu kien, khong can biet wait() tra ve gia tri nao.
// Dung khi khong can biet gia tri tra ve -> tiet kiem tai nguyen
#define CHECK(cond) do { \
  if (!(cond)) { \
    printf("  check failed: %s (dòng %d)\n", #cond, __LINE__); \
    return -1; \
  } \
} while (0)

// CHECK_EQ: kiem tra dieu kien va tra ve gia tri cua wait().
#define CHECK_EQ(a, b) do { \
  int _a = (int)(a), _b = (int)(b); \
  if (_a != _b) { \
    printf("  check failed: %s == %s (%d != %d, dòng %d)\n", #a, #b, _a, _b, __LINE__); \
    return -1; \
  } \
} while(0)

#define SKIP(why) do { \
  printf("  skip: %s\n", why); \
  return 1; \
} while(0)

#define NCHILD 8

struct test { const char *name; int (*fn)(void); };


// ---- Các test ------
static int test_harness_sanity(void) { 
  CHECK(1 + 1 == 2); 
  return 0; 
}

static int test_fork_wait(void) {   
  int pid = fork();
  CHECK(pid >= 0);
  if (pid == 0) exit(7);
  int st = -1;
  CHECK_EQ(wait(&st), pid);
  CHECK_EQ(st, 7);
  return 0;
}

static int test_fork_many(void) {
  for (int i = 0; i < NCHILD; i++) {
    int pid = fork();
    CHECK(pid >= 0);
    if (pid == 0) exit(10 + i);
  }
  int seen = 0; //su dung co che bit, bit i = 1 khi nhan duoc con thu i
  for (int i = 0; i < NCHILD; i++) {
    int st = -1;
    CHECK(wait(&st) > 0); 
    CHECK(st >= 10 && st < 10 + NCHILD);
    seen |= 1 << (st - 10); //seen duoc OR voi 1 dich trai so bit tuong ung
  }
  CHECK_EQ(seen, (1 << NCHILD) - 1);
  return 0;
  
}

static int test_e1000_init(void) {
  SKIP("waiting...");
}

static int test_arp_request_tx(void) {
  SKIP("waiting...");
}

static struct test tests[] = {
  { "harness_sanity",  test_harness_sanity },
  { "fork_wait",       test_fork_wait },
  { "fork_many",       test_fork_many },
  { "e1000_init",      test_e1000_init },
  { "arp_request_tx",  test_arp_request_tx },
};

static void run(struct test *t) {
  int r = t->fn();
  if (r == 0) {
    printf("PASS: %s\n", t->name);
    npass++;
  } else if (r == 1) { 
    printf("SKIP: %s\n", t->name); 
    nskip++; 
  } else { 
    printf("FAIL: %s\n", t->name); 
    nfail++; 
  }
}

int main(int argc, char *argv[]) {
  int n = sizeof(tests) / sizeof(tests[0]);
  if (argc > 1) {
    int found = 0;
    for (int i = 0; i < n; i++) if (strcmp(tests[i].name, argv[1]) == 0) {
      run(&tests[i]);
      found = 1;
    }
    if (!found) {
      printf("FAIL: test not found '%s'\n", argv[1]);
      nfail++;
    }
  } else {
    for (int i = 0; i < n; i++) run(&tests[i]);
  }
  printf("NETTESTS: %d passed, %d failed, %d skipped\n", npass, nfail, nskip);
  printf("NETTESTS DONE\n");
  exit(nfail ? 1 : 0);
}