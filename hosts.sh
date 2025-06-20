#!/bin/bash

#HOST=/etc/hosts
HOSTS=/root/shell/hosts
NET=192.168.10

for i in $(seq 200 230)
do
    echo "$NET.$i Linus$i.example.com Linux$i" >> "$HOSTS"
done

cat "$HOSTS"