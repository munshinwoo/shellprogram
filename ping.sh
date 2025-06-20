#!/bin/bash

cat << EOF > server.list
192.168.10.10  
192.168.10.20
192.168.10.30
EOF

NET=192.168.10

for ip in 10 20 30
do
    ping -c 1 -W 1 $NET.$ip >/dev/null 2>&1
    [ $? -eq 0 ] \
     && echo "[ ok ] $NET.$ip" \
     || echo "[ fail ]" $NET.$ip
done