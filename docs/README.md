# xv6-riscv: E1000 Driver + ARP / ICMP / UDP

> **Môn học:** Xv6-riscv Term Projects (Fall 2026) · **Độ khó:** ★★ (demanding, +3 điểm thưởng độ khó) · **Nhóm:** 3 thành viên
> **Chủ đề:** Networking – viết driver card mạng Intel E1000 và một network stack tối thiểu cho xv6-riscv.

---

## 1. Tổng quan dự án

Xv6-riscv gốc **không có** hỗ trợ mạng. Dự án này bổ sung:

| Lớp | Thành phần | Mô tả ngắn |
|---|---|---|
| Thiết bị | **PCI + E1000 driver** | Dò thiết bị PCI, khởi tạo E1000 (QEMU), vòng mô tả TX/RX, ngắt |
| L2 | **Ethernet + ARP** | Đóng/mở khung Ethernet, ARP request/reply, **ARP cache** có timeout |
| L3 | **IPv4 + ICMP** | Kiểm tra checksum, **ICMP echo** (trả lời ping và chủ động gửi ping) |
| L4 | **UDP** | Demux theo cổng, hàng đợi nhận có giới hạn |
| Hệ thống | **UDP socket là file descriptor** | Socket dùng chung bảng `struct file`, dùng được với `read/write/close` |
| Công cụ | Chương trình user + script trên host | `ping`, `udpecho`, test C trong xv6, script Python trên host |
| Stretch | **DNS client**, **`nc -u`** | Làm sau khi phần lõi đã ổn định |

### Kết quả cần chứng minh (theo đề bài)

1. **Host ping xv6** và **xv6 ping host** thành công (có RTT).
2. **UDP echo** giữa xv6 và một script Python trên host (cả hai chiều).
3. Test **ping round-trip** và test **đầy vòng (full-ring)** của TX/RX.
4. Bộ test chạy bằng **một lệnh**, in `PASS/FAIL` cho từng case.

### Phạm vi

**Trong phạm vi:** IPv4, ARP, ICMP echo, UDP, một NIC E1000, một địa chỉ IP tĩnh.
**Ngoài phạm vi:** TCP, IPv6, DHCP, phân mảnh IP (fragmentation), nhiều NIC, routing phức tạp.

---

## 2. Cách đánh giá và ánh xạ vào dự án

| Tiêu chí | Điểm | Chúng ta cần làm gì |
|---|---|---|
| Core functionality | 30 | Ping 2 chiều, UDP echo, ARP cache, full-ring không crash; `usertests` + `grind` vẫn pass |
| Usage of project tools | 10 | Jira (bắt buộc), Figma/FigJam (bắt buộc), Scrum 1-tuần-sprint, PR có review, CI |
| Testing | 5 | **≥ 25 case**, có stress + failure-path, chạy `CPUS=1` và `CPUS=4`, lặp ≥ 10 lần |
| Code quality | 10 | Lock đúng, không leak, comment bất biến (invariant), commit history sạch |
| Measurement | 5 | RTT ping, throughput/pps UDP, tỉ lệ mất gói; ≥ 5 lần lặp, có mean ± độ lệch, biểu đồ |
| Proposal + midterm | 5 | Proposal **tuần 3**, demo giữa kỳ **tuần 5** |
| Progress reports | 10 | Báo cáo 1 trang **mỗi tuần**, so sánh TODO tuần trước với thực tế |
| Final demo & Q&A | 20 | **Mỗi thành viên** phải giải thích được code kernel của cả nhóm |
| Report | 5 | 15–20 trang: thiết kế, cài đặt, kết quả, hạn chế, ai làm gì |

**Điểm trừ cần tránh:** kernel không build ở tag cuối (−20), nộp trễ (−5/ngày), hồi quy `usertests` không giải trình (−5).
**Hệ số cá nhân (0.7–1.1):** dựa trên Git history, bản khai đóng góp, peer review và phần Q&A của từng người; ai không giải thích được code của mình tối đa 0.8.

---

## 3. Kiến trúc đề xuất

```
 user space   ping   udpecho   nc -u   dnsclient   nettests
                 \      |        |        /          /
 ─────────────── syscalls: socket / bind / sendto / recvfrom / (read, write, close) ───
 kernel          sysnet.c  ── struct sock (fd-backed, port, rxq, lock)
                    │
                  udp.c ──┐
                  icmp.c ─┼── ip.c ── arp.c (cache) ── ether.c / net.c
                          │                                 │
                          └────────── e1000.c  ◄── interrupt ──► PCI (pci.c)
                                          │
                       TX ring ◄──────────┴──────────► RX ring  (DMA buffers)
 ─────────────────────────────────────────────────────────────────────────────────────
 QEMU            -device e1000   ⟷   user-net (slirp)  hoặc  tap0
```

