#!/bin/bash
#poweroff 순서
# server1 ->server2->main

for server in server1 server2 main
do
    ssh $server poweroff
    sleep 4
done