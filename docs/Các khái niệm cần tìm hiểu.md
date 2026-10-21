# Các khái niệm cần tìm hiểu – Dự án xv6 E1000 + ARP/ICMP/UDP

Danh sách khái niệm chung cho nhóm 3 người. Mọi thành viên nên nắm các nhóm 1, 2 và 7, vì Q&A hỏi từng người về code của cả nhóm. Các nhóm còn lại có thể chia theo vai A (Driver), B (Protocol), C (Socket & Test).

## 1. Nền tảng xv6-riscv (cả nhóm)

- **Kernel/user mode, trap, syscall:** đường đi `ecall` → `usertrap` → `syscall()`, cách thêm syscall mới (`syscall.h`, `usys.pl`, `sysproc.c`).
- **Tiến trình và lập lịch:** `sleep/wakeup`, trạng thái tiến trình, `fork`.
- **Khóa:** spinlock, sleeplock, deadlock, và quy tắc không giữ lock khi `sleep`.
- **Ngắt và PLIC:** ngắt thiết bị được định tuyến thế nào, top half và bottom half của driver.
- **Bộ nhớ:** page table Sv39, `kalloc/kfree`, `copyin/copyout`, map vùng MMIO vào kernel (`kvmmap`).
- **File descriptor:** `struct file`, bảng file toàn cục và bảng fd theo tiến trình, đếm tham chiếu (`filedup`, `fileclose`).
- **Cách xv6 viết driver:** xem `console.c`, `uart.c` và `virtio_disk.c` để thấy mẫu driver có ring và ngắt.

## 2. Mạng cơ bản (cả nhóm)

- **Mô hình phân lớp:** Ethernet → IP → ICMP/UDP, đóng gói (encapsulation) và mở gói.
- **Khung Ethernet:** địa chỉ MAC, EtherType, địa chỉ broadcast, kích thước khung và MTU (1500).
- **Địa chỉ IPv4:** subnet mask, gateway, quyết định gửi trực tiếp hay qua gateway.
- **Thứ tự byte:** big-endian (network order) so với little-endian của RISC-V, `htons/ntohs`, và lỗi hay gặp khi ép kiểu struct.
- **Struct đóng gói:** `__attribute__((packed))`, vấn đề alignment khi parse gói.
- **Checksum Internet:** tổng bù một 16-bit (RFC 1071), dùng cho IP, ICMP, UDP.

## 3. Phần cứng và driver (chủ yếu A)

- **PCI/PCIe:** configuration space, vendor/device ID, BAR, ECAM, bit Memory Space và Bus Master Enable.
- **Memory-mapped I/O:** đọc/ghi thanh ghi qua con trỏ `volatile`, memory barrier (`__sync_synchronize`).
- **DMA:** card đọc/ghi RAM trực tiếp, địa chỉ vật lý so với ảo, buffer phải nằm trong vùng DMA được.
- **Vòng mô tả (descriptor ring):** con trỏ head/tail (`TDH/TDT`, `RDH/RDT`), cờ trạng thái (`DD`, `EOP`, `RS`), quy tắc sở hữu giữa phần cứng và phần mềm.
- **Intel E1000 (8254x):** các thanh ghi `CTRL`, `STATUS`, `RCTL`, `TCTL`, `RDBAL/RDLEN`, `TDBAL/TDLEN`, `IMS/ICR`, `RAL/RAH`; trình tự khởi tạo; mảng bộ lọc multicast (MTA).
- **Xử lý ngắt NIC:** đọc `ICR` để xóa ngắt, xử lý nhiều gói mỗi lần ngắt.
- **Ring đầy:** chiến lược drop, chặn chờ, hoặc trả lỗi, và đếm gói bị rớt.
- **QEMU:** `-device e1000`, `-netdev user/tap`, `filter-dump`.

## 4. ARP và IP/ICMP (chủ yếu B)

- **ARP (RFC 826):** request/reply, định dạng gói, gratuitous ARP, vì sao cần cache.
- **ARP cache:** TTL, trạng thái `INCOMPLETE/VALID`, hàng đợi gói chờ phân giải, retry và timeout, chính sách thay thế.
- **IPv4 (RFC 791):** các trường header (IHL, total length, TTL, protocol, checksum), kiểm tra gói đến.
- **ICMP (RFC 792):** echo request/reply (type 8/0), trường identifier và sequence, dữ liệu echo lại nguyên vẹn.
- **Ping:** đo RTT, timeout, nhiều kích thước gói, và cách xv6 lấy đồng hồ (`ticks`).
- **Chưa cần làm:** phân mảnh IP (fragmentation), nhưng nên biết để xử lý hoặc bỏ gói đúng.

## 5. UDP và socket (chủ yếu C)

- **UDP (RFC 768):** header 8 byte, checksum (có pseudo-header), không kết nối, không đảm bảo thứ tự hay tin cậy.
- **Cổng:** bảng cổng, bind, giá trị cổng nguồn và cổng đích, xử lý khi không có socket nhận.
- **Socket API kiểu BSD:** `socket/bind/sendto/recvfrom` và `connect` cho UDP.
- **Socket như file:** thêm loại `FD_SOCK` vào `struct file`, và `close`, `dup`, `fork` hoạt động ra sao với socket.
- **Hàng đợi nhận có giới hạn:** blocking `recvfrom` bằng `sleep/wakeup`, và chống cạn bộ nhớ khi bị flood.
- **Giải phóng tài nguyên khi đóng:** gói còn trong hàng đợi, cổng được trả lại.
- **Stretch:** giao thức DNS (RFC 1035: header, question, A record) và cách `nc -u` hoạt động.

## 6. Mạng trên host và kiểm thử (chủ yếu C)

- **QEMU user networking (slirp):** địa chỉ mặc định `10.0.2.15/10.0.2.2`, `hostfwd`, hạn chế của slirp.
- **TAP/TUN:** `ip tuntap`, gán địa chỉ cho `tap0`.
- **Công cụ bắt gói:** `tcpdump`, Wireshark, đọc file `.pcap`.
- **Scapy / raw socket Python:** tự dựng khung ARP, ICMP, UDP để làm host giả.
- **Kiểm thử kernel:** viết test tự kiểm tra, in `PASS/FAIL`, stress test, kiểm tra leak qua số trang trống trước và sau.
- **Đo hiệu năng:** lặp ≥ 5 lần, mean ± độ lệch chuẩn, vẽ biểu đồ.
- **CI:** GitHub Actions chạy QEMU và tính timeout của test.

## 7. Quy trình và công cụ dự án (cả nhóm)

- **Scrum:** sprint 1 tuần, planning, stand-up, review, retrospective, và các vai Product Owner/Scrum Master.
- **Jira:** viết user story, ước lượng, Definition of Done.
- **Figma/FigJam:** vẽ sơ đồ kiến trúc, bố cục dữ liệu và sequence diagram của luồng gói tin.
- **Git workflow:** feature branch, pull request có review chéo, commit message tham chiếu mã task.
- **Liêm chính học thuật:** quy tắc trích dẫn code tái sử dụng và chính sách dùng AI của môn học.

## Thứ tự nên học

1. **Tuần 1:** nhóm 1 và 2 (cả nhóm), cùng phần PCI/E1000 (A), RFC ARP/IP/ICMP (B), socket API (C).
2. **Tuần 2–3:** đào sâu phần của mình, đủ để viết proposal.
3. **Từ tuần 4:** học chéo bằng buổi trình bày 10 phút mỗi tuần.
