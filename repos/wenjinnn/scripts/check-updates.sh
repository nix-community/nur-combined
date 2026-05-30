#!/usr/bin/env bash
# Script to check for upstream version updates of packages
# Usage: ./check-updates.sh [--json]
#
# Checks for new versions of:
# - lemminx-maven (Eclipse repository)
# - pi-acp (GitHub)
# - pi-packages (multiple GitHub/npm packages)

set -euo pipefail

JSON_OUTPUT=false
if [[ "${1:-}" == "--json" ]]; then
  JSON_OUTPUT=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any updates found
UPDATES_FOUND=false
UPDATE_RESULTS=()

# Function to extract current version from nix file
get_current_version() {
  local file="$1"
  local pattern="$2"
  grep -oP "$pattern" "$file" | head -1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+'
}

# Function to get latest GitHub release
get_github_latest_release() {
  local owner="$1"
  local repo="$2"
  curl -sL "https://api.github.com/repos/${owner}/${repo}/releases/latest" | jq -r '.tag_name // empty' | sed 's/^v//'
}

# Function to get latest GitHub tag
get_github_latest_tag() {
  local owner="$1"
  local repo="$2"
  curl -sL "https://api.github.com/repos/${owner}/${repo}/tags?per_page=1" | jq -r '.[0].name // empty' | sed 's/^v//'
}

# Function to check npm package latest version
get_npm_latest_version() {
  local package="$1"
  curl -sL "https://registry.npmjs.org/${package}/latest" | jq -r '.version // empty'
}

# Function to compare versions
version_gt() {
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# Function to report update
report_update() {
  local package="$1"
  local current="$2"
  local latest="$3"
  local source="$4"

  UPDATES_FOUND=true

  if $JSON_OUTPUT; then
    UPDATE_RESULTS+=("{\"package\":\"${package}\",\"current\":\"${current}\",\"latest\":\"${latest}\",\"source\":\"${source}\"}")
  else
    echo -e "${YELLOW}⬆ Update available:${NC} ${package}"
    echo -e "  Current: ${RED}${current}${NC}"
    echo -e "  Latest:  ${GREEN}${latest}${NC}"
    echo -e "  Source:  ${source}"
    echo ""
  fi
}

# Function to report no update
report_up_to_date() {
  local package="$1"
  local current="$2"

  if ! $JSON_OUTPUT; then
    echo -e "${GREEN}✓ Up to date:${NC} ${package} (${current})"
  fi
}

echo "Checking for upstream version updates..."
echo "========================================"
echo ""

# ── Check lemminx-maven ──────────────────────────────────────────────────────
echo "Checking lemminx-maven..."
LEMMINX_FILE="${REPO_ROOT}/pkgs/lemminx-maven/default.nix"

if [[ -f "$LEMMINX_FILE" ]]; then
  CURRENT_LEMMINX=$(get_current_version "$LEMMINX_FILE" 'version = "[0-9]+\.[0-9]+\.[0-9]+"')

  if [[ -n "$CURRENT_LEMMINX" ]]; then
    # Check Eclipse repository for latest version
    # Try GitHub first as it's easier to query
    LATEST_LEMMINX=$(get_github_latest_release "eclipse-lemminx" "lemminx-maven")

    # Fallback: check Maven metadata if GitHub fails
    if [[ -z "$LATEST_LEMMINX" ]]; then
      LATEST_LEMMINX=$(curl -sL "https://repo.eclipse.org/content/repositories/lemminx-releases/org/eclipse/lemminx/lemminx-maven/maven-metadata.xml" | grep -oP '<latest>\K[0-9]+\.[0-9]+\.[0-9]+' || true)
    fi

    if [[ -n "$LATEST_LEMMINX" ]]; then
      if version_gt "$LATEST_LEMMINX" "$CURRENT_LEMMINX"; then
        report_update "lemminx-maven" "$CURRENT_LEMMINX" "$LATEST_LEMMINX" "https://github.com/eclipse-lemminx/lemminx-maven"
      else
        report_up_to_date "lemminx-maven" "$CURRENT_LEMMINX"
      fi
    else
      echo -e "${RED}✗ Could not fetch latest version for lemminx-maven${NC}"
    fi
  else
    echo -e "${RED}✗ Could not parse current version from ${LEMMINX_FILE}${NC}"
  fi
else
  echo -e "${RED}✗ File not found: ${LEMMINX_FILE}${NC}"
fi

echo ""

# ── Check pi-acp ─────────────────────────────────────────────────────────────
echo "Checking pi-acp..."
PIACP_FILE="${REPO_ROOT}/pkgs/pi-acp/default.nix"

if [[ -f "$PIACP_FILE" ]]; then
  CURRENT_PIACP=$(get_current_version "$PIACP_FILE" 'version = "[0-9]+\.[0-9]+\.[0-9]+"')

  if [[ -n "$CURRENT_PIACP" ]]; then
    LATEST_PIACP=$(get_github_latest_release "svkozak" "pi-acp")

    if [[ -n "$LATEST_PIACP" ]]; then
      if version_gt "$LATEST_PIACP" "$CURRENT_PIACP"; then
        report_update "pi-acp" "$CURRENT_PIACP" "$LATEST_PIACP" "https://github.com/svkozak/pi-acp"
      else
        report_up_to_date "pi-acp" "$CURRENT_PIACP"
      fi
    else
      echo -e "${RED}✗ Could not fetch latest version for pi-acp${NC}"
    fi
  else
    echo -e "${RED}✗ Could not parse current version from ${PIACP_FILE}${NC}"
  fi
else
  echo -e "${RED}✗ File not found: ${PIACP_FILE}${NC}"
fi

echo ""

# ── Check pi-packages ────────────────────────────────────────────────────────
echo "Checking pi-packages..."
PIPACKAGES_FILE="${REPO_ROOT}/pkgs/pi-packages/default.nix"

if [[ -f "$PIPACKAGES_FILE" ]]; then
  # Define packages to check with their GitHub sources
  declare -A PACKAGE_SOURCES=(
    ["pi-mcp-adapter"]="nicobailon/pi-mcp-adapter"
    ["pi-web-access"]="nicobailon/pi-web-access"
    ["pi-hermes-memory"]="chandra447/pi-hermes-memory"
    ["@gotgenes/pi-subagents"]="gotgenes/pi-packages"
    ["@gotgenes/pi-permission-system"]="gotgenes/pi-packages"
    ["@gotgenes/pi-permission-system"]="gotgenes/pi-packages"
    ["@juicesharp/rpiv-ask-user-question"]="juicesharp/rpiv-mono"
    ["@juicesharp/rpiv-btw"]="juicesharp/rpiv-mono"
    ["@juicesharp/rpiv-todo"]="juicesharp/rpiv-mono"
    ["@plannotator/pi-extension"]="backnotprop/plannotator"
    ["@llblab/pi-telegram"]="llblab/pi-telegram"
    ["@tmustier/pi-usage-extension"]="tmustier/pi-usage-extension"
    ["pi-permission-system"]="MasuRii/pi-permission-system"
  )

  for package in "${!PACKAGE_SOURCES[@]}"; do
    source_repo="${PACKAGE_SOURCES[$package]}"
    owner="${source_repo%%/*}"
    repo="${source_repo##*/}"

    # Use awk to find the package block and extract version on next line
    CURRENT_VERSION=$(awk -v pkg="$package" '
      $0 ~ "\x22" pkg "\x22" { found=1 }
      found && /version =/ {
        match($0, /[0-9]+\.[0-9]+\.[0-9]+/)
        if (RSTART > 0) {
          print substr($0, RSTART, RLENGTH)
          exit
        }
      }
    ' "$PIPACKAGES_FILE" || true)

    if [[ -z "$CURRENT_VERSION" ]]; then
      echo -e "${YELLOW}? Could not parse version for ${package}${NC}"
      continue
    fi

    # Try npm first for npm packages
    LATEST_VERSION=$(get_npm_latest_version "$package")

    # Fallback to GitHub
    if [[ -z "$LATEST_VERSION" ]] || [[ "$LATEST_VERSION" == "null" ]]; then
      LATEST_VERSION=$(get_github_latest_release "$owner" "$repo")
    fi

    # Try GitHub tags if release not found
    if [[ -z "$LATEST_VERSION" ]]; then
      LATEST_VERSION=$(get_github_latest_tag "$owner" "$repo")
    fi

    if [[ -n "$LATEST_VERSION" ]]; then
      if version_gt "$LATEST_VERSION" "$CURRENT_VERSION"; then
        report_update "$package" "$CURRENT_VERSION" "$LATEST_VERSION" "https://github.com/${source_repo}"
      else
        report_up_to_date "$package" "$CURRENT_VERSION"
      fi
    else
      echo -e "${RED}✗ Could not fetch latest version for ${package}${NC}"
    fi
  done
else
  echo -e "${RED}✗ File not found: ${PIPACKAGES_FILE}${NC}"
fi

echo ""
echo "========================================"

# Output results
if $JSON_OUTPUT; then
  echo "["
  for i in "${!UPDATE_RESULTS[@]}"; do
    if [[ $i -gt 0 ]]; then
      echo ","
    fi
    echo -n "  ${UPDATE_RESULTS[$i]}"
  done
  echo ""
  echo "]"
else
  if $UPDATES_FOUND; then
    echo -e "${YELLOW}⬆ Updates available for one or more packages!${NC}"
    exit 1
  else
    echo -e "${GREEN}✓ All packages are up to date!${NC}"
    exit 0
  fi
fi
