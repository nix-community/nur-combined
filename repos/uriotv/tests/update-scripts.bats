#!/usr/bin/env bats
# Tests for update.sh scripts
# Run with: bats tests/update-scripts.bats

setup() {
    # Save current directory
    ORIG_DIR="$PWD"
    cd "$BATS_TEST_DIRNAME/.." || exit 1
}

teardown() {
    cd "$ORIG_DIR" || exit 1
}

# Helper function to check if update script exists and is executable
check_update_script() {
    local pkg="$1"
    local script="pkgs/$pkg/update.sh"

    [ -f "$script" ] || {
        echo "Update script not found: $script"
        return 1
    }

    [ -x "$script" ] || {
        echo "Update script not executable: $script"
        return 1
    }

    return 0
}

@test "cybergrub2077: update.sh exists and is executable" {
    check_update_script "cybergrub2077"
}

@test "optiscaler-client: update.sh exists and is executable" {
    check_update_script "optiscaler-client"
}

@test "rimsort-appimage: update.sh exists and is executable" {
    check_update_script "rimsort-appimage"
}

@test "scopebuddy: update.sh exists and is executable" {
    check_update_script "scopebuddy"
}

@test "vs-launcher: update.sh exists and is executable" {
    check_update_script "vs-launcher"
}

@test "wowup-cf: update.sh exists and is executable" {
    check_update_script "wowup-cf"
}

@test "cybergrub2077: update.sh is idempotent (no changes on second run)" {
    # Skip if package is not in a git repo or has uncommitted changes
    git rev-parse --git-dir > /dev/null 2>&1 || skip "Not in a git repository"
    git diff --quiet || skip "Repository has uncommitted changes"

    # Run update script first time
    run ./pkgs/cybergrub2077/update.sh
    [ "$status" -eq 0 ]

    # Capture state after first run
    local first_run_hash
    first_run_hash=$(git hash-object pkgs/cybergrub2077/default.nix 2>/dev/null || echo "no-file")

    # Run update script second time
    run ./pkgs/cybergrub2077/update.sh
    [ "$status" -eq 0 ]

    # Capture state after second run
    local second_run_hash
    second_run_hash=$(git hash-object pkgs/cybergrub2077/default.nix 2>/dev/null || echo "no-file")

    # Verify no changes between runs (idempotent)
    [ "$first_run_hash" = "$second_run_hash" ]
}

@test "rimsort-appimage: update.sh is idempotent (no changes on second run)" {
    git rev-parse --git-dir > /dev/null 2>&1 || skip "Not in a git repository"
    git diff --quiet || skip "Repository has uncommitted changes"

    run ./pkgs/rimsort-appimage/update.sh
    [ "$status" -eq 0 ]

    local first_run_hash
    first_run_hash=$(git hash-object pkgs/rimsort-appimage/default.nix 2>/dev/null || echo "no-file")

    run ./pkgs/rimsort-appimage/update.sh
    [ "$status" -eq 0 ]

    local second_run_hash
    second_run_hash=$(git hash-object pkgs/rimsort-appimage/default.nix 2>/dev/null || echo "no-file")

    [ "$first_run_hash" = "$second_run_hash" ]
}

@test "scopebuddy: update.sh is idempotent (no changes on second run)" {
    git rev-parse --git-dir > /dev/null 2>&1 || skip "Not in a git repository"
    git diff --quiet || skip "Repository has uncommitted changes"

    run ./pkgs/scopebuddy/update.sh
    [ "$status" -eq 0 ]

    local first_run_hash
    first_run_hash=$(git hash-object pkgs/scopebuddy/default.nix 2>/dev/null || echo "no-file")

    run ./pkgs/scopebuddy/update.sh
    [ "$status" -eq 0 ]

    local second_run_hash
    second_run_hash=$(git hash-object pkgs/scopebuddy/default.nix 2>/dev/null || echo "no-file")

    [ "$first_run_hash" = "$second_run_hash" ]
}

@test "vs-launcher: update.sh is idempotent (no changes on second run)" {
    git rev-parse --git-dir > /dev/null 2>&1 || skip "Not in a git repository"
    git diff --quiet || skip "Repository has uncommitted changes"

    run ./pkgs/vs-launcher/update.sh
    [ "$status" -eq 0 ]

    local first_run_hash
    first_run_hash=$(git hash-object pkgs/vs-launcher/default.nix 2>/dev/null || echo "no-file")

    run ./pkgs/vs-launcher/update.sh
    [ "$status" -eq 0 ]

    local second_run_hash
    second_run_hash=$(git hash-object pkgs/vs-launcher/default.nix 2>/dev/null || echo "no-file")

    [ "$first_run_hash" = "$second_run_hash" ]
}

@test "wowup-cf: update.sh is idempotent (no changes on second run)" {
    git rev-parse --git-dir > /dev/null 2>&1 || skip "Not in a git repository"
    git diff --quiet || skip "Repository has uncommitted changes"

    run ./pkgs/wowup-cf/update.sh
    [ "$status" -eq 0 ]

    local first_run_hash
    first_run_hash=$(git hash-object pkgs/wowup-cf/default.nix 2>/dev/null || echo "no-file")

    run ./pkgs/wowup-cf/update.sh
    [ "$status" -eq 0 ]

    local second_run_hash
    second_run_hash=$(git hash-object pkgs/wowup-cf/default.nix 2>/dev/null || echo "no-file")

    [ "$first_run_hash" = "$second_run_hash" ]
}

@test "optiscaler-client: update.sh generates deps.json" {
    [ -f "pkgs/optiscaler-client/default.nix" ] || skip "default.nix not found"

    run ./pkgs/optiscaler-client/update.sh
    [ "$status" -eq 0 ]

    # Check if deps.json was created or updated
    [ -f "pkgs/optiscaler-client/deps.json" ]
}

@test "optiscaler-client: deps.json is valid JSON" {
    [ -f "pkgs/optiscaler-client/deps.json" ] || skip "deps.json not found"

    run jq empty pkgs/optiscaler-client/deps.json
    [ "$status" -eq 0 ]
}
