#!/usr/bin/env bash
set -euo pipefail

SYSTEM="${SYSTEM:-x86_64-linux}"
BLACKLIST=(
  "packages.${SYSTEM}.yaziPlugins.ucp"
)

list_derivations() {
  local attrset=$1

  nix eval --raw ".#${attrset}" \
    --apply 'pkgs: builtins.concatStringsSep "\n" (builtins.filter (name: let v = builtins.getAttr name pkgs; in builtins.isAttrs v && v ? type && v.type == "derivation") (builtins.attrNames pkgs))'
}

is_blacklisted() {
  local attr_path=$1

  for blocked in "${BLACKLIST[@]}"; do
    if [ "${attr_path}" = "${blocked}" ]; then
      return 0
    fi
  done
  return 1
}

run_updates() {
  local attrset=$1
  local -a attrs=()

  mapfile -t attrs < <(list_derivations "${attrset}")

  for attr in "${attrs[@]}"; do
    local attr_path="${attrset}.${attr}"
    if is_blacklisted "${attr_path}"; then
      continue
    fi
    nix run nixpkgs#nix-update -- --flake --use-github-releases --version=stable "${attr_path}" || true
  done
}

run_updates "packages.${SYSTEM}"
run_updates "packages.${SYSTEM}.yaziPlugins"
