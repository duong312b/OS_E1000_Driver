#!/usr/bin/env bash
# Chạy toàn bộ test: (1) test trong xv6 (user/nettests), (2) test phía host (tests/host/*.sh|*.py).
# Biến môi trường:
#   CPUS_LIST  danh sách số CPU cần thử        (mặc định "1 4")
#   REPEAT     số lần lặp mỗi cấu hình         (mặc định 1; đề bài yêu cầu >= 10 ở bản cuối)
#   BOOT_TIMEOUT / TEST_TIMEOUT  giây          (mặc định 60 / 120)
#   FWDPORT    cổng host chuyển vào xv6        (mặc định 26000)
# Mã thoát: 0 nếu mọi lần chạy đều không có FAIL và nettests chạy tới "NETTESTS DONE".
set -u
cd "$(dirname "$0")/.."

CPUS_LIST=${CPUS_LIST:-"1 4"}
REPEAT=${REPEAT:-1}
BOOT_TIMEOUT=${BOOT_TIMEOUT:-60}
TEST_TIMEOUT=${TEST_TIMEOUT:-120}
FWDPORT=${FWDPORT:-26000}
LOGDIR=tests/logs
mkdir -p "$LOGDIR"

total_runs=0; bad_runs=0

kill_group() { kill -- -"$1" 2>/dev/null; sleep 1; kill -9 -- -"$1" 2>/dev/null; pkill -f qemu-system-riscv64 2>/dev/null; true; }

run_xv6_tests() {   # $1 = cpus, $2 = lần thứ mấy
  local cpus=$1 iter=$2
  local log="$LOGDIR/xv6-cpus${cpus}-run${iter}.log"
  : > "$log"

  # setsid: để có thể giết cả nhóm tiến trình (make + qemu) khi xong/timeout.
  setsid bash -c "
    # đợi shell của xv6 khởi động rồi mới gõ lệnh
    ( t=0
      until grep -q 'init: starting sh' '$log' 2>/dev/null; do
        sleep 0.2; t=\$((t+1)); [ \$t -gt $((BOOT_TIMEOUT*5)) ] && exit 0
      done
      sleep 0.5; echo nettests; sleep $TEST_TIMEOUT
    ) | make qemu CPUS=$cpus FWDPORT=$FWDPORT
  " > "$log" 2>&1 &
  local pid=$!

  local waited=0 limit=$(( (BOOT_TIMEOUT + TEST_TIMEOUT) * 2 ))
  while ! grep -q 'NETTESTS DONE' "$log" 2>/dev/null; do
    sleep 0.5; waited=$((waited+1))
    [ $waited -ge $limit ] && break
  done
  kill_group "$pid"; wait "$pid" 2>/dev/null

  local npass nfail done_ok=0
  npass=$(grep -c '^PASS: ' "$log"); nfail=$(grep -c '^FAIL: ' "$log")
  grep -q 'NETTESTS DONE' "$log" && done_ok=1

  grep -E '^(PASS|FAIL): ' "$log"
  echo "  -> CPUS=$cpus run=$iter: pass=$npass fail=$nfail done=$done_ok (log: $log)"

  total_runs=$((total_runs+1))
  if [ "$nfail" -ne 0 ] || [ "$done_ok" -ne 1 ]; then bad_runs=$((bad_runs+1)); return 1; fi
  return 0
}

run_host_tests() {  # test phía host: tests/host/test_*.sh hoặc test_*.py (tuần 2+ sẽ có)
  local f rc=0
  for f in tests/host/test_*.sh tests/host/test_*.py; do
    [ -e "$f" ] || continue
    echo "== host: $f"
    case "$f" in *.py) python3 "$f" ;; *) bash "$f" ;; esac || rc=1
  done
  return $rc
}

for cpus in $CPUS_LIST; do
  for i in $(seq 1 "$REPEAT"); do
    echo "=== xv6 tests: CPUS=$cpus, lần $i/$REPEAT ==="
    run_xv6_tests "$cpus" "$i"
  done
done

run_host_tests || bad_runs=$((bad_runs+1))

echo
echo "TỔNG KẾT: $total_runs lần chạy xv6, $bad_runs lần lỗi"
[ "$bad_runs" -eq 0 ] && { echo "ALL PASS"; exit 0; } || { echo "SOME FAIL"; exit 1; }