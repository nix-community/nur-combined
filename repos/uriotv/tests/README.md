# Tests

## Offline suite (no Nix builds, upstream requests or credentials)

```console
./tests/run-tests.sh
```

The runner discovers every `pkgs/<name>/default.nix`, checks its executable
strict-Bash updater, then runs:

- `update-workflow.py`: RimSort release/asset selection, mocked nix-update,
  package-directory rollback, partial failures, counters, missing-updater
  preflight, empty discovery and ScopeBuddy's version-linked tag.
- `ci-workflow.py`: stubbed Nix/Cachix/curl; build every package and output,
  including non-cacheable ones; continue then fail on build errors; both Nix
  JSON output formats; malformed manifests/outputs; publication restrictions,
  complete output matching, HTTP/upload failures and exact narinfo StorePath
  validation; required gate handling all 16 success/failure/skip/cancel pairs.

- `storyforge-update.py`: mocked stable-release selection, snapshot preservation,
  strict ancestry/retag checks, complete staged updates, dependency coverage,
  generator/evaluation failures, rollback and read-only regeneration checks.
- `storyforge-compatibility.py`: JSONC parser, source-bound plans, conditional
  compatibility adjustments and unchanged resolved dependency records.

- `nur-notification.py`: mock HTTP 204/429/403/503, transient and transport
  failures; only 429 becomes a visible deferred-request warning, not a hidden
  failure or a falsely claimed accepted refresh. No network or retry waits.

- `cachyos-kernel-update.py`: offline fixtures for direct CachyOS metadata,
  numeric version-only updates, coupled source/config/patch hashes, malformed
  metadata, package-directory isolation and rollback on evaluation errors.

- `readme-versions.py`: README Version column is filled from a manifest; stale
  versions, unknown versions and package-set drift in either direction fail.

## Nix evaluation (not compilation)

```console
# Pure registry tests, no downloads; requires the Nix CLI.
python3 -B tests/registry-eval.py

# Uses the repository lock; Nix may fetch evaluation inputs.
nix eval --json --no-write-lock-file .#ci.x86_64-linux.policyTests
nix eval --json --no-write-lock-file .#ci.x86_64-linux.kernelTests
nix eval --json --no-write-lock-file .#ci.x86_64-linux.manifest
nix flake check --no-build --no-write-lock-file
```

`registry-eval.py` verifies automatic registration of a newly added package,
rejection of reserved/invalid names, exclusion of symlinks/nonpackages, and
consistent NUR/overlay exports. `package-policy.nix` verifies license decisions,
full output selection, unfree builds, redistributable nonfree uploads,
`preferLocalBuild`, broken packages and unsupported platforms.

`overlay-pin.nix` checks that the flake overlay gives a consumer with a different
nixpkgs the CI-built kernel derivation, including the NixOS `boot.kernelPackages` path.

`cachyos-eval.nix` verifies both kernels against the repository nixpkgs, the actual
NixOS kernel override pathway and patch handling. `publication-cache.py` tests the
cache-branch gate (publication status and branch promotion) with a fake `gh`.
This fetches evaluation inputs if necessary but never compiles kernels.

The build workflow runs these checks and then builds eligible supported package
outputs on x86_64-linux. `meta.ciBuild = false` kernels are compiled separately
on the self-hosted builder, never in the GitHub-hosted build job. Evaluation success is not compilation or runtime success;
GUI applications are not launched by CI. Cache verification proves public root
narinfo presence and correct StorePath, not an independent cold-cache restore.

## Optional BATS

```console
nix run nixpkgs#bats -- tests/update-scripts.bats
```

Default BATS execution is structural/offline. The idempotence test is deliberately
opt-in because it downloads upstream sources and modifies packages:

```console
# Only in a disposable checkout, with nix-update available:
RUN_LIVE_UPDATER_TESTS=1 bats tests/update-scripts.bats
```

## Adding coverage

New directories are discovered automatically; do not add a hand-maintained list.
Add policy edge cases in `package-policy.nix`, new updater fixtures in
`update-workflow.py`, and helper/network failures in `ci-workflow.py`.
