#!/bin/bash

set -e

LOCAL_REPO_PATH=/root/shell

REMOTE_REPO_URL="https://github.com/munshinwoo/shellprogram.git"

REMOTE_NAME="origin"

COMMIT_MESSAGE="code update"

# 1. Git 설치 확인
echo "정보: Git 설치 여부 확인 중..."
if ! command -v git &> /dev/null; then
    echo "오류: Git이 설치되어 있지 않습니다. Git을 먼저 설치해주세요."
    echo "dnf install git"
    exit 1
fi
echo "정보: Git이 설치되어 있습니다."

# 2. 로컬 저장소 경로 이동
echo "정보: 로컬 저장소 경로로 이동 중: ${LOCAL_REPO_PATH}"
if [[ ! -d "$LOCAL_REPO_PATH" ]]; then
    echo "오류: 지정된 로컬 저장소 경로 '${LOCAL_REPO_PATH}'가 존재하지 않습니다."
    exit 1
fi
cd "$LOCAL_REPO_PATH" || { echo "오류: 경로 이동 실패."; exit 1; }
echo "정보: 경로 이동 완료."

# 3. Git 저장소 초기화 또는 확인 (필요시)
if [[ ! -d ".git" ]]; then
    echo "정보: 현재 디렉토리가 Git 저장소가 아닙니다. Git 초기화 중..."
    git init
    if [[ $? -ne 0 ]]; then echo "오류: Git 초기화 실패."; exit 1; fi
    echo "정보: Git 저장소 초기화 완료."
else
    echo "정보: 현재 디렉토리는 이미 Git 저장소입니다."
fi

# 4. 원격 저장소 설정 확인 및 추가
echo "정보: 원격 저장소 '${REMOTE_NAME}' 설정 확인 중..."
if ! git remote get-url "$REMOTE_NAME" &> /dev/null; then
    echo "경고: 원격 저장소 '${REMOTE_NAME}'가 설정되어 있지 않습니다. 추가 중..."
    git remote add "$REMOTE_NAME" "$REMOTE_REPO_URL"
    if [[ $? -ne 0 ]]; then echo "오류: 원격 저장소 추가 실패. URL을 확인하세요."; exit 1; fi
    echo "정보: 원격 저장소 '${REMOTE_NAME}' 추가 완료."
else
    # 원격 저장소 URL이 설정된 URL과 다르면 업데이트
    CURRENT_REMOTE_URL=$(git remote get-url "$REMOTE_NAME")
    if [[ "$CURRENT_REMOTE_URL" != "$REMOTE_REPO_URL" ]]; then
        echo "경고: 원격 저장소 '${REMOTE_NAME}'의 URL이 다릅니다. 업데이트 중..."
        git remote set-url "$REMOTE_NAME" "$REMOTE_REPO_URL"
        if [[ $? -ne 0 ]]; then echo "오류: 원격 저장소 URL 업데이트 실패."; exit 1; fi
        echo "정보: 원격 저장소 URL 업데이트 완료."
    else
        echo "정보: 원격 저장소 '${REMOTE_NAME}'가 올바르게 설정되어 있습니다."
    fi
fi


# 5. 변경사항 스테이징 (모든 변경사항 추가)
echo "정보: 모든 변경사항 스테이징 중 (git add .)..."
git add .
if [[ $? -ne 0 ]]; then echo "오류: git add 실패."; exit 1; fi
echo "정보: 변경사항 스테이징 완료."


# 6. 커밋 메시지 설정 (인자 우선, 없으면 기본값 사용)
if [[ -n "$1" ]]; then # 스크립트 실행 시 첫 번째 인자가 있으면
    COMMIT_MESSAGE="$1"
    echo "정보: 커밋 메시지 (인자 사용): ${COMMIT_MESSAGE}"
else
    echo "정보: 커밋 메시지 (기본값 사용): ${COMMIT_MESSAGE}"
fi


# 7. 변경사항 커밋
echo "정보: 변경사항 커밋 중..."
if git commit -m "$COMMIT_MESSAGE"; then
    echo "정보: 커밋 성공."
else
    # 커밋할 변경사항이 없을 경우 (nothing to commit)에도 성공으로 간주
    if git status --porcelain | grep -q "^??"; then # untracked files만 있다면
        echo "정보: Untracked 파일만 존재하고 커밋할 변경사항이 없습니다. 커밋 건너뜀."
    elif [[ $(git status --porcelain) ]]; then # untracked 외에 변경사항이 있는데 커밋 실패
        echo "오류: git commit 실패."
        exit 1
    else # 커밋할 변경사항이 아예 없을 경우 (nothing to commit, working tree clean)
        echo "정보: 커밋할 변경사항이 없습니다. 커밋 건너뜀."
    fi
fi


# 8. GitHub로 푸시
echo "정보: GitHub로 푸시 중..."
git push "$REMOTE_NAME" main # 또는 master 브랜치 (GitHub 기본은 main)

# 푸시 실패 시 비밀번호/토큰 입력이 필요할 수 있음을 안내
if [[ $? -ne 0 ]]; then
    echo "오류: git push 실패."
    echo "  GitHub 사용자 이름과 비밀번호(또는 개인 액세스 토큰)를 입력해야 할 수 있습니다."
    echo "  SSH 방식을 사용 중이라면 SSH 키 설정이 올바른지 확인하세요."
    exit 1
fi
echo "성공: 코드가 GitHub에 성공적으로 푸시되었습니다!"

echo "--- GitHub 푸시 스크립트 완료 ---"