#!/bin/bash

# 10% | =>
# 50% | ======>

for i in $(seq 1 10)
do
#clear
    PERCENT=$(expr $i \* 10)
    echo -ne "$PERCENT% |"

    for j in $(seq $i)
    do
        echo -ne "="
    done 

    if [ $i -eq 10 ]; then
        echo -ne " | complete "  
        echo
    else
        echo -ne ">"
    fi

    echo -ne "\r"
    #echo -ne "\n"
    sleep 1
done