### File dự kiến thêm / sửa

| File | Nội dung |
|---|---|
| `kernel/pci.c` | Dò bus PCI (ECAM của QEMU `virt`), bật bus-master + memory space, map BAR |
| `kernel/e1000.c`, `kernel/e1000_dev.h` | Thanh ghi, init, `e1000_transmit()`, `e1000_intr()`, các vòng TX/RX |
| `kernel/net.c`, `kernel/net.h` | Cấu trúc header, `mbuf`/buffer, checksum, `net_rx()`, Ethernet |
| `kernel/arp.c` | ARP request/reply, cache, hàng đợi gói chờ phân giải |
| `kernel/ip.c`, `kernel/icmp.c` | IPv4 + ICMP echo |
| `kernel/udp.c` | UDP rx/tx, bảng cổng |
| `kernel/sysnet.c` | Socket như `struct file` (thêm `FD_SOCK`), syscall |
| `kernel/{syscall.c,syscall.h,sysproc.c,file.c,main.c,vm.c,defs.h,param.h}` | Đăng ký syscall, map MMIO, khởi tạo |
| `user/{ping,udpecho,nc,dnsclient,nettests}.c`, `user/user.h`, `user/usys.pl` | Chương trình user + test |
| `tests/host/*.py`, `tests/run_all.sh` | Script phía host, chạy toàn bộ test |
| `Makefile` | Thêm tham số QEMU cho NIC, target `make test` |

### Thiết kế chính cần chốt trong Proposal (tuần 3)

- **Vòng TX/RX:** số descriptor (ví dụ 16–64), cơ chế sở hữu buffer (kernel cấp phát, giải phóng sau khi gửi xong), xử lý **TX ring đầy** (trả lỗi hoặc ngủ chờ) và **RX ring đầy** (drop có đếm).
- **Khóa:** `e1000_lock` cho TX; RX xử lý trong ngắt, **không giữ lock khi gọi lên stack**; mỗi socket có spinlock riêng và hàng đợi nhận **giới hạn** (tránh cạn bộ nhớ khi bị flood).
- **ARP cache:** số entry cố định (ví dụ 16), TTL, trạng thái `INCOMPLETE/VALID`, hàng đợi gói chờ, thay thế entry cũ nhất, gửi lại ARP request có giới hạn số lần.
- **Socket API (đề xuất):**
  ```c
  int socket(void);                                   // trả về fd UDP
  int bind(int fd, int port);
  int sendto(int fd, const void *buf, int n, uint32 ip, int port);
  int recvfrom(int fd, void *buf, int n, uint32 *ip, int *port);   // chặn đến khi có gói
  int netinfo(struct netstat *st);                    // bộ đếm: rx/tx/drop/arp hit-miss
  // close(fd) giải phóng cổng; read/write dùng được sau khi connect (stretch)
  ```
- **Địa chỉ:** hai chế độ mạng (xem mục 5).

---

## 4. Cấu trúc thư mục repo

```
.
├── README.md
├── Makefile
├── kernel/ …            # code kernel (xem bảng trên)
├── user/ …              # chương trình user và nettests
├── tests/
│   ├── host/            # ping_xv6.sh, udp_echo_host.py, ...
│   └── run_all.sh       # một lệnh chạy toàn bộ test
├── docs/
│   ├── proposal.md
│   ├── weekly/week-01.md … week-09.md
│   ├── design/          # xuất từ Figma/FigJam (png/pdf)
│   └── report/
└── .github/workflows/ci.yml   # (tuỳ chọn) chạy QEMU trên mỗi push
```

---

## 5. Môi trường chạy và cấu hình QEMU

**Công cụ:** RISC-V GNU toolchain, QEMU (`qemu-system-riscv64`), Python 3 (+ `scapy` cho script host nếu cần), `tcpdump`/Wireshark để đọc pcap.

> Lưu ý: bản xv6-riscv gốc của MIT **chưa có** E1000. Bài lab networking của MIT 6.1810 có sẵn khung code E1000; nếu nhóm tham khảo, phải **trích dẫn rõ trong báo cáo** và code tái sử dụng sẽ **không được chấm**. Đừng chép lời giải công khai trên mạng (bị coi là đạo văn).

