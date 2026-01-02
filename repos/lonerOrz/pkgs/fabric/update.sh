#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# 基本信息
# -----------------------------------------------------------------------------
owner="Fabric-Development"
repo="fabric"
pname="fabric"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/default.nix"

dummy_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

CURRENT_STAGE=""
ROLLBACK_NEEDED=0

# -----------------------------------------------------------------------------
# 回滚逻辑（统一出口）
# -----------------------------------------------------------------------------
rollback() {
  [[ "$ROLLBACK_NEEDED" != "1" ]] && return

  echo "⚠️  Rolling back (stage=$CURRENT_STAGE)"

  case "$CURRENT_STAGE" in
    pygobject)
      sed -i -E \
        's|(pygobject_hash\s*=\s*")[^"]+(")|\1'"$OLD_PYGOBJECT_HASH"'\2|' \
        "$package_file"
      ;;
    src)
      sed -i -E \
        's|(rev\s*=\s*")[^"]+(")|\1'"$OLD_REV"'\2|' \
        "$package_file"
      sed -i -E \
        's|(src_hash\s*=\s*")[^"]+(")|\1'"$OLD_SRC_HASH"'\2|' \
        "$package_file"
      ;;
    version)
      awk -v pname="$pname" -v old="$OLD_VERSION" '
        $0 ~ "pname\\s*=\\s*\"" pname "\"" { in_pkg=1 }
        in_pkg && /version\s*=/ && !done {
          sub(/version\s*=\s*"[^"]+"/, "version = \"" old "\"")
          done=1
        }
        { print }
      ' "$package_file" > "$package_file.tmp" && mv "$package_file.tmp" "$package_file"
      ;;
  esac

  echo "Rollback finished."
}

trap rollback ERR EXIT

# -----------------------------------------------------------------------------
# upstream 检查
# -----------------------------------------------------------------------------
latest_rev=$(git ls-remote "https://github.com/$owner/$repo.git" HEAD | cut -f1)
current_rev=$(grep -oP 'rev\s*=\s*"\K[0-9a-f]+' "$package_file" | head -n1)

if [[ "$latest_rev" == "$current_rev" ]]; then
  echo "✅ Already up to date."
  exit 0
fi

# -----------------------------------------------------------------------------
# 1️⃣ pygobject_hash（不动 version / rev）
# -----------------------------------------------------------------------------
CURRENT_STAGE="pygobject"
ROLLBACK_NEEDED=1

OLD_PYGOBJECT_HASH=$(grep -oP 'pygobject_hash\s*=\s*"\K[^"]+' "$package_file")

sed -i -E \
  's|(pygobject_hash\s*=\s*")[^"]+(")|\1'"$dummy_hash"'\2|' \
  "$package_file"

output=$(nix build "$script_dir/../.."#$pname 2>&1 || true)
NEW_PYGOBJECT_HASH=$(echo "$output" | grep 'got:' | head -n1 | grep -oP 'sha256-[A-Za-z0-9+/=]+')

[[ -n "$NEW_PYGOBJECT_HASH" ]]

sed -i -E \
  's|(pygobject_hash\s*=\s*")[^"]+(")|\1'"$NEW_PYGOBJECT_HASH"'\2|' \
  "$package_file"

echo "✅ pygobject_hash updated"

# -----------------------------------------------------------------------------
# 2️⃣ rev + src_hash
# -----------------------------------------------------------------------------
CURRENT_STAGE="src"

OLD_REV="$current_rev"
OLD_SRC_HASH=$(grep -oP 'src_hash\s*=\s*"\K[^"]+' "$package_file")

sed -i -E \
  's|(rev\s*=\s*")[^"]+(")|\1'"$latest_rev"'\2|' \
  "$package_file"

sed -i -E \
  's|(src_hash\s*=\s*")[^"]+(")|\1'"$dummy_hash"'\2|' \
  "$package_file"

output=$(nix build "$script_dir/../.."#$pname 2>&1 || true)
NEW_SRC_HASH=$(echo "$output" | grep 'got:' | head -n1 | grep -oP 'sha256-[A-Za-z0-9+/=]+')

[[ -n "$NEW_SRC_HASH" ]]

sed -i -E \
  's|(src_hash\s*=\s*")[^"]+(")|\1'"$NEW_SRC_HASH"'\2|' \
  "$package_file"

echo "✅ src updated"

# -----------------------------------------------------------------------------
# 3️⃣ 精确更新包本体 version（基于 pname 锚定）
# -----------------------------------------------------------------------------
CURRENT_STAGE="version"

OLD_VERSION=$(
  awk -v pname="$pname" '
    $0 ~ "pname\\s*=\\s*\"" pname "\"" { in_pkg=1 }
    in_pkg && /version\s*=/ {
      match($0, /"([^"]+)"/, m)
      print m[1]
      exit
    }
  ' "$package_file"
)

NEW_VERSION="$OLD_VERSION"  # 如需 bump，可在此计算

awk -v pname="$pname" -v new="$NEW_VERSION" '
  $0 ~ "pname\\s*=\\s*\"" pname "\"" { in_pkg=1 }
  in_pkg && /version\s*=/ && !done {
    sub(/version\s*=\s*"[^"]+"/, "version = \"" new "\"")
    done=1
  }
  { print }
' "$package_file" > "$package_file.tmp" && mv "$package_file.tmp" "$package_file"

echo "✅ version updated: $OLD_VERSION -> $NEW_VERSION"

# -----------------------------------------------------------------------------
# 成功，解除回滚
# -----------------------------------------------------------------------------
ROLLBACK_NEEDED=0
trap - ERR EXIT

echo "🎉 Update finished cleanly."
