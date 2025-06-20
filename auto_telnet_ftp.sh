#!/bin/bash

IP=192.168.10.20
PORT=23
DATE=$(date +%m%d)


Cmd(){
    sleep 2; echo 'root'
    sleep 0.5; echo 'soldesk1.'
    sleep 0.5; echo 'tar cvzf /tmp/linux$(date +%m%d).tar.gz /home'
    sleep 0.5; echo 'exit 1'
}
Cmd | telnet $IP

ftp -n "$IP" 21 << EOF
user root soldesk1.
cd /tmp
lcd /root
bin
hash
prompt
mget linux_$DATE.tar.gz
quit
EOF

ls -l /root/linux*