#!/bin/bash

max=5
for i in $(seq 1 $max)
do
    # 공백 라인
    for k in $(seq $(expr "$max" - "$i") -1 1)
    do
        echo -n ' '
    done
    # 별 개수(왼쪽)
    for j in $(seq 1 "$i")
    do
        echo -n '*'
    done
    # 별 개수(오른쪽)
    for k in $(seq 1 $(expr "$i" - 1))
    do
        echo -n '*'
    done
    echo 
done 