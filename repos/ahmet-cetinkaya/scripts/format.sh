#!/usr/bin/env bash

set -euo pipefail

print_section() {
  local title="$1"
  echo
  echo "----- ${title} -----"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

find_repo_files() {
  find . \
    \( \
    -path "./.git" -o \
    -path "./agent-ctrl" -o \
    -path "./_archived" -o \
    -path "./claude-code" -o \
    -path "./claude-code.bak" -o \
    -path "./konsave" -o \
    -path "./quickshell" -o \
    -path "./zsh/zsh-autosuggestions" -o \
    -path "./zsh/zsh-syntax-highlighting" \
    \) -prune -o "$@" -print0
}

has_tool() {
  command -v "$1" > /dev/null 2>&1
}

run_formatter() {
  local name="$1"
  local tool="$2"
  shift 2

  local files=()
  mapfile -d '' -t files < <(find_repo_files "$@")
  if [ "${#files[@]}" -eq 0 ]; then
    return 0
  fi

  if ! has_tool "${tool}"; then
    echo "[skip] ${name}: '${tool}' not found (${#files[@]} files)"
    return 0
  fi

  print_section "${name}"
  local clean_name="${name//[^a-zA-Z0-9\/\-\/ _]}"
  echo "[run]  ${clean_name}: ${#files[@]} files"

  case "${name}" in
    "Shell")
      printf '%s\0' "${files[@]}" | xargs -0 shfmt -w -i 2 -ci -sr
      ;;
    "Nix")
      printf '%s\0' "${files[@]}" | xargs -0 alejandra
      ;;
    "Lua")
      printf '%s\0' "${files[@]}" | xargs -0 stylua
      ;;
    "JSON/CSS/YAML")
      printf '%s\0' "${files[@]}" | xargs -0 prettier --write --log-level warn
      ;;
    "JSONC")
      printf '%s\0' "${files[@]}" | xargs -0 prettier --write --log-level warn --trailing-comma none
      ;;
    "TOML")
      printf '%s\0' "${files[@]}" | xargs -0 taplo format
      ;;
  esac
}

trim_trailing_whitespace() {
  local files=()
  mapfile -d '' -t files < <(
    find_repo_files -type f \( -name "*.conf" -o -name "*.rasi" \)
  )

  if [ "${#files[@]}" -eq 0 ]; then
    return 0
  fi

  if ! has_tool python3; then
    echo "[skip] conf/rasi cleanup: 'python3' not found (${#files[@]} files)"
    return 0
  fi

  print_section "🧹 conf/rasi cleanup"
  echo "[run]  conf/rasi cleanup: ${#files[@]} files"

  local file
  for file in "${files[@]}"; do
    python3 - "${file}" << 'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
content = path.read_text(encoding="utf-8")
lines = [line.rstrip() for line in content.splitlines()]
formatted = "\n".join(lines) + "\n"
if content != formatted:
    path.write_text(formatted, encoding="utf-8")
PY
  done
}

normalize_toml_inline_comments() {
  local files=()
  mapfile -d '' -t files < <(find_repo_files -type f -name "*.toml")

  if [ "${#files[@]}" -eq 0 ]; then
    return 0
  fi

  if ! has_tool python3; then
    echo "[skip] toml comment spacing: 'python3' not found (${#files[@]} files)"
    return 0
  fi

  print_section "💬 toml comment spacing"
  echo "[run]  toml comment spacing: ${#files[@]} files"

  local file
  for file in "${files[@]}"; do
    python3 - "${file}" << 'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
content = path.read_text(encoding="utf-8")

# Keep exactly one space before inline comments ("key = value # comment").
# This avoids Taplo's alignment-style spacing while preserving full-line comments.
formatted = re.sub(r"(\S)\s{2,}#", r"\1 #", content)

if content != formatted:
    path.write_text(formatted, encoding="utf-8")
PY
  done
}

run_formatter "🐚 Shell" shfmt -type f -name "*.sh"
run_formatter "❄️ Nix" alejandra -type f -name "*.nix"
run_formatter "🌙 Lua" stylua -type f -name "*.lua"
run_formatter "📄 JSON/CSS/YAML" prettier -type f \
  \( \
  -name "*.json" -o \
  -name "*.css" -o \
  -name "*.yml" -o \
  -name "*.yaml" \
  \) \
  ! -name "flake.lock" \
  ! -name "lazy-lock.json"
run_formatter "📋 JSONC" prettier -type f -name "*.jsonc"
run_formatter "📦 TOML" taplo -type f -name "*.toml"
normalize_toml_inline_comments
trim_trailing_whitespace

echo "Formatting completed."
