#!/usr/bin/env bash
# UpNote 갱신기. snap store API 를 폴링해 default.nix 의 version/revision/hash 세 값을 갱신한다.
#
# 왜 snap 인가(소스 자체의 근거는 default.nix 상단 주석 참조): deb 는 버전 없는 롤링 URL 이라
#   업스트림이 파일을 갈아치우면 옛 해시에 묶인 소비자가 재빌드할 방법이 사라졌다. snap 은 URL 에
#   리비전이 박히고 과거 리비전이 남아 있어 그 창이 없다. 그 성질이 이 스크립트의 위상도 바꾼다 —
#   **갱신이 늦어도 다운스트림이 깨지지 않으므로**, 이 폴링은 이제 고장 방지가 아니라 단순 최신화다.
#
# 단일 진실원천: https://api.snapcraft.io/v2/snaps/info/upnote (stable/amd64 채널맵).
#   version + revision + download.url + download.sha3-384 을 준다.
#   ⚠️ nix 는 sha3 을 모른다 → 파일을 받아 sha256(SRI)을 직접 만든다. 대신 받은 바이트가 정말
#     스토어가 말한 것인지 sha3-384 로 먼저 대조한다(deb 시절엔 없던 무결성 관문이다).
#
# 로컬 수동 실행도 지원한다(인자 없음). CI 에서는 GITHUB_OUTPUT 에 결과를 실어 후속 스텝이 분기한다.
#   exit 0 + updated=false → 이미 최신(할 일 없음)
#   exit 0 + updated=true  → default.nix 가 수정됨
#   exit >0                → 조회/파싱/검증 실패(호출 측에서 실패로 취급)
set -euo pipefail

readonly API="https://api.snapcraft.io/v2/snaps/info/upnote?fields=version,revision,download"
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

# Snap-Device-Series 헤더가 없으면 API 가 거절한다(스토어가 클라이언트 시리즈를 요구).
info=$(curl -fsSL --retry 3 --retry-delay 5 \
  -H "Snap-Device-Series: 16" -H "Snap-Device-Architecture: amd64" "$API") \
  || { echo "error: snap API 조회 실패" >&2; exit 1; }

# 채널맵에는 채널×아키텍처 조합이 여러 개 들어온다. stable/amd64 하나만 집는다.
read -r new_ver new_rev url sha3 < <(jq -r '
  .["channel-map"][]
  | select(.channel.name == "stable" and .channel.architecture == "amd64")
  | [.version, (.revision|tostring), .download.url, .download["sha3-384"]] | @tsv' <<<"$info" | head -1)

old_ver=$(sed -nE 's/^  version = "(.+)";$/\1/p' "$PKG")
old_rev=$(sed -nE 's/^  revision = "(.+)";$/\1/p' "$PKG")

for v in new_ver new_rev url sha3 old_ver old_rev; do
  [ -n "${!v}" ] || { echo "error: $v 파싱 실패 — API 응답이나 default.nix 서식을 확인" >&2; exit 1; }
done

emit old_version "$old_ver"
emit new_version "$new_ver"
emit old_revision "$old_rev"
emit new_revision "$new_rev"

# 리비전은 스토어가 매기는 단조 증가 정수라 비교가 명확하다(버전 문자열보다 낫다 — 같은 버전으로
#   다시 올라온 리비전도 잡아낸다). 같으면 할 일이 없고, 낮으면 채널 롤백이므로 자동으로 되돌리지
#   않고 사람이 판단하게 남긴다.
if [ "$new_rev" -eq "$old_rev" ]; then
  echo "이미 최신: rev $old_rev ($old_ver)"
  emit updated false
  exit 0
fi
if [ "$new_rev" -lt "$old_rev" ]; then
  echo "warn: stable 채널이 rev $old_rev -> $new_rev 로 내려갔다(롤백?). 자동 갱신하지 않는다." >&2
  emit updated false
  exit 0
fi

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo "내려받는 중: rev $new_rev ($new_ver)"
curl -fsSL --retry 3 --retry-delay 5 -o "$tmp/upnote.snap" "$url" \
  || { echo "error: snap 내려받기 실패: $url" >&2; exit 1; }

got_sha3=$(openssl dgst -sha3-384 -hex "$tmp/upnote.snap" | awk '{print $NF}')
if [ "$got_sha3" != "$sha3" ]; then
  echo "error: sha3-384 불일치 — 받은 바이트가 스토어가 말한 것과 다르다" >&2
  echo "  기대: $sha3" >&2
  echo "  실제: $got_sha3" >&2
  exit 1
fi

new_hash="sha256-$(openssl dgst -sha256 -binary "$tmp/upnote.snap" | openssl base64 -A)"

# base64 는 / + = 를 포함할 수 있어 sed 구분자로 | 를 쓴다(base64 알파벳에 없음).
sed -i -E \
  -e "s|^  version = \".*\";$|  version = \"$new_ver\";|" \
  -e "s|^  revision = \".*\";$|  revision = \"$new_rev\";|" \
  -e "s|^    hash = \"sha256-.*\";$|    hash = \"$new_hash\";|" \
  "$PKG"

echo "갱신: $old_ver (rev $old_rev) -> $new_ver (rev $new_rev)"
emit updated true