### Chế độ A – User-mode networking (slirp), không cần root

Dùng cho: xv6 → host và UDP echo với script Python.

```make
QEMUOPTS += -netdev user,id=net0,hostfwd=udp::$(FWDPORT)-:2000
QEMUOPTS += -object filter-dump,id=net0,netdev=net0,file=packets.pcap
QEMUOPTS += -device e1000,netdev=net0,bus=pcie.0
```

- xv6 dùng IP `10.0.2.15`, gateway/host `10.0.2.2`, MAC của host do slirp trả lời qua ARP.
- Host gửi UDP tới `127.0.0.1:$(FWDPORT)` sẽ được chuyển vào cổng 2000 của xv6.
- Gói tin được ghi vào `packets.pcap` để debug.

### Chế độ B – TAP, cho yêu cầu "host ping xv6"

Slirp không cho host chủ động ping vào guest, nên dùng TAP (cần `sudo`):

```bash
sudo ip tuntap add dev tap0 mode tap user $USER
sudo ip addr add 192.168.100.1/24 dev tap0 && sudo ip link set tap0 up
# QEMU: -netdev tap,id=net0,ifname=tap0,script=no,downscript=no
# xv6 : IP 192.168.100.2   →   host: ping 192.168.100.2
```

Nếu không có root: dùng `-netdev socket`/`dgram` và một script Python (scapy) đóng vai host, tự tạo khung ARP/ICMP/UDP. Cách này cũng dùng được trong CI.

---

## 6. Chiến lược kiểm thử (≥ 25 case)

Quy ước: một test chỉ được tính nếu **chạy tự động, tự kiểm tra kết quả, in `PASS`/`FAIL`**.

| Nhóm | Case ví dụ |
|---|---|
| **Driver / ring** | init E1000 đọc đúng MAC; gửi 1 khung; gửi liên tục > số descriptor (**TX ring đầy**); nhận burst > số descriptor (**RX ring đầy**, drop có đếm, không treo); khung quá dài/quá ngắn |
| **ARP** | trả lời ARP request cho IP của mình; bỏ qua request không phải của mình; cache hit/miss; hết hạn TTL; hàng đợi chờ phân giải; ARP không trả lời → timeout hợp lệ; cache đầy |
| **IP / ICMP** | trả lời echo từ host; ping host từ xv6 và đo RTT; sai checksum IP/ICMP bị bỏ; TTL, độ dài header sai; payload ping nhiều kích thước |
| **UDP / socket** | `socket/bind/sendto/recvfrom` đúng; **bind trùng cổng** lỗi; fd không hợp lệ, buffer NULL, độ dài âm; `close` giải phóng cổng; UDP echo với script Python; datagram rỗng và tối đa (1472 byte); cổng không có socket nhận → drop; hàng đợi socket đầy |
| **Đồng thời** | nhiều tiến trình cùng gửi/nhận; `fork` giữ fd socket; chạy với `CPUS=1` **và** `CPUS=4`, lặp ≥ 10 lần |
| **Tài nguyên** | số trang trống và số fd/inode **trước và sau** bộ test phải bằng nhau (không leak) |
| **Hồi quy** | `usertests` và `grind` của xv6 gốc vẫn pass |

**Cách chạy (mục tiêu):**

```bash
make qemu              # chạy xv6 với E1000
make test              # build + chạy toàn bộ test, in PASS/FAIL từng case
make test CPUS=4
tests/run_all.sh       # kèm các test phía host (ping, UDP echo)
```

**Benchmark (≥ 5 lần lặp mỗi điểm dữ liệu, báo cáo mean ± độ lệch):**
RTT ping theo kích thước gói · throughput UDP (pkt/s, Mbit/s) theo kích thước payload · tỉ lệ mất gói khi flood · độ trễ ARP miss so với hit.

---

## 7. Kế hoạch 6 tuần

> Khung thời gian của môn học là 9 tuần (đăng ký tuần 1, **proposal tuần 3**, **midterm tuần 5**, **code freeze tuần 8**, demo + báo cáo tuần 9). Kế hoạch dưới đây dồn **toàn bộ tính năng và test xong trong 6 tuần**, để tuần 7–9 là **vùng đệm** cho stretch, tối ưu, viết báo cáo và luyện demo. Nếu thực tế chỉ có 6 tuần tổng cộng, bỏ tuần đệm và cắt phần stretch.

