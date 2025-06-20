#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {httpd|nginx}"
    exit 1
fi
WEBSVC=$1

PkgInstall() {
    PKG=$*
    yum -q -y install $PKG >/dev/null 2>&1
    rpm -q $PKG >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "[  OK  ] 패키지($PKG)가 설치가 완료 되었습니다."
    else
        echo "[ FAIL ] 패키지($PKG) 설치가 완료되지 않았습니다."
        exit 2
    fi
}

MakeIndex() {
    INDEX=$1
    echo "$WEBSVC" | tr [a-z] [A-Z] > "$INDEX"
    if [ -f "$INDEX" ]; then
        echo "[  OK  ] $INDEX 파일 생성 되었습니다."
    else
        echo "[ FAIL ] $INDEX 파일이 생성되지 않았습니다."
        exit 3
    fi
}

SvcStart() {
    SVCNAME=$1
    systemctl enable $SVCNAME >/dev/null 2>&1
    systemctl restart $SVCNAME > /dev/null 2>&1
    SVCSTATUS=$(systemctl is-active $SVCNAME)
    if [ "$SVCSTATUS" = 'active' ]; then
        echo "[  OK  ] 서비스($SVCNAME)가 정상적으로 동작 되었습니다."
    else
        echo "[ FAIL ] 서비스($SVCNAME)가 정상적으로 동작되지 않았습니다."
        exit 4
    fi
}

Httpd() {
    PkgInstall httpd mod_ssl
    MakeIndex /var/www/html/index.html
    systemctl disable --now nginx >/dev/null 2>&1
    SvcStart httpd
}

Nginx() {
    PkgInstall nginx
    MakeIndex /usr/share/nginx/html/index.html
    systemctl disable --now httpd >/dev/null 2>&1
    SvcStart nginx
}

case $WEBSVC in
    'httpd') Httpd ;;
    'nginx') Nginx ;;
    *)       echo "Usage: $0 {httpd|nginx}" ; exit 1 ;;
esac
