#!/bin/bash

set -e

# 설정변수
path=/dev/sdb
mount_point=/oracle
fsype=xfs

if [[ ! -b "${path}1" ]]; then
    echo "파티션을 할당합니다"
    parted "$path" mklabel gpt
    parted "$path" mkpart primary xfs 1Mib 100%
    mkfs."$fsype" "${path}1"
    parted "$path" print | tail -n +6
else
    echo "파티션이 이미 할당되어 있습니다, 과정을 건너 뜀니다"
    parted "$path" print | tail -n +6
fi


if mountpoint -q "$mount_point"; then
    echo "이미 마운트가 되어있습니다"
    df -hT "$mount_point"
else
    echo "마운트 시작"
    mount "${path}1" "$mount_point"
    df -hT "$mount_point"
fi

