#!/bin/bash
#####################
# 페키지 생성
# 키 쌍 생성
# 키 배포
######################

set -e
# 1. 페키지 생성
dnf -q -y install sshpass

# 2. 키 쌍 생성
echo -e 'y/n' | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# 3. 키 배포

for host in main server1 server2
do
    sshpass -p 'soldesk1.' ssh-copy-id -o StrictHostKeyChecking=no $host
done

# 4. 키베포 확인
for host in main server1 server2
do
    ssh $host hostname
done

