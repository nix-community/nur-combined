#!/usr/bin/env bats
# Optional BATS entry point. The default test is offline; the live test requires
# explicit opt-in and must run in a disposable checkout with nix-update on PATH.
setup() {
    cd "$BATS_TEST_DIRNAME/.." || exit 1
}

@test "all registered packages have executable, strict Bash updaters" {
    count=0
    for directory in pkgs/*/; do
        [[ ! -L "${directory%/}" && -f "${directory}default.nix" ]] || continue
        count=$((count + 1))
        [ -x "${directory}update.sh" ]
        head -1 "${directory}update.sh" | grep -q '^#!/usr/bin/env bash'
        grep -q 'set -euo pipefail' "${directory}update.sh"
    done
    [ "$count" -gt 0 ]
}

@test "live: all registered updaters are idempotent" {
    [[ "${RUN_LIVE_UPDATER_TESTS:-}" == 1 ]] || skip 'Opt in with RUN_LIVE_UPDATER_TESTS=1 in a disposable checkout'
    command -v nix-update >/dev/null || skip 'nix-update required'
    for directory in pkgs/*/; do
        [[ ! -L "${directory%/}" && -f "${directory}default.nix" ]] || continue
        run "${directory}update.sh"
        [ "$status" -eq 0 ]
        before=$(find "$directory" -type f -exec sha256sum {} + | sort)
        run "${directory}update.sh"
        [ "$status" -eq 0 ]
        after=$(find "$directory" -type f -exec sha256sum {} + | sort)
        [ "$before" = "$after" ]
    done
}
