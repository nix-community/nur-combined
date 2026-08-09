#!/usr/bin/env bash
# Simple test runner for update.sh scripts
# Usage: ./tests/run-tests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test packages
PACKAGES=(
    "cybergrub2077"
    "optiscaler-client"
    "rimsort-appimage"
    "scopebuddy"
    "vs-launcher"
    "wowup-cf"
)

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $*"
    return 0
}

test_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $*"
    return 1
}

test_skip() {
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    echo -e "${YELLOW}⊘${NC} $*"
    return 0
}

# Test 1: Check if update.sh exists and is executable
test_script_exists() {
    local pkg="$1"
    local script="$REPO_ROOT/pkgs/$pkg/update.sh"

    if [[ ! -f "$script" ]]; then
        test_fail "$pkg: update.sh not found" || return 0
        return 0
    fi

    if [[ ! -x "$script" ]]; then
        test_fail "$pkg: update.sh not executable" || return 0
        return 0
    fi

    test_pass "$pkg: update.sh exists and is executable" || return 0
    return 0
}

# Test 2: Check if update.sh has proper shebang and set -euo pipefail
test_script_structure() {
    local pkg="$1"
    local script="$REPO_ROOT/pkgs/$pkg/update.sh"

    if ! head -1 "$script" | grep -q '^#!/usr/bin/env bash'; then
        test_fail "$pkg: missing or incorrect shebang" || return 0
        return 0
    fi

    if ! grep -q 'set -euo pipefail' "$script"; then
        test_fail "$pkg: missing 'set -euo pipefail'" || return 0
        return 0
    fi

    test_pass "$pkg: script structure is correct" || return 0
    return 0
}

# Test 3: Check if update.sh uses nix-update
test_uses_nix_update() {
    local pkg="$1"
    local script="$REPO_ROOT/pkgs/$pkg/update.sh"

    if ! grep -q 'nix-update' "$script"; then
        test_fail "$pkg: does not use nix-update" || return 0
        return 0
    fi

    test_pass "$pkg: uses nix-update" || return 0
    return 0
}

# Test 4: Check if update.sh uses --flake flag (required for flake-based packages)
test_uses_flake() {
    local pkg="$1"
    local script="$REPO_ROOT/pkgs/$pkg/update.sh"

    if ! grep -q '\-\-flake' "$script"; then
        test_skip "$pkg: does not use --flake flag" || return 0
        return 0
    fi

    test_pass "$pkg: uses --flake flag" || return 0
    return 0
}

# Test 5: Check if optiscaler-client generates deps.json
test_optiscaler_deps() {
    local pkg="optiscaler-client"
    local deps_file="$REPO_ROOT/pkgs/$pkg/deps.json"

    if [[ ! -f "$deps_file" ]]; then
        test_skip "$pkg: deps.json not found (run update.sh first)" || return 0
        return 0
    fi

    if command -v jq &> /dev/null; then
        if ! jq empty "$deps_file" 2>/dev/null; then
            test_fail "$pkg: deps.json is not valid JSON" || return 0
            return 0
        fi
    else
        test_skip "$pkg: jq not available, skipping JSON validation" || return 0
        return 0
    fi

    test_pass "$pkg: deps.json is valid JSON" || return 0
    return 0
}

# Test 6: Check if package directory exists
test_package_dir_exists() {
    local pkg="$1"
    local pkg_dir="$REPO_ROOT/pkgs/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        test_fail "$pkg: package directory not found" || return 0
        return 0
    fi

    if [[ ! -f "$pkg_dir/default.nix" ]]; then
        test_fail "$pkg: default.nix not found" || return 0
        return 0
    fi

    test_pass "$pkg: package directory and default.nix exist" || return 0
    return 0
}

# Main test runner
main() {
    echo "======================================"
    echo "Testing update.sh scripts"
    echo "======================================"
    echo

    cd "$REPO_ROOT"

    for pkg in "${PACKAGES[@]}"; do
        echo "--- Testing: $pkg ---"
        test_package_dir_exists "$pkg"
        test_script_exists "$pkg"
        test_script_structure "$pkg"
        test_uses_nix_update "$pkg"
        test_uses_flake "$pkg"

        # Special test for optiscaler-client
        if [[ "$pkg" == "optiscaler-client" ]]; then
            test_optiscaler_deps
        fi
        echo
    done

    echo "======================================"
    echo "Test Summary"
    echo "======================================"
    echo -e "Passed:  ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:  ${RED}$TESTS_FAILED${NC}"
    echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    echo

    if [[ $TESTS_FAILED -gt 0 ]]; then
        log_error "Some tests failed!"
        exit 1
    else
        log_info "All tests passed!"
        exit 0
    fi
}

main "$@"
