#!/bin/bash

SOURCE_CONF_FILE="/etc/named.conf"
SOURCE_ZONE_FILE="/etc/named.rfc1912.zones"
SOURCE_COMZONE_FILE="/var/named/example.com.zone"

DOMAIN="example"

# 설정할 Zone 정보
ZONE_NAME="example.com"
ZONE_TYPE="master"
ZONE_FILE="${ZONE_NAME}.zone"

#페키지 설치여부 확인
if ! rpm -q bind >/dev/null 2>&1; then
  echo "bind가 설치되어있지 않습니다, 설치를 시작합니다"
  dnf -y install bind
else
  echo "bind가 설치되어 있습니다"
fi

if ! rpm -q bind-utils >/dev/null 2>&1; then
  echo "bind-utils가 설치되어있지 않습니다, 설치를 시작합니다"
  dnf -y install bind
else
  echo "bind-utils가 설치되어 있습니다"
fi

# 방화벽 DNS 서비스 허용
#firewall-cmd --permanent --add-service=dns
#firewall-cmd --reload


#백업 파일 설정
if [[ -f /etc/named.conf.OLD ]]; then
  :
else
  cp /etc/named.conf /etc/named.conf.OLD
  echo "백업파일이 없어서 복사함"
fi

sed -i '/listen-on port 53/c\	listen-on port 53 { any; };' "$SOURCE_CONF_FILE"
sed -i '/listen-on-v6 port 53/c\	listen-on-v6 port 53 { any; };' "$SOURCE_CONF_FILE"
sed -i '/allow-query/c\        allow-query     { any; };' "$SOURCE_CONF_FILE"

# forwarders { 8.8.8.8; }; 설정 추가
# 'allow-query' 또는 'options {' 다음에 추가
if ! grep -q "forwarders" "$SOURCE_CONF_FILE"; then
    sed -i '/allow-query     { any; };/a \  forwarders { 8.8.8.8; };' "$SOURCE_CONF_FILE"
else
    sed -i 's/^.*forwarders {[^\;]*; };/        forwarders { 8.8.8.8; };/' "$SOURCE_CONF_FILE"
fi

# forward only; 설정 추가
if ! grep -q "forward only;" "$SOURCE_CONF_FILE"; then
    sed -i '/forwarders { 8.8.8.8; };/a \	forward only;' "$SOURCE_CONF_FILE"
else
    sed -i 's/^.*forward only;/        forward only;/' "$SOURCE_CONF_FILE"
fi

# dnssec-validation no; 설정
sed -i 's/^.*dnssec-validation[^;]*;/	dnssec-validation no;/' "$SOURCE_CONF_FILE"

# zone "." IN { ... }; 주석 처리
# 'zone'으로 시작하고 'hint'가 포함된 라인과 그 다음부터 '};'까지 주석 처리
sudo sed -i '/^zone "\." IN {/,/^};/ {s/^/# &/;}' "$SOURCE_CONF_FILE"

named-checkconf /etc/named.conf
if [[ $? -ne 0 ]]; then # 이전 명령어(named-checkconf)의 종료 코드가 0이 아니면 오류
  echo "오류: /etc/named.conf 파일에 문법 오류가 있습니다. 스크립트를 종료합니다."
  exit 1
fi

#zone 파일 설정

# 해당 zone이 이미 존재하는지 확인
if grep -q "zone \"${ZONE_NAME}\" IN {" "$SOURCE_ZONE_FILE"; then
    echo "경고: '${ZONE_NAME}' zone 설정이 이미 파일에 존재합니다. 중복 추가하지 않습니다."
else
    # 파일 끝에 zone 설정 추가
    echo "" | sudo tee -a "$SOURCE_ZONE_FILE" > /dev/null # 줄바꿈 추가
    cat <<EOF | sudo tee -a "$SOURCE_ZONE_FILE" > /dev/null
zone "${ZONE_NAME}" IN {
    type ${ZONE_TYPE};
    file "${ZONE_FILE}";
};
EOF
    echo "성공: '${ZONE_NAME}' zone 설정이 파일에 추가되었습니다."
fi

# 존파일 검사
named-checkconf /etc/named.rfc1912.zones 

# 파일 내용이 이미 존재하는지 확인
# 특정 핵심 줄 (예: SOA 레코드의 ns1.도메인.com 부분)을 기준으로 검사
if grep -q "ns1.${DOMAIN}.com." "$SOURCE_COMZONE_FILE"; then
    echo "정보: '${SOURCE_COMZONE_FILE}' 파일에 '${DOMAIN}.com' Zone 레코드가 이미 존재합니다. 다시 작성하지 않습니다."
    echo "------------------------------------------------"
    echo "### 스크립트 실행 완료 ###"
    exit 0 # 스크립트 종료
fi

# here document를 사용하여 zone 파일 내용 작성
cat <<EOF > "$SOURCE_COMZONE_FILE"
\$TTL 86400        ; 기본 TTL (Time To Live): 1일
@                 IN SOA  ns1."$DOMAIN".com. root.com. (
                          10      ; serial
                          1D      ; refresh
                          1H      ; retry
                          1W      ; expire
                          3H )    ; minimum

;; DNS Server
"$DOMAIN".com.       IN    NS    ns1."$DOMAIN".com.
ns1."$DOMAIN".com.  IN    A     192.168.10.10

;; DNS Domain
main              IN    A     192.168.10.10 
server1           IN    A     192.168.10.20
server2           IN    A     192.168.10.30
EOF

chown ${named}:${NAMED_GROUP} "$SOURCE_COMZONE_FILE"
chmod 640 "$SOURCE_COMZONE_FILE"