#!/usr/bin/env bash
# gitlab-runner-bin 갱신기. GitLab releases API 를 폴링해 default.nix 의 version/hash 두 값을 갱신한다.
#
# 단일 진실원천: gitlab.com/gitlab-org/gitlab-runner 의 releases (최신 버전)
#   + 그 릴리스의 release.sha256 (바이너리 체크섬).
#   ⚠️ releases API 의 **첫 항목이 최신 버전이 아니다.** 정렬 기준이 released_at 이라, 구 minor 의
#     패치가 나중에 나오면 앞에 온다(2026-08-25 실측: v19.3.1 다음이 v19.2.3, 그다음이 v19.3.0).
#     그래서 안정판 태그만 골라 **semver 로 정렬해** 최고값을 쓴다.
#   받은 바이트는 release.sha256 과 대조한 뒤에야 SRI 로 환산한다 — 해시를 메타파일에서 옮겨 적는
#   게 아니라, 실제 파일에서 계산한 값이 공식 체크섬과 같은지 확인한다.
#
# 로컬 수동 실행도 지원한다(인자 없음). CI 에서는 GITHUB_OUTPUT 에 결과를 실어 후속 스텝이 분기한다.
#   exit 0 + updated=false → 이미 최신(할 일 없음)
#   exit 0 + updated=true  → default.nix 가 수정됨
#   exit >0                → 조회/파싱/검증 실패(호출 측에서 실패로 취급)
set -euo pipefail

readonly API="https://gitlab.com/api/v4/projects/gitlab-org%2Fgitlab-runner/releases?per_page=50"
readonly DL="https://gitlab-runner-downloads.s3.amazonaws.com"
readonly ASSET="binaries/gitlab-runner-linux-amd64"
PKG="$(dirname "$0")/default.nix"
readonly PKG

emit() { # $1=key $2=value — CI 면 GITHUB_OUTPUT 에, 아니면 stdout 에.
  if [ -n "${GITHUB_OUTPUT:-}" ]; then printf '%s=%s\n' "$1" "$2" >> "$GITHUB_OUTPUT"; fi
  printf '%s=%s\n' "$1" "$2"
}

[ -f "$PKG" ] || { echo "error: $PKG 없음" >&2; exit 1; }
for c in curl jq openssl; do
  command -v "$c" >/dev/null || { echo "error: $c 필요 (로컬이면 nix-shell -p $c)" >&2; exit 1; }
done

releases=$(curl -fsSL --retry 3 --retry-delay 5 "$API") \
  || { echo "error: releases API 조회 실패" >&2; exit 1; }

# 안정판(vX.Y.Z)만 — rc/beta 태그는 제외한다.
new_ver=$(jq -r '.[].tag_name' <<<"$releases" \
  | sed -nE 's/^v([0-9]+\.[0-9]+\.[0-9]+)$/\1/p' | sort -V | tail -1)
old_ver=$(sed -nE 's/^  version = "(.+)";$/\1/p' "$PKG")

for v in new_ver old_ver; do
  [ -n "${!v}" ] || { echo "error: $v 파싱 실패 — API 응답이나 default.nix 서식을 확인" >&2; exit 1; }
done

emit old_version "$old_ver"
emit new_version "$new_ver"

if [ "$new_ver" = "$old_ver" ]; then
  echo "이미 최신: $old_ver"
  emit updated false
  exit 0
fi
# 최고 semver 가 현재보다 낮다면 upstream 이 릴리스를 내린 것이다. 자동으로 되돌리지 않고 사람이 판단한다.
if [ "$(printf '%s\n%s\n' "$old_ver" "$new_ver" | sort -V | tail -1)" = "$old_ver" ]; then
  echo "warn: 최신 릴리스가 $old_ver -> $new_ver 로 내려갔다(릴리스 철회?). 자동 갱신하지 않는다." >&2
  emit updated false
  exit 0
fi

# 파일명 끝을 고정해 매칭한다 — 안 그러면 gitlab-runner-linux-amd64-fips 도 같이 걸린다.
want=$(curl -fsSL --retry 3 --retry-delay 5 "$DL/v$new_ver/release.sha256" \
  | awk -v a="$ASSET" '$2 == a { print $1 }')
[ -n "$want" ] || { echo "error: release.sha256 에 $ASSET 항목이 없다 (v$new_ver)" >&2; exit 1; }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo "내려받는 중: $new_ver"
curl -fsSL --retry 3 --retry-delay 5 -o "$tmp/gitlab-runner" "$DL/v$new_ver/$ASSET" \
  || { echo "error: 바이너리 내려받기 실패: $DL/v$new_ver/$ASSET" >&2; exit 1; }

got=$(openssl dgst -sha256 -hex "$tmp/gitlab-runner" | awk '{print $NF}')
if [ "$got" != "$want" ]; then
  echo "error: sha256 불일치 — 받은 바이트가 release.sha256 과 다르다" >&2
  echo "  기대: $want" >&2
  echo "  실제: $got" >&2
  exit 1
fi

new_hash="sha256-$(openssl dgst -sha256 -binary "$tmp/gitlab-runner" | openssl base64 -A)"

# base64 는 / + = 를 포함할 수 있어 sed 구분자로 | 를 쓴다(base64 알파벳에 없음).
sed -i -E \
  -e "s|^  version = \".*\";$|  version = \"$new_ver\";|" \
  -e "s|^    hash = \"sha256-.*\";$|    hash = \"$new_hash\";|" \
  "$PKG"

echo "갱신: $old_ver -> $new_ver"
emit updated true
