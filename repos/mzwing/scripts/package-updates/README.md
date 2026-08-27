# Package update pipeline

The update workflow (`.github/workflows/update.yml`) runs four stages, in this order:

1. **`update-sources`** — nvfetcher refreshes `_sources/generated.json` (upstream versions and source hashes).
2. **`update-lockfiles`** — regenerates crate2nix `Cargo.nix`, gomod2nix `gomod2nix.toml` and pub `pubspec.lock.json` files for packages whose source changed.
3. **`update-pins`** — refreshes package *pins*: data whose URL and hash must change together, declared by packages as `passthru.pins`.
4. **`update-hashes`** — nix-update recomputes vendored dependency hashes (`vendorHash`, `pnpmDepsHash`, ...) when a package source, package definition, or shared hash input changed.

Pins run after lockfiles because pin data can be derived from the regenerated lockfiles, and before hash refreshes so nix-update sees settled pins. NPM lockfile repair is part of the repository's `fetchNpmDeps` wrapper, so it runs inside the dependency FOD before nix-update observes and writes the resulting hash; it does not need a separate pipeline stage.

For push-triggered runs, the workflow passes the pre-push revision as `UPDATE_BASE_REV`, allowing package changes already committed at `HEAD` to trigger a refresh. Working-tree source, lockfile, pin, and flake input changes are detected directly. Changes to `default.nix`, `flake.nix`, `flake.lock`, or `internal/npm-lockfile-fix.nix` refresh every hash-bearing package because they can change dependency outputs without changing an nvfetcher source.

## Which mechanism owns what

- **Static URL, only the hash changes** (dependency FODs recomputed from a lockfile): `update-hashes` / nix-update. Convention: a `*Hash = "sha256-..."` attribute in `pkgs/<name>/default.nix`. Use `nix run .#update-hashes -- <name>` to force a package after external hash drift.
- **URL and hash must change together** (a version/commit/feature tuple embedded in the URL): `update-pins`, via the package's own `passthru.pins`. The pin data lives in a `pins.json` next to the package's `default.nix` and is imported with `lib.importJSON`, so plain evaluation stays offline.
- **Upstream ships no lockfile at all** (Flutter projects commonly gitignore `pubspec.lock`): `update-lockfiles` resolves one with `flutter pub get` and commits it as `pubspec.lock.json` next to the package's `default.nix`. The package names the SDK to resolve against through `passthru.pubLockFlutter`, keeping the Flutter version in one place and the runner package-agnostic. A placeholder lock carries an empty `packages` map and an `sdks.dart` constraint (pub2nix derives the Dart language version from it): it evaluates, so the repository keeps evaluating before the first resolution lands. Resolution only runs when the source changed, and the SDK closure is dropped from the store right afterwards — `gc-store` roots every package's build closure, so a multi-gigabyte SDK left behind would ride the shared store cache from then on.

## The `passthru.pins` contract

A package with coupled URL+hash data declares *what* to pin; the runner owns *how*:

```nix
passthru.pins = {
  # Prints the pin identity — everything except the hashes — as JSON on stdout, or fails.
  resolve = pkgs.writeShellApplication {
    name = "<name>-resolve-pins";
    runtimeInputs = [ pkgs.curl pkgs.jq /* ... */ ];
    text = builtins.readFile ./resolve-pins.sh;
  };

  # Where each prefetched SRI hash lands in pins.json, and the URL it comes from.
  # `{a.b}` interpolates a dotted path from the resolved identity.
  hashes."koffi.hash" = "https://example.invalid/{koffi.commit}.tar.gz";
};
```

The runner (`nix run .#update-pins`) discovers every package in the current system's flake package set that declares `pins`, then for each one:

1. builds `resolve` and runs it with the package's `_sources/generated.json` entry in `PIN_SOURCE`, rejecting output that is not a JSON object;
2. compares the identity against `pkgs/<name>/pins.json` with the declared hash paths spliced back in; when they match and every hash is already filled in, it stops without touching the network or the worktree;
3. expands each `hashes` URL template — a missing or non-string dotted path aborts the run — and prefetches it with `nix store prefetch-file`, rejecting an empty hash;
4. writes canonical (`jq -S`) JSON atomically, and only when the content actually changed.

Consequences of that split:

- A resolver never reads or writes `pins.json`, never sees `--force`, and needs no knowledge of the repository layout. It is a pure function from the upstream source entry to an identity.
- Skip-if-unchanged, forcing, prefetching, hash validation and the atomic canonical write exist once, in the runner.
- `nix run .#update-pins -- <name>` runs only the named packages and forces them: re-download and re-hash even when the identity is unchanged. This is the escape hatch for upstream asset drift or fetcher behavior changes. Unknown names are an error, not a no-op.
- Resolvers fail loudly: an unexpected tag, a changed upstream manifest shape, or an unresolvable ref aborts the run instead of keeping a potentially wrong pin.

## Failure handling

A failing resolver aborts the workflow before `update-hashes` runs, so a half-updated pin can never be committed. Diagnose locally with `nix run .#update-pins -- <name>`; the resolvers are ordinary scripts and their error messages name the exact check that failed.