### Phân vai

| Thành viên | Vai chính | Phụ trách |
|---|---|---|
| **A – Driver** | Phần cứng & ring | PCI, E1000, TX/RX ring, ngắt, cấu hình QEMU, test ring |
| **B – Protocol** | Giao thức | Ethernet, ARP + cache, IPv4, ICMP, chương trình `ping`, test ARP/ICMP |
| **C – Socket & Test** | API & kiểm thử | UDP, socket-as-fd, syscall, `udpecho`/`nc`, script host, `make test`, CI, benchmark |

- **Vai Scrum xoay vòng** mỗi 2 tuần: Product Owner / Scrum Master / Developer.
- **Luật chéo:** mỗi PR phải được **thành viên khác review**. Mỗi người **viết code kernel** (không chỉ test/báo cáo) để tránh bị hạ hệ số cá nhân.
- **Chéo kiến thức:** mỗi tuần một người trình bày 10 phút phần của mình cho hai người còn lại, vì Q&A hỏi từng người về code của cả nhóm.

### Bảng công việc theo tuần

| Tuần | Mục tiêu | A – Driver | B – Protocol | C – Socket & Test |
|---|---|---|---|---|
| **1** | Khởi động, môi trường chạy được | Đăng ký nhóm; đọc datasheet E1000 (§ ring, thanh ghi); dò PCI, in vendor/device ID ra console | Đọc RFC 826/791/792; vẽ khung header Ethernet/ARP/IP/ICMP; viết struct + hàm checksum | Tạo repo + Jira + Figma, cấp quyền cho giảng viên; sửa Makefile thêm `-device e1000`; dựng khung `make test` và CI rỗng |
| **2** | Gửi/nhận khung thô | Map BAR, init E1000, TX ring + RX ring, gửi được 1 khung (kiểm tra bằng pcap) | Parser Ethernet; `net_rx()` phân loại ARP/IP; gửi ARP request thủ công | Test harness (`nettests.c`, macro PASS/FAIL); script host gửi/nhận UDP thô; vẽ sơ đồ kiến trúc, bắt đầu proposal |
| **3** | **Proposal nộp**; ARP chạy | Ngắt RX, nhận khung vào stack; xử lý ring đầy (drop + đếm); ≥ 4 test ring | ARP reply + **ARP cache** (TTL, hàng đợi chờ); test ARP | Hoàn thiện proposal 2–3 trang (cấu trúc dữ liệu, file sửa, syscall, kế hoạch test); thiết kế API socket; tạo `struct sock` + `FD_SOCK` |
| **4** | Ping 2 chiều, UDP | Ổn định lock TX/RX; test burst, `CPUS=4`; bộ đếm thống kê | IPv4 rx/tx; **ICMP echo reply** (host ping xv6); `ping` user (xv6 ping host, RTT) | UDP rx/tx + bảng cổng; syscall `socket/bind/sendto/recvfrom`; `udpecho` user; script UDP echo Python |
| **5** | **Midterm demo** | Chế độ TAP; kiểm tra pcap với Wireshark; sửa lỗi ring | Hoàn thiện ping (nhiều kích thước, timeout); test ICMP lỗi (checksum, TTL) | Demo 10 phút (ping 2 chiều + UDP echo); test case ≥ 15; CI chạy QEMU trên mỗi push |
| **6** | Hoàn thiện, **feature freeze** | Test full-ring, stress; kiểm tra leak buffer/DMA; `usertests` + `grind` | Tinh chỉnh ARP (cache đầy, retry); review lock toàn stack | Đủ **≥ 25 case**, lặp 10 lần cho `CPUS=1/4`; leak check; benchmark ≥ 5 lần lặp, vẽ biểu đồ |
| 7–9 | Đệm, stretch, báo cáo, demo | DNS client (gợi ý: B) và `nc -u` (gợi ý: C); sửa lỗi; hoàn thiện báo cáo 15–20 trang; luyện demo cả 3 người; tag cuối **trước tuần 8** | | |

### Definition of Done (áp dụng cho mọi task trên Jira)

- Có người được giao, có ước lượng, trạng thái đúng trên board.
- Code build sạch bằng `make`, có comment về bất biến khóa/ownership.
- Có test tương ứng, in PASS.
- PR đã được người khác review và merge; commit message ghi mã task (ví dụ `NET-12`).
- Không làm hỏng `usertests`.

