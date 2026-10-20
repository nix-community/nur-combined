# Story Forge

Source build of StoryForge for Linux, independent of its upstream flake.
The accepted version, immutable revision and source hash live in `source.json`.
NUR, the repository overlay and direct flake outputs use the same package.

```console
nix build .#storyforge
nix run .#storyforge
```

## Automatic updates

`update.sh` is picked up by the repository's daily updater without a separate
workflow. It delegates to `update.py`, which:

1. selects a strictly newer stable `storyforge-vX.Y.Z` GitHub release;
2. resolves the tag to an immutable SHA and checks ancestry/retags;
3. downloads one hash-verified snapshot and validates all three app versions;
4. copies Cargo.lock exactly and regenerates the complete Bun manifest using
   the reviewed bun2nix pin;
5. creates a source-fingerprint-bound compatibility plan;
6. evaluates the staged package with the repository's locked nixpkgs and IFD
   disabled, then replaces the four generated files with rollback on errors.

The current accepted snapshot is 45 commits ahead of stable 2.0.8. No newer
stable version means **success without changes**, not a downgrade to that tag.
New releases must descend from the accepted commit. A moved tag, divergence,
unknown schema or changed tool pin stops the updater for manual review.

```console
# Cheap release selection, without downloading sources/generating manifests:
./pkgs/storyforge/update.sh --check

# Normal update: no-op when current, otherwise stage and validate a new release:
./pkgs/storyforge/update.sh

# Explicit, read-only regeneration/evaluation of the currently accepted source:
# May build the pinned bun2nix tool if it is not cached; does NOT build StoryForge.
./pkgs/storyforge/update.sh --verify-current
```

The last check is also an optional checkbox in the manual **Build and populate
cache** workflow (`verify_storyforge_updater`). It is deliberately opt-in so
routine no-op update checks do not build a second toolchain. The subsequent CI
build still compiles StoryForge and runs Rust tests. Updating files successfully
is not equivalent to passing that full build.

Failed updates leave the original files intact. The parent updater also backs
up/restores the entire package directory, so it can continue checking other
packages and open a PR containing their successful updates. Its final failure
counter keeps a broken StoryForge update visible rather than silently green.

## Dependency handling

- `bun.nix` is generated with bun2nix 2.1.2 and covers every unique package record
  in bun.lock, including all five `@dnd-kit/*` dependencies omitted upstream.
- `bun2nix-pin.json` contains the reviewed source revision/hash/version shared
  by the updater and `bun-support.nix`. The updater checks the generator flake's
  source hash before running it. Tool upgrades are deliberate maintenance.
- `bun-support/` contains MIT-licensed modules from that source. The adapter
  uses this repository's nixpkgs, without evaluating StoryForge's flake. Only
  the Zig cache helper is built from hash-pinned source, not during evaluation.
- `Cargo.lock` is copied from the same source snapshot. The Rust build hook
  checks consistency. New Git dependencies need reviewed `outputHashes` support;
  automatic updates fail rather than guess those hashes.
- `compatibility.py` parses JSONC and supports only reviewed lock schemas. The
  fingerprinted plan currently changes header version 2 to 1 for pinned Bun,
  and adjusts the known better-auth requirement mismatch without changing its
  resolved 1.7.7 package. If upstream fixes the mismatch, the adjustment is
  omitted instead of applying an obsolete hardcoded replacement.
- The actual install phases use `--offline --frozen-lockfile`. The updater never
  runs upstream scripts, `bun install`, Cargo lock regeneration or app builds.

No update changes `flake.lock`, the generator pin or the vendored support files.
If upstream requires new compatibility behavior, review it explicitly and update
fixtures before allowing auto-merge. GPL-3.0 metadata makes StoryForge eligible
for the existing main-only cache publication after the complete required CI gate.

## Verification and scope

The offline suite includes source selection, no downgrade/retag, manifest
coverage, compatibility, staging/evaluation failures, file-replacement rollback,
interruption, read-only verification and repeat no-op tests:

```console
./tests/run-tests.sh
python3 -B tests/registry-eval.py
nix eval --json .#ci.x86_64-linux.manifest
```

For a full sandbox build (can be expensive):

```console
nix build .#storyforge --no-link \
  --option sandbox true --option allow-import-from-derivation false
```

CI does not launch the GUI, test authentication, download game files or run
Vintage Story. Those are separate runtime checks. For untracked development
files, use `path:.#storyforge` instead of `.#storyforge`.

Implementation decisions: [UPDATE-DESIGN.md](UPDATE-DESIGN.md).
