#!/bin/bash

basedir=/root/shell
serverlist=$basedir/telnet.list

cat  << EOF > $serverlist
192.168.10.10 root  soldesk1.
192.168.10.20 user01 user01
192.168.10.30 user02 user02
EOF