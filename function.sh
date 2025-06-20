#Variabled Definitions


# SvcStop <SERVICE>
SvcStop() {
    SVC=$1
    systemctl disable $SVC >/dev/null 2>&1
    systemctl stop $SVC >/dev/null 2>&1
    echo "[  OK  ] $SVC 서비스 중지"
}

# SvcStart <SERVICE>
SvcStart() {
    SVC=$1
    systemctl enable $SVC >/dev/null 2>&1
    systemctl start $SVC >/dev/null 2>&1
    SVCSTATUS=$(systemctl is-active $SVC)
    if [ $SVCSTATUS = 'active' ]; then
        echo "[  OK  ] $SVC 서비스 기동"
    else
        echo "[ FAIL ] $SVC 서비스 기동 실패"
        exit 2
    fi
}

# PkgInstall <PKG>
PkgInstall() {
    PKGS=$*
    yum -q -y install "$PKGS" >/dev/null 2>/dev/null
    rpm -q $PKGS >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "[  OK  ] $PKGS 설치 완료"
    else
        echo "[ FAIL ] $PKGS 설치 실패"
        exit 3
    fi
}

function print_good () {
    echo -e "\x1B[01;32m[ 성공 ]\x1B[0m $1"
}

function print_error () {
    echo -e "\x1B[01;31m[ 에러 ]\x1B[0m $1"
}

function print_info () {
    echo -e "\x1B[01;34m[ info ]\x1B[0m $1"
}