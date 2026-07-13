---
name: update-packages
description: Run nix-update across all packages in this repo, fix build failures, and land each package's changes as its own separate jj commit. Use when asked to "update all packages", "bump everything", "run nix-update on all packages", or similar bulk-update requests.
---

Bulk-update every package in `default.nix` via `nix-update`, fix whatever
breaks, verify builds, and end with one clean jj commit per changed package.

## Rules (non-negotiable)

- **One package change per commit.** Never let fixes for package B leak into
  package A's commit. Use `jj squash --from <rev> --into <rev> -- <path>` to
  move stray file changes into the right commit, then `jj rebase` to keep the
  stack linear.
- **Never regress a version.** For every package whose `version`/`rev`
  changes, explicitly verify the new value is newer/forward from the old one
  before committing — don't just trust `nix-update`'s pick. This is
  mandatory, not just for cases where you're unsure:
  ```sh
  git clone -q <homepage-url> /tmp/<pkg>-check
  cd /tmp/<pkg>-check
  # if both sides are tags/versions, compare dates:
  git log -1 --format=%ci <old-ref>
  git log -1 --format=%ci <new-ref>
  # if either side is a raw commit hash (not a tag), confirm ancestry:
  git merge-base --is-ancestor <old-rev> <new-rev> \
    && echo "old is ancestor of new (safe upgrade)" \
    || echo "STOP: old is NOT an ancestor of new — do not commit this"
  ```
  If `merge-base --is-ancestor` fails (exit non-zero) or the old ref's commit
  date is later than the new ref's, treat this as a bug in the proposed
  update — do not commit it. Re-check upstream tags/releases manually and
  either pick the actually-latest one or leave the package untouched.
- **Every touched package must build** before it's considered done
  (`nix-build -A <pkg>`, or `nix build .#<pkg>` if the local `<nixpkgs>`
  channel is too old — see Known Issues below).
- **Attribute renames with no version bump** (e.g. `cargoSha256` ->
  `cargoHash`) still get their own commit — don't bundle with unrelated
  version bumps.

## Steps

1. **List packages for the current system:**
   ```sh
   nix flake show --json 2>/dev/null | \
     jq -r '.inventory.packages.output.children["aarch64-darwin"].children | keys[]'
   ```
   (swap `aarch64-darwin` for the relevant system)

2. **Run nix-update per package, non-interactively, logging output:**
   ```sh
   <list-of-packages> | xargs -n1 nix-update --commit --flake 2>&1 | tee /tmp/nix-update-log.txt
   ```
   This auto-commits via `jj`/`git` as it goes — expect it to create messy
   working-copy commits you'll clean up in step 4. Some packages will error
   out (unstable/prerelease versions, hash mismatches from tag renames,
   flake-eval quirks) — note them, don't stop the batch.

3. **Triage failures from the log:**
   - `"Found an unstable version ... ignored"` → rerun that package alone with
     `nix-update --commit --flake --version=unstable <pkg>`.
   - Hash mismatch after a `rev` change → check if upstream tags have a `v`
     prefix (`rev = version;` vs `rev = "v${version}";`), fix, then re-run
     `nix-update` or manually recompute via `lib.fakeSha256` swap +
     `nix-build`.
   - Go `vendorHash` / Rust `cargoHash` mismatches after any `src` change →
     always need to be recomputed; let the build error tell you the correct
     hash and paste it in.
   - Rust packages with a **vendored `Cargo.lock` that's gitignored upstream**
     (check `pkgs/<pkg>/Cargo.lock` existing in this repo) → regenerate with
     `cargo generate-lockfile` against a fresh clone of the new tag, copy it
     over `pkgs/<pkg>/Cargo.lock`.
   - Git dependencies in `Cargo.lock` (`source = "git+https://..."`) need
     explicit hashes in `cargoLock.outputHashes` — get them via
     `nix run nixpkgs#nix-prefetch-git -- --url <url> --rev <rev> --quiet`.

4. **Verify each version/rev bump is actually forward**, before doing any jj
   cleanup. For every package where `version` or `rev` changed, run the
   ancestry/date check from the "Never regress a version" rule above. Do
   this for every single change — including ones `nix-update` picked
   automatically — not just the ones that look suspicious. If a package
   fails the check, revert its change (`jj restore` or drop that package's
   commit) and investigate upstream manually before retrying.