### Cột mốc nội bộ

| Cuối tuần | Phải chứng minh được |
|---|---|
| 2 | Khung thô gửi ra được và thấy trong `packets.pcap` |
| 3 | Proposal nộp; xv6 trả lời ARP request |
| 4 | Host ping xv6 thành công; UDP datagram gửi/nhận được |
| 5 | **Demo giữa kỳ:** ping 2 chiều + UDP echo với Python, test chạy trong CI |
| 6 | Feature freeze: ≥ 25 test pass, benchmark xong, không leak |

---

## 8. Quản lý dự án và báo cáo hằng tuần

**Báo cáo 1 trang mỗi tuần** (lưu tại `docs/weekly/week-NN.md`), gồm:

1. **Việc đã làm theo từng thành viên** – kèm link task Jira và commit.
2. **Kết quả** – cái gì chạy, số test pass/fail, số liệu đo, vấn đề phát hiện.
3. **Blocker và rủi ro** – cái gì đang kẹt, cần giúp gì.
4. **TODO tuần sau** – theo từng người, có ước lượng và Definition of Done.

Bắt buộc **so sánh TODO tuần trước với thực tế**. Thiếu báo cáo hoặc báo cáo không ghi việc cá nhân sẽ bị ghi vào hệ số cá nhân.

**Nhịp Scrum (sprint 1 tuần):** planning đầu tuần · stand-up ≥ 2 lần/tuần · review + retrospective cuối tuần → làm đầu vào cho báo cáo.

**Công cụ bắt buộc:** Jira (hoặc Trello/GitHub Projects nếu được duyệt) và Figma/FigJam – cấp quyền đọc cho giảng viên **từ tuần 2**.

---

## 9. Rủi ro và cách giảm thiểu

| Rủi ro | Cách giảm thiểu |
|---|---|
| Driver E1000 khó debug (DMA, thanh ghi) | Bật `filter-dump` pcap từ ngày đầu; in trạng thái thanh ghi `TDH/TDT/RDH/RDT`; làm A sớm nhất, B và C tạm dùng gói giả để làm song song |
| Host không ping được vào slirp | Dùng chế độ TAP hoặc script Python (scapy) làm host giả |
| Race giữa ngắt RX và syscall | Không giữ lock khi gọi lên stack; hàng đợi socket có lock riêng; test `CPUS=4` lặp nhiều lần |
| Leak buffer khi drop gói | Quy ước rõ bên nào giải phóng; test free-page trước/sau |
| Một người gánh quá nhiều | Họp cuối tuần cân lại việc; review chéo; chia sẻ kiến thức |
| Lỡ mốc tuần 3 / 5 | Chốt phạm vi tối thiểu: ping 2 chiều + UDP echo; stretch chỉ làm khi đã xong |
| Vi phạm liêm chính học thuật | Tự viết code, trích dẫn rõ mọi phần tái sử dụng, mọi thành viên giải thích được từng dòng |

---

## 10. Checklist trước khi nộp (code freeze)

- [ ] `make` build sạch ở tag cuối, `make qemu` chạy được
- [ ] `make test` in PASS/FAIL, ≥ 25 case, pass với `CPUS=1` và `CPUS=4` (lặp ≥ 10 lần)
- [ ] Host ping xv6 và xv6 ping host
- [ ] UDP echo với script Python hoạt động hai chiều
- [ ] Test ring đầy (TX và RX), test lỗi tham số
- [ ] Không leak: số trang trống trước = sau
- [ ] `usertests` và `grind` pass
- [ ] Benchmark ≥ 5 lần lặp, có mean ± độ lệch và biểu đồ
- [ ] Báo cáo 15–20 trang, bản khai đóng góp cá nhân
- [ ] Jira, Figma, repo cho giảng viên truy cập; weekly report đủ
- [ ] Mỗi thành viên giải thích được toàn bộ code của mình và luồng gói tin từ NIC đến `recvfrom`

---

## 11. Tài liệu tham khảo

- Repo xv6-riscv: <https://github.com/mit-pdos/xv6-riscv>
- Sách xv6 (MIT 6.1810) – chương về driver và ngắt
- Intel 8254x Software Developer's Manual (E1000)
- RFC 826 (ARP), RFC 791 (IP), RFC 792 (ICMP), RFC 768 (UDP), RFC 1035 (DNS, cho stretch)
- Tài liệu QEMU: user networking, `-netdev tap`, `filter-dump`
