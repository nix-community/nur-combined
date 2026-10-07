#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix nix-update common-updater-scripts gnused
set -euo pipefail
file="$(dirname $0)/default.nix"
cd "$(dirname $0)/../.."
: "${UPDATE_NIX_ATTR_PATH:=llama-cpp-toshllm}"
# Update the ToshLLM patchset…
nix-update "${UPDATE_NIX_ATTR_PATH}._pkgForUpdater" --src-only
# Then find out what version of llama.cpp it's based on…
toshllmSrc="$(nix-build -A "${UPDATE_NIX_ATTR_PATH}.toshllmSrc" --no-out-link)"
llamaCppRev="$(sed -En '/^LLAMA_COMMIT=/ { s@^.*:-([a-z0-9]+)}.*$@\1@; p; q; }' "${toshllmSrc}/scripts/build-engines.sh")"
sed -Ei 's@(^ *llama-cpp-rev = )".*";@\1"'"$llamaCppRev"'";@' "$file"
# Then update the hash for that…
nix-update "${UPDATE_NIX_ATTR_PATH}" --src-only --version=skip
# And finally update npmDeps hash
nix-update "${UPDATE_NIX_ATTR_PATH}" --no-src --version=skip
