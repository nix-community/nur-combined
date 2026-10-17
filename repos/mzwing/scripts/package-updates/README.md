# Package update pipeline

The update workflow (`.github/workflows/update.yml`) runs `scripts/ci/update-packages.sh`, which runs two stages in this order:

1. **`update-sources`** — [nix-repin](https://github.com/so1ve/nix-repin) runs every `pkgs/<name>/source.ts` and writes what it returns beside it: a `source.nix` with the pinned version and source, plus any lockfile, pin file or dependency hash the definition derives from that source.
2. **`update-hashes`** — nix-update recomputes the vendored dependency hashes only a build reveals (`pnpmDepsHash`, `bunDepsHash`, ...) when a package or a shared hash input changed.

When a definition's revision or version is unchanged, nix-repin skips it entirely, lock and pin generation included; the [Composing providers](https://github.com/so1ve/nix-repin#composing-providers) section of its README lists the providers that do this and which generated file to delete to regenerate everything at the same revision. Everything a definition returns is generated, so change the `source.ts` instead.

For push-triggered runs, the workflow passes the pre-push revision as `UPDATE_BASE_REV`, allowing package changes already committed at `HEAD` to trigger a hash refresh. Working-tree changes, including everything `update-sources` just wrote, are detected directly. Changes to `default.nix`, `flake.nix`, `flake.lock`, or `internal/npm-lockfile-fix.nix` refresh every hash-bearing package because they can change dependency outputs without changing a package's source.

## Which mechanism owns what

- **Anything derived from upstream metadata or the source tree** (versions, archives, lockfiles, pins, and an `npmDepsHash` computable from a complete lockfile): the package's `source.ts`, composed from nix-repin's providers and the `crate2nix` and `gomod2nix` providers in `internal/sources.ts`. nix-repin only lets a definition start the programs in the `--allow-run` list of its `default.nix`, so those two build their tool from the nixpkgs that `flake.lock` pins and run it through `nix shell`.
- **Hashes only a build reveals** (bun and pnpm dependency FODs, and npm lockfiles that `internal/npm-lockfile-fix.nix` repairs inside the FOD): `update-hashes`. Convention: a `*Hash = "sha256-..."` attribute in `pkgs/<name>/default.nix`. Use `nix run .#update-hashes -- <name>` to force a package after external hash drift.

Resolving a pub lock realises a multi-gigabyte Flutter SDK, so `scripts/ci/update-packages.sh` drops the SDK each `pubspec.lock` provider names right afterwards — `gc-store` roots every package's build closure, so an SDK left behind would ride the shared store cache from then on.

## Adding a package

Commit `pkgs/<name>/source.ts` together with its `default.nix`. `packageDirs` in `internal/discover.nix` keeps a package whose `source.ts` has no `source.nix` yet out of the package set, and the next update run generates its source and lockfiles; from then on `discover.nix` passes the generated `source.nix` to the package as `source`.

## Failure handling

`update-sources` exits on the first definition that fails, before `update-hashes` runs, so the workflow commits nothing from that run. Reproduce on Linux with `nix run .#update-sources -- <name>`; nix-repin builds for Linux only.
