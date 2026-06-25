#!/usr/bin/env bash
#
# Update the fixed-output vendor hash of Caddy packages built via
# pkgs.caddy.withPlugins (declared in ./default.nix).
#
# 镜像 scripts/update-go-vendorHash.sh。唯一的区别在目标发现：gomod2nix 派生
# 会暴露 `goModules` 属性用于过滤，而 caddy.withPlugins 派生没有这样的标记，
# 因此目标属性名在下方 `caddy_targets` 中显式列出。
#
# 每个目标必须以字面量形式声明 hash（与 codex/kwok 约定一致），这样本脚本才能
# 用 `rg -F` 定位并就地改写。
#
# 用法:
#   scripts/update-caddy-hash.sh                         # 更新全部 caddy_targets
#   scripts/update-caddy-hash.sh :caddy-with-plugins:   # 仅更新指定目标
#   CADDYHASH_TARGETS=:caddy-with-plugins: scripts/update-caddy-hash.sh

set -euo pipefail

# 通过 pkgs.caddy.withPlugins 构建、且在 ./default.nix 中导出的派生属性名。
# 其插件集合会被 vendor 进 fixed-output `src` 派生。新增 caddy 变体时在此追加。
caddy_targets=( caddy-with-plugins )

target_list="${1:-${CADDYHASH_TARGETS:-}}"

contains_target() {
  local target="$1"
  # target_list 为空表示“caddy_targets 中的每一项”
  [[ -z "$target_list" || "$target_list" == *":${target}:"* ]]
}

selected_derivations=()
for DERIVATION_NAME in "${caddy_targets[@]}"; do
  if contains_target "$DERIVATION_NAME"; then
    selected_derivations+=("${DERIVATION_NAME}")
  fi
done

if [ "${#selected_derivations[@]}" -eq 0 ]; then
  echo "no caddy hash targets selected"
  exit 0
fi

sed_replacements=()
replace_files=()
need_rebuild=()

for DERIVATION_NAME in "${selected_derivations[@]}"; do
  if ! output="$(nix-build -E "
 let
  pkgs = (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [
        (import \"\${fetchTree gomod2nix.locked}/overlay.nix\")
      ];
      config.allowUnfree = true;
    }
  );
  attrs = pkgs.callPackage ./default.nix {};
in attrs.$DERIVATION_NAME
" 2>&1 | tee /dev/stderr)"; then
    specified=$(echo "$output" | awk -F: '$1~/specified/{print $2}' | xargs)
    got=$(echo "$output" | awk -F: '$1~/got/{print $2}' | xargs)
    if [ -n "$specified" -a -n "$got" ]; then
      echo "hash replacement detected. searching for hashes: $specified -> $got"
      while IFS= read -r ENTRY; do
        [ -n "$ENTRY" ] && replace_files+=("$ENTRY")
      done < <(rg -l -F "$specified" --glob '*.nix' .)
      sed_replacements=("${sed_replacements[@]}" "$specified" "$got")
      need_rebuild=("${need_rebuild[@]}" "${DERIVATION_NAME}")
    fi
  fi
done

if [ "${#sed_replacements[@]}" -eq 0 ]; then
  echo "nothing to be replaced"
  exit
fi

if [ "${#replace_files[@]}" -eq 0 ]; then
  echo "no nix files matched the old hash"
  exit 1
fi

mapfile -t replace_files < <(printf '%s\n' "${replace_files[@]}" | sort -u)

for ENTRY in "${replace_files[@]}"; do
  for ((i = 0; i < ${#sed_replacements[@]}; i += 2)); do
    sed -i "s,${sed_replacements[i]},${sed_replacements[i + 1]},g" "$ENTRY"
  done
done

for DERIVATION_NAME in "${need_rebuild[@]}"; do
  nix-build -E "
   let
    pkgs = (
      let
        inherit (builtins) fetchTree fromJSON readFile;
        inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
      in
      import (fetchTree nixpkgs.locked) {
        overlays = [
          (import \"\${fetchTree gomod2nix.locked}/overlay.nix\")
        ];
        config.allowUnfree = true;
      }
    );
    attrs = pkgs.callPackage ./default.nix {};
  in attrs.$DERIVATION_NAME
  "
done
