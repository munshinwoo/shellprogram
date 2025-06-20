#!/bin/bash

basedir=/root/shell
serverlist="$basrdir"/server.list

#서버목로 파일생성
: << EOF
192.168.10.10
192.168.10.20
192.168.10.30
EOF


for ip in $(cat "$serverlist")
do
    echo $i
    ftp -n $ip 21 << EOF
    user root soldesk1.
    lcd /test
    cd /tmp
    bin
    hash
    prompt
    mput testfile.txt
    bye
EOF
done
