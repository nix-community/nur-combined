# Package update pipeline

The update workflow (`.github/workflows/update.yml`) runs four stages, in this order:

1. **`update-sources`** — nvfetcher refreshes `_sources/generated.json` (upstream versions and source hashes).
2. **`update-lockfiles`** — regenerates crate2nix `Cargo.nix`, gomod2nix `gomod2nix.toml` and pub `pubspec.lock.json` files for packages whose source changed.
3. **`update-pins`** — refreshes package *pins*: data whose URL and hash must change together, exposed by packages as `passthru.pinUpdater`.
4. **`update-hashes`** — nix-update recomputes vendored dependency hashes (`vendorHash`, `pnpmDepsHash`, ...) when a package source, package definition, or shared hash input changed.

Pins run after lockfiles because pin data can be derived from the regenerated lockfiles, and before hash refreshes so nix-update sees settled pins. NPM lockfile repair is part of the repository's `fetchNpmDeps` wrapper, so it runs inside the dependency FOD before nix-update observes and writes the resulting hash; it does not need a separate pipeline stage.

For push-triggered runs, the workflow passes the pre-push revision as `UPDATE_BASE_REV`, allowing package changes already committed at `HEAD` to trigger a refresh. Working-tree source, lockfile, pin, and flake input changes are detected directly. Changes to `default.nix`, `flake.nix`, `flake.lock`, or `internal/npm-lockfile-fix.nix` refresh every hash-bearing package because they can change dependency outputs without changing an nvfetcher source.

## Which mechanism owns what

- **Static URL, only the hash changes** (dependency FODs recomputed from a lockfile): `update-hashes` / nix-update. Convention: a `*Hash = "sha256-..."` attribute in `pkgs/<name>/default.nix`. Use `nix run .#update-hashes -- <name>` to force a package after external hash drift.
- **URL and hash must change together** (a version/commit/feature tuple embedded in the URL): `update-pins`, via the package's own `passthru.pinUpdater`. The pin data lives in a `pins.json` next to the package's `default.nix` and is imported with `lib.importJSON`, so plain evaluation stays offline.
- **Upstream ships no lockfile at all** (Flutter projects commonly gitignore `pubspec.lock`): `update-lockfiles` resolves one with `flutter pub get` and commits it as `pubspec.lock.json` next to the package's `default.nix`. The package names the SDK to resolve against through `passthru.pubLockFlutter`, keeping the Flutter version in one place and the runner package-agnostic. A placeholder lock carries an empty `packages` map and an `sdks.dart` constraint (pub2nix derives the Dart language version from it): it evaluates, so the repository keeps evaluating before the first resolution lands. Resolution only runs when the source changed, and the SDK closure is dropped from the store right afterwards — `gc-store` roots every package's build closure, so a multi-gigabyte SDK left behind would ride the shared store cache from then on.

## The `passthru.pinUpdater` contract

A package with coupled URL+hash data exposes:

```nix
passthru.pinUpdater = pkgs.writeShellApplication {
  name = "<name>-update-pins";
  runtimeInputs = [ pkgs.curl pkgs.jq pkgs.nix /* ... */ ];
  runtimeEnv.PIN_UTILS = ../../scripts/package-updates/lib/pin-utils.sh;
  text = builtins.readFile ./update-pins.sh;
};
```

- The runner (`nix run .#update-pins`) discovers every package in the current system's flake package set that exposes `pinUpdater`, builds the executables and runs them **from the repository root**. The runner has no package-specific logic.
- An updater only ever rewrites pin files in its own package directory and must leave the worktree untouched when nothing changed (no mtime bumps, no spurious diffs).
- `nix run .#update-pins -- <name>` runs only the named updaters and passes `--force`: re-download and re-hash even when the pin identity is unchanged. This is the escape hatch for upstream asset drift or fetcher behavior changes. Unknown names are an error, not a no-op.
- Updaters fail loudly: a missing crate entry, an ambiguous release asset match, an unknown feature flag or an empty hash all abort the run instead of keeping a potentially wrong pin.

`lib/pin-utils.sh` provides the reusable pieces: extracting a crate's version and `resolvedDefaultFeatures` from a crate2nix-generated `Cargo.nix`, querying GitHub release assets (with optional `GITHUB_TOKEN`/`GH_TOKEN` authentication), unique-asset matching, `nix store prefetch-file` SRI hashing and stable, atomic JSON rewrites.

## Failure handling

A failing updater aborts the workflow before `update-hashes` runs, so a half-updated pin can never be committed. Diagnose locally with `nix run .#update-pins -- <name>`; the updaters are ordinary scripts and their error messages name the exact check that failed.
