#!/usr/bin/env bash
# UpNote 버전 갱신기. 업스트림이 버전 없는 롤링 URL 만 제공해 flake/dependabot 어느 쪽도 신버전을
# 알려주지 못하므로(→ 조용히 뒤처짐), latest-linux.yml 을 직접 폴링해 default.nix 의 version/hash 를 갱신한다.
#
# 단일 진실원천: https://download.getupnote.com/app/latest-linux.yml (electron-builder 메타파일).
#   version + 아티팩트별 sha512(base64) 를 주며, base64 sha512 는 그대로 SRI(`sha512-…`) 로 쓸 수 있다.
#
# 로컬 수동 실행도 지원한다(인자 없음). CI 에서는 GITHUB_OUTPUT 에 결과를 실어 후속 스텝이 분기한다.
#   exit 0 + updated=false → 이미 최신(할 일 없음)
#   exit 0 + updated=true  → default.nix 가 수정됨
#   exit >0                → 조회/파싱 실패(호출 측에서 실패로 취급)
set -euo pipefail

readonly META_URL="https://download.getupnote.com/app/latest-linux.yml"
PKG="$(dirname "$0")/default.nix"
readonly PKG

emit() { # $1=key $2=value — CI 면 GITHUB_OUTPUT 에, 아니면 stdout 에.
  if [ -n "${GITHUB_OUTPUT:-}" ]; then printf '%s=%s\n' "$1" "$2" >> "$GITHUB_OUTPUT"; fi
  printf '%s=%s\n' "$1" "$2"
}

[ -f "$PKG" ] || { echo "error: $PKG 없음" >&2; exit 1; }

meta=$(curl -fsSL --retry 3 --retry-delay 5 "$META_URL") \
  || { echo "error: $META_URL 조회 실패" >&2; exit 1; }

# version 은 파일 첫 줄. sha512 는 .deb 아티팩트 블록 안의 것만 집는다 — 파일 말미에 있는 최상위
#   sha512 는 AppImage(= path:) 것이라 그걸 집으면 엉뚱한 해시가 박힌다.
new_ver=$(sed -nE '1s/^version: (.+)$/\1/p' <<<"$meta")
new_hash=$(sed -nE '/url: upnote_amd64\.deb/,/^ *size:/s/^ *sha512: (.+)$/\1/p' <<<"$meta")
old_ver=$(sed -nE 's/^  version = "(.+)";$/\1/p' "$PKG")

for v in new_ver new_hash old_ver; do
  [ -n "${!v}" ] || { echo "error: $v 파싱 실패 — 업스트림 서식이 바뀌었는지 확인" >&2; exit 1; }
done

emit old_version "$old_ver"
emit new_version "$new_ver"

# 문자열 비교가 아니라 버전 비교(9.9.0 < 9.10.0). 다운그레이드나 동일이면 아무것도 안 한다.
#   builtins.compareVersions 가 아니라 sort -V 인 이유: 이 스크립트가 nix 를 안 부르면 워크플로가
#   nix 설치를 "실제 범프가 있는 주"로 미룰 수 있다(대부분의 주는 no-op 인데 nix 부트스트랩만 하고 끝났음).
#   정렬 결과의 마지막이 old 면 old >= new.
if [ "$(printf '%s\n%s\n' "$old_ver" "$new_ver" | sort -V | tail -n1)" = "$old_ver" ]; then
  echo "이미 최신: $old_ver (upstream $new_ver)"
  emit updated false
  exit 0
fi

# base64 는 / + = 를 포함할 수 있어 sed 구분자로 | 를 쓴다(base64 알파벳에 없음).
sed -i -E \
  -e "s|^  version = \".*\";$|  version = \"$new_ver\";|" \
  -e "s|^    hash = \"sha512-.*\";$|    hash = \"sha512-$new_hash\";|" \
  "$PKG"

echo "갱신: $old_ver -> $new_ver"
emit updated true
