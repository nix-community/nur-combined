# StoryForge updater architecture

Implemented by `update.sh`, `update.py` and `compatibility.py`. See README.md for
commands. This file records the invariants, not an additional update workflow.

## Source selection

Stable GitHub releases must have tags `storyforge-vMAJOR.MINOR.PATCH`, numeric
semantic ordering, `draft=false` and `prerelease=false`. The API is paginated and
malformed/rate-limited responses are errors. `target_commitish` is not trusted as
a source revision: the chosen tag is resolved to a 40-character commit SHA.

The initially packaged snapshot `89fd64ff2ca4c018260bc0538dc2d45aca12114a` has
version 2.0.8 but is 45 commits ahead of stable `storyforge-v2.0.8`
(`4755efc523c756399160065af6de7f6685ef69db`). Upstream's default branch is `release`.
The updater preserves this snapshot until a **strictly newer stable version**
descending from it appears. It never silently replaces it with the older tag.

In release mode, the accepted tag is re-resolved to detect retagging. Every new
candidate must descend from the previous accepted SHA. Rollbacks, divergent
history and moving the generator/toolchain are manual maintenance decisions.

## Metadata and dependencies

| File | Responsibility |
|---|---|
| `source.json` | Accepted version, revision, SHA-256, snapshot/release mode and tag |
| `bun2nix-pin.json` | Reviewed generator version, revision and source hash |
| `Cargo.lock` | Exact copy from that source, no Cargo resolution |
| `bun.nix` | Generated dependency fetchers, never copied from upstream |
| `compatibility.json` | Source fingerprints and bounded build adjustments |

The Nix package reads source.json, and bun-support.nix reads bun2nix-pin.json.
The updater validates the pin against the reviewed adapter contract and checks
its fetched flake source narHash. No automatic update modifies the repository
flake.lock, generator metadata, or vendored support modules.

The generator is an update-time, source-pinned tool flake. The consumer package
never evaluates StoryForge's flake or imports a different nixpkgs. Before running
the generator, cheap compatibility checks reject unknown formats. It may need
an initial compilation on GitHub if no substitute is available; ordinary no-op
release checks never invoke it. The parent timeout remains 900 seconds/package.

## Transaction

1. Select candidate; no new candidate means no downloads/writes/generator run.
2. Prefetch/hash one immutable snapshot with Nix. Both `storePath` and `path`
   response formats are accepted. Source files must not escape it via symlinks.
3. Validate package.json, Cargo.toml, tauri.conf.json and Cargo.lock versions.
   Cargo Git sources are rejected until explicit outputHashes support exists.
4. Generate a bounded compatibility plan and verify it against that source.
5. Copy the package into staging; write the **new** source metadata before
   evaluation, copy Cargo.lock and generate bun.nix from the original bun.lock.
6. Parse/evaluate the generated Nix with inert fetcher stubs. Its attribute keys
   must exactly match the unique package identities in bun.lock (668 for the
   initial snapshot, including the five historically missing dnd-kit packages).
7. Evaluate the staged derivation with the repository's pinned nixpkgs and
   `allow-import-from-derivation=false`; verify the candidate version and drvPath.
8. Replace only source.json, Cargo.lock, bun.nix and compatibility.json. Preserve
   backups/modes and restore on exceptions, SIGTERM/SIGHUP or interruption.

Multi-file replacement is a logical rollback-protected transaction, not a
filesystem-wide atomic operation. The parent updater's complete directory backup
is the second recovery layer for a killed child. No partial update may return
success. Subprocess diagnostics redact the GitHub token; Python bytecode is
suppressed so generated caches cannot enter update PRs.

## Compatibility boundaries

A small standard-library JSONC parser supports comments/trailing commas without
corrupting string contents and rejects duplicate keys or unknown syntax.
Only lock schemas 1/2 with configVersion 1 are understood. Build-time application
regenerates the only allowed plan and requires exact equality, including raw
source fingerprints. It can change header 2 to 1 and the reviewed better-auth
requirement mismatch (^1.7.7 to the workspace's ^1.7.6); resolved records are not
modified. Matching requirements need no adjustment. New cases fail closed.

The updater never runs upstream lifecycle scripts, Bun install, Cargo lock
regeneration or StoryForge compilation. Those checks belong to the subsequent
sandboxed package build, with `--offline --frozen-lockfile` installation.

## Read-only verification

`--check` performs real release selection without source downloads/writes.
`--verify-current` deliberately exercises source hashing, lock identity,
regeneration of bun.nix and staged evaluation. It requires byte-identical
regeneration and never publishes staged files. A manual build workflow checkbox
runs this more expensive test; regular update checks keep their fast no-op path.

Both modes are distinct from compiling the app. The full package build and
required test-gate still decide whether the grouped update PR can auto-merge.
Successful main builds alone publish license-eligible outputs to Cachix and
notify NUR. No updater has cache write credentials or merge permissions.

## Tests

`tests/storyforge-update.py` mocks API/Nix/generator calls and exercises release
ordering/pagination, no-downgrade, retag/ancestry failures, complete staging,
precise manifest coverage, malformed inputs, evaluation/generation failure,
rollback, interruption, idempotence and read-only verification.
`tests/storyforge-compatibility.py` checks JSONC parsing, approved edits, unknown
schemas, input-fingerprint mismatch and preservation of resolved dependencies.
Both are included in tests/run-tests.sh. Registry/preflight accepts the strict
Bash wrapper only with a real Python updater file; no placeholder success script.
