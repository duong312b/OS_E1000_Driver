#ifndef NETINFO_H
#define NETINFO_H

struct netinfo {
    uint32 ip; // ip cua xv6
    uint8 mac[6]; // MAC
    uint16 nsock; // so socket dang mo

    // L2: lay tu bo dem cua net,c
    uint32 rx_arp; // so luong goi tin arp da nhan thanh cong
    uint32 rx_ip; // so luong goi tin ip da nhan thanh cong
    uint32 rx_drop; // so goi tin nhan duoc nhung bi drop
    uint32 tx_frames; // so Ethernet frame da duoc truyen
    uint32 tx_err; // so Ehternet frame bi loi khi truyen

    // L4 UDP
    uint32 udp_rx; // so goi tin udp nhan thanh cong
    uint32 udp_tx; // so goi tin udp gui thanh cong
    uint32 udp_noport; // so goi tin udp bi loai do khong co socket nao lang nghe o cong dich
    uint32 udp_qfull; // so goi tin udp bi loai do day hang doi
    uint32 udp_bad; // so goi tin udp bi loai do hong/ sai cau truc
};

#endif