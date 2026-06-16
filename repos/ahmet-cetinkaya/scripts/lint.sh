#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

print_section() {
  local title="$1"
  echo
  echo "----- ${title} -----"
}

find_repo_files() {
  find ./arch ./hyprland ./nixos ./scripts "$@" -print0
}

print_section "🐚 Shell lint"
shell_files=()
mapfile -d '' -t shell_files < <(find_repo_files -type f -name "*.sh")
if [ "${#shell_files[@]}" -gt 0 ]; then
  echo "[run]  Checking ${#shell_files[@]} shell files with shellcheck"
  shellcheck "${shell_files[@]}"
fi

print_section "❄️ Nix flake check"
echo "[run]  Formatting Nix files with alejandra"
alejandra ./nixos
echo "[run]  Checking Nix files with statix"
statix check ./nixos
echo "[run]  Scanning for dead code with deadnix"
deadnix ./nixos
echo "[run]  Validating flake with nix"
nix flake check ./nixos
