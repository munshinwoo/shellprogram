#!/bin/bash

set -e

BASEDIR=/root/shell
ENV=$BASEDIR/env.conf
SCRIPTDIR=$BASEDIR/scripts

#: << EOT
cat << EOF > $ENV
# 서비스 설정
firewalld=off
selinux=off
telnet_server=on
ftp_server=on
httpd_server=on

# 환경 구성
bashrc=on
vimrc=on

# 패키지 설치
epel=on
pkg=gcc,boxes,cowsay

#바탕화면 아이콘 생성 및 폰트 조정
desktopicon=on
font=폰트채,크기
EOF
#EOT

#: << EOF 
mkdir -p $BASEDIR/scripts
FILES='firewalld.sh 
selinux.sh 
telnet_server.sh 
ftp_server.sh 
httpd_server.sh 
bashrc.sh 
vimrc.sh 
epel.sh
pkg.sh
desktopicon.sh'
for i in $FILES
do
    > $BASEDIR/scripts/$i
done
chmod 755 $BASEDIR/scripts/*.sh

tree $BASEDIR/scripts
#EOF

# env.conf 파일 분석
[ ! -f $BASEDIR/env.conf ] && exit 1

for line in $(cat $ENV | egrep -v '^$|^#')
do
    FUN="$(echo "$line" | awk -F= '{print $1}')"
    ONOFF="$(echo "$line" | awk -F= '{print $2}')"
    # echo "$FUN : $ONOFF" ; read

    case "$FUN" in 
        firewalld)     $SCRIPTDIR/$FUN.sh $ONOFF ;;
        selinux)       $SCRIPTDIR/$FUN.sh $ONOFF ;;
        telnet_server) $SCRIPTDIR/$FUN.sh $ONOFF ;;
        ftp_server)    $SCRIPTDIR/$FUN.sh $ONOFF ;;
        httpd_server)  $SCRIPTDIR/$FUN.sh $ONOFF ;;
        bashrc)        $SCRIPTDIR/$FUN.sh $ONOFF ;;
        vimrc)         $SCRIPTDIR/$FUN.sh $ONOFF ;;
        epel)          $SCRIPTDIR/$FUN.sh $ONOFF ;;
        pkg)           $SCRIPTDIR/$FUN.sh $ONOFF ;;
        desktopicon)   $SCRIPTDIR/$FUN.sh $ONOFF ;;
        *) echo '[ Syntax Error ] env.conf 파일의 문법이 잘못 되었습니다.'
           exit 1 ;;
    esac
done