5. **Split/clean up commits with jj:**
   ```sh
   jj log -n 10                      # see what nix-update produced
   jj diff --git -r <rev> --stat     # check which files landed in which commit
   ```
   For any commit that has more than one package's files:
   ```sh
   jj new <good-parent> -m "<pkg>: <desc>" --no-edit   # empty commit to receive it
   jj squash --from <messy-rev> --into <new-rev> -- pkgs/<pkg>/default.nix [pkgs/<pkg>/Cargo.lock ...]
   jj rebase -r <messy-rev-descendant-chain> -d <new-rev>   # keep it linear
   ```
   Abandon any leftover empty commits (`jj abandon <rev>`) and fix descriptions
   with `jj describe <rev> -m "..."`.

6. **Verify every touched package builds:**
   ```sh
   nix-build -A <pkg1> -A <pkg2> ...
   ```
   If a Rust package needs a newer rustc than the local `<nixpkgs>` channel
   provides (see Known Issues), fall back to `nix build .#<pkg>` and run the
   resulting binary's `--version` to sanity check.

7. **Final check:** `jj log -n <N>` should show one commit per changed
   package, each with a description in `<pkg>: <old> -> <new>` format (or a
   short description for non-version changes), and `jj status` should be
   clean except for the working-copy tip.

## Commit Message Format

Follow the repo convention from `AGENTS.md`: `<package-name>: <description>`,
one line, no body needed for routine bumps.

- **Version bump:** `<pkg>: <old-version> -> <new-version>`
  e.g. `esa: 0.2.0 -> 0.3.0`, `prr: 0.20.0 -> 0.21.0`
- **Commit-pinned package moving to a tagged release:** use the short hash
  for the old side, plain version for the new side —
  `<pkg>: <old-short-hash> -> <new-version>`
  e.g. `protodot: 87817c3 -> 1.2.0`
  (only do this after confirming the old commit is actually an ancestor of
  the new tag — see the "Never regress a version" rule above)
- **Hash/attribute-only fixups with no version change:**
  `<pkg>: <old-attr> -> <new-attr>` or a short imperative description —
  e.g. `toffee: cargoSha256 -> cargoHash`, `gloc: recompute`
- **Non-version code fixes** (e.g. migrating away from a removed nixpkgs
  attribute): a short imperative description, still scoped to one package —
  e.g. `prr: migrate darwin frameworks to apple-sdk`
- **New package added to the repo** (not a bulk-update scenario, but keep the
  convention consistent if one comes up alongside a batch): `<pkg>: init at
  <version>` — e.g. `defuddle: init at 0.9.0`, `esa: init at v0.2.0`. For
  packages pinned to a commit instead of a tag, use nixpkgs' `unstable-`
  date format: `hunk: init at unstable-2026-05-08`.
- Never combine multiple packages' descriptions in one message
  (no `probe/prr/toffee: ...`) — if you catch yourself writing a message with
  a slash or "and", that's a signal the commit needs splitting per the
  one-package-per-commit rule.
- Don't add prefixes like `fix:`/`chore:`/`feat:` — this repo doesn't use
  conventional commits, just `<package-name>: <description>`.

## Known Issues

- **`darwin.apple_sdk_11_0 has been removed`** when building via `nix build`
  (flake-pinned nixpkgs) for packages still using
  `darwin.apple_sdk.frameworks.*` in `buildInputs`. Fix: replace the
  `darwin` callPackage arg with `apple-sdk`, and swap
  `darwin.apple_sdk.frameworks.X` for just `apple-sdk` in the darwin
  `lib.optionals` block. Works on both the old `<nixpkgs>` channel and the
  flake's pinned nixpkgs. Any `cargoHash`/`vendorHash` will need
  recomputation after this since it changes the dependency closure.
- **Local `<nixpkgs>` channel has an older rustc** than the flake's pinned
  nixpkgs (observed: channel rustc 1.82 vs flake nixpkgs-unstable rustc
  1.96+). If a Rust package's MSRV exceeds the channel's rustc, `nix-build`
  will fail with `rustc X.Y.Z is not supported by ...` — use
  `nix build .#<pkg>` instead, which resolves against the flake's own
  `nixpkgs` input.
- **`hunk`** is provided via a separate flake input (see `flake.nix`), not a
  `pkgs/hunk` directory — skip it in bulk `nix-update` runs, it'll error with
  a `sanitizePositions`/`package.nix is not in ...` eval error which is
  expected and not fixable from this repo.
