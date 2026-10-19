#!/usr/bin/env bash
# Invoked by the flake app with KERNEL_FLAKE pinned to that app's source tree.
set -euo pipefail

usage() {
  echo 'Usage: build-and-cache-kernel [--build-only] [--cores N] [--token-file PATH]'
  echo 'Token: automatically detected in sops-nix secrets; environment/file overrides supported.'
  echo 'Builds this flake revision, without activating or installing the kernel.'
}

find_sops_token() {
  local root name
  local -a roots
  if [[ -n "${CACHIX_SOPS_SECRETS_DIR:-}" ]]; then
    roots=("$CACHIX_SOPS_SECRETS_DIR")
  else
    roots=(/run/secrets)
    if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
      roots+=("$XDG_RUNTIME_DIR/secrets")
    fi
    roots+=("${XDG_CONFIG_HOME:-$HOME/.config}/sops-nix/secrets")
  fi
  # Only known Cachix names; never read unrelated secrets or decrypt a whole vault.
  for root in "${roots[@]}"; do
    for name in cachix_auth_token uriotv_cachix_auth_token cachix_token CACHIX_AUTH_TOKEN cachix/auth_token cachix; do
      if [[ -f "$root/$name" && -r "$root/$name" && -s "$root/$name" ]]; then
        printf '%s\n' "$root/$name"
        return 0
      fi
    done
  done
  return 1
}

build_only=false
cores="$(nproc)"
token_file="${CACHIX_AUTH_TOKEN_FILE:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only) build_only=true; shift ;;
    --cores|--token-file)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      case "$1" in
        --cores) cores="$2" ;;
        --token-file) token_file="$2" ;;
      esac
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
[[ "$cores" =~ ^[1-9][0-9]*$ ]] || { echo 'Invalid --cores value' >&2; exit 2; }
: "${KERNEL_FLAKE:?Run this script through nix run .#build-and-cache-kernel}"

if ! "$build_only"; then
  if [[ -z "$token_file" && -z "${CACHIX_AUTH_TOKEN:-}" ]]; then
    token_file="$(find_sops_token)" || true
  fi
  if [[ -n "$token_file" ]]; then
    [[ -r "$token_file" ]] || { echo 'Cannot read Cachix token file' >&2; exit 1; }
    CACHIX_AUTH_TOKEN="$(< "$token_file")"
  fi
  [[ -n "${CACHIX_AUTH_TOKEN:-}" ]] || {
    echo 'No readable Cachix token found in sops-nix secrets. Provision cachix_auth_token (readable by your user), or use --token-file PATH / --build-only.' >&2
    exit 1
  }
  export CACHIX_AUTH_TOKEN
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
installable="${KERNEL_FLAKE}#packages.x86_64-linux.linux-cachyos-bore-x86_64-v3"
echo "Building CachyOS BORE v3 with ${cores} cores (one Nix build job)."
# Never put write credentials into the kernel builder environment. Only the
# later cachix invocation needs them. nproc controls parallelism, NOT CPU tuning.
env -u CACHIX_AUTH_TOKEN -u CACHIX_AUTH_TOKEN_FILE -u CACHIX_SOPS_SECRETS_DIR nix build \
  --no-write-lock-file --no-link --json --max-jobs 1 --cores "$cores" \
  "${installable}^*" "${installable}.src" "${installable}.urioUpstreamSource" \
  > "$work/build.json"
jq -r '.[].outputs[]' "$work/build.json" | sort -u > "$work/paths"
[[ -s "$work/paths" ]] || { echo 'Build returned no outputs' >&2; exit 1; }
while IFS= read -r path; do
  du -sh "$path"
done < "$work/paths"

if "$build_only"; then
  echo 'Build complete; no publication or system activation performed.'
  exit 0
fi

cachix push uriotv < "$work/paths"
while IFS= read -r path; do
  hash="${path#/nix/store/}"
  hash="${hash%%-*}"
  curl --fail --silent --show-error --retry 5 --retry-all-errors \
    "https://uriotv.cachix.org/${hash}.narinfo" > "$work/output.narinfo"
  grep -Fx "StorePath: $path" "$work/output.narinfo"
done < "$work/paths"
echo 'All outputs published and verified on uriotv.cachix.org; system unchanged.'
