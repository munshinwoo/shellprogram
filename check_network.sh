#!/bin/bash


source /root/shell/function.sh

#print_good ""
#print_error ""
#

IP1=192.168.10.2
IP2=8.8.8.8
IP3=www.google.com

print_info "ping 192.168.10.2"
ping -c 1 $IP1 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    print_good "로컬 네트워크 점검"
else
    print_error "로컬 내트워크 점검"
    cat << EOF
    (a) VMWare > Edit > Virtual Network Editor
    (b) VMware > VM > Settings > Network Adapter
    (c) # ip addr
EOF
fi

print_info "8.8.8.8"
ping -c 2 -W 1 "$IP2" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    print_good "외부 네트워크 점검"
else
    print_error "외부 내트워크 점검"
    cat << EOF
    echo "  (a) # netstat -nr (# route -n)"
EOF
fi

print_info "ping www.gopgle.com"
ping -c 2 -W 1 "$IP3" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    print_good "DNS 클라이언트 점검"
else
    print_error "DNS 클라이언트 점검"
    cat << EOF
    echo "  (a) cat /etc/resolv.conf
EOF
fi