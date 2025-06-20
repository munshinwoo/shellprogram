#!/bin/bash

echo -n "Enter A : "
read A1

echo -n "Enter B : "
read B1

cat << EOF
==============================================
(1) +    (2) -   (3) x   (4) /
==============================================
EOF
echo -n "Enter you choice? : "
read C1

case $C1 in
        1) echo "$A1 + $B1 = $(expr $A1 + $B1)"  ;;
        2) echo "$A1 - $B1 = $(expr $A1 - $B1)"  ;;
        3) echo "$A1 x $B1 = $(expr $A1 \* $B1)" ;;
        4) echo "$A1 / $B1 = $(expr $A1 / $B1)"  ;;
        *) echo "Error1"
       exit 1 ;;
esac