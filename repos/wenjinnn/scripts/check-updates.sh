#!/usr/bin/env bash
# Script to check for upstream version updates of packages
# Usage: ./check-updates.sh [--json]
#
# Checks for new versions of:
# - lemminx-maven (Eclipse repository)
# - pi-acp (GitHub)
# - pi-web (GitHub)

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
CHECK_ERRORS=false
UPDATE_RESULTS=()

say() {
	if ! $JSON_OUTPUT; then
		echo -e "$@"
	fi
}

report_error() {
	CHECK_ERRORS=true
	say "$@"
}

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
	curl -fsSL "https://api.github.com/repos/${owner}/${repo}/releases/latest" 2>/dev/null | jq -r '.tag_name // empty' | sed 's/^v//' || true
}

# Function to get latest GitHub tag
get_github_latest_tag() {
	local owner="$1"
	local repo="$2"
	curl -fsSL "https://api.github.com/repos/${owner}/${repo}/tags?per_page=1" 2>/dev/null | jq -r '.[0].name // empty' | sed 's/^v//' || true
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
		UPDATE_RESULTS+=("$(jq -cn --arg package "$package" --arg current "$current" --arg latest "$latest" --arg source "$source" '{package: $package, current: $current, latest: $latest, source: $source}')")
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

say "Checking for upstream version updates..."
say "========================================"
say ""

# ── Check lemminx-maven ──────────────────────────────────────────────────────
say "Checking lemminx-maven..."
LEMMINX_FILE="${REPO_ROOT}/pkgs/lemminx-maven/default.nix"

if [[ -f "$LEMMINX_FILE" ]]; then
	CURRENT_LEMMINX=$(get_current_version "$LEMMINX_FILE" 'version = "[0-9]+\.[0-9]+\.[0-9]+"' || true)

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
			report_error "${RED}✗ Could not fetch latest version for lemminx-maven${NC}"
		fi
	else
		report_error "${RED}✗ Could not parse current version from ${LEMMINX_FILE}${NC}"
	fi
else
	report_error "${RED}✗ File not found: ${LEMMINX_FILE}${NC}"
fi

say ""

# ── Check pi-acp ─────────────────────────────────────────────────────────────
say "Checking pi-acp..."
PIACP_FILE="${REPO_ROOT}/pkgs/pi-acp/default.nix"

if [[ -f "$PIACP_FILE" ]]; then
	CURRENT_PIACP=$(get_current_version "$PIACP_FILE" 'version = "[0-9]+\.[0-9]+\.[0-9]+"' || true)

	if [[ -n "$CURRENT_PIACP" ]]; then
		LATEST_PIACP=$(get_github_latest_release "svkozak" "pi-acp")

		if [[ -n "$LATEST_PIACP" ]]; then
			if version_gt "$LATEST_PIACP" "$CURRENT_PIACP"; then
				report_update "pi-acp" "$CURRENT_PIACP" "$LATEST_PIACP" "https://github.com/svkozak/pi-acp"
			else
				report_up_to_date "pi-acp" "$CURRENT_PIACP"
			fi
		else
			report_error "${RED}✗ Could not fetch latest version for pi-acp${NC}"
		fi
	else
		report_error "${RED}✗ Could not parse current version from ${PIACP_FILE}${NC}"
	fi
else
	report_error "${RED}✗ File not found: ${PIACP_FILE}${NC}"
fi

say ""

# ── Check pi-web
say "Checking pi-web..."
PIWEB_FILE="${REPO_ROOT}/pkgs/pi-web/default.nix"

if [[ -f "$PIWEB_FILE" ]]; then
	CURRENT_PIWEB=$(get_current_version "$PIWEB_FILE" 'version = "[0-9]+\.[0-9]+\.[0-9]+"' || true)

	if [[ -n "$CURRENT_PIWEB" ]]; then
		LATEST_PIWEB=$(get_github_latest_release "jmfederico" "pi-web")

		if [[ -z "$LATEST_PIWEB" ]]; then
			LATEST_PIWEB=$(get_github_latest_tag "jmfederico" "pi-web")
		fi

		if [[ -n "$LATEST_PIWEB" ]]; then
			if version_gt "$LATEST_PIWEB" "$CURRENT_PIWEB"; then
				report_update "pi-web" "$CURRENT_PIWEB" "$LATEST_PIWEB" "https://github.com/jmfederico/pi-web"
			else
				report_up_to_date "pi-web" "$CURRENT_PIWEB"
			fi
		else
			report_error "${RED}✗ Could not fetch latest version for pi-web${NC}"
		fi
	else
		report_error "${RED}✗ Could not parse current version from ${PIWEB_FILE}${NC}"
	fi
else
	report_error "${RED}✗ File not found: ${PIWEB_FILE}${NC}"
fi

say ""
say "========================================"

# Output results
if $JSON_OUTPUT; then
	printf '[\n'
	for i in "${!UPDATE_RESULTS[@]}"; do
		[[ $i -gt 0 ]] && printf ',\n'
		printf '  %s' "${UPDATE_RESULTS[$i]}"
	done
	printf '\n]\n'
	if $CHECK_ERRORS; then
		exit 2
	elif $UPDATES_FOUND; then
		exit 1
	fi
else
	if $CHECK_ERRORS; then
		say "${RED}✗ One or more update checks failed.${NC}"
		exit 2
	elif $UPDATES_FOUND; then
		say "${YELLOW}⬆ Updates available for one or more packages!${NC}"
		exit 1
	else
		say "${GREEN}✓ All packages are up to date!${NC}"
		exit 0
	fi
fi
