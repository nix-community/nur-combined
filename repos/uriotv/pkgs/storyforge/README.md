# Story Forge

Source build of Story Forge 2.0.8 for Linux, independent of the upstream flake.
The package works through both the NUR package set and the repository overlay.
No StoryForge or bun2nix flake input is required.

```sh
nix build .#storyforge
nix run .#storyforge
```

## Dependency handling

- `bun.nix` is generated locally with bun2nix 2.1.2, including all five
  `@dnd-kit/*` packages missing from the upstream generated manifest.
- `bun-support.nix` adapts the vendored cache/hook modules in `bun-support/`
  from bun2nix commit `0456acb1b7394fc14c414b056aa889df5124943a` (MIT).
  It does not evaluate either upstream flake or import their nixpkgs. The adapter
  uses this repository's package set. Only the Zig cache helper is built from a
  hash-pinned source fetched at build time, not during evaluation.
  The vendored `cache-entry-creator.nix` is adjusted to use that source and the
  local `cache-entry-deps.nix`; other vendored files are unchanged.
- `Cargo.lock` is copied from the pinned StoryForge source so evaluation does
  not need import-from-derivation. The Rust setup hook checks its consistency.
- The pinned nixpkgs Bun 1.3.13 rejects the upstream lockfile version 2. The
  package patches the header to the compatible version 1 without changing any
  resolutions, and aligns the `better-auth` requirement with the lockfile's
  workspace declaration. The resolved version remains 1.7.7.
- Both Bun install phases use `--offline --frozen-lockfile`. Dependencies are
  fetched by hash-checked Nix fetchers before the network-isolated build.

The build includes upstream Rust tests. Building the launcher does not verify
logging in, downloading game files or running Vintage Story. Game files and
runtime setup remain separate from the launcher package.

## Manual updates

Updates are deliberately manual: source, Cargo lock, Bun manifest and any
compatibility patches must be reviewed together.

1. Update `version`, `src.rev` and `src.hash` in `default.nix`.
2. Copy `src-tauri/Cargo.lock` from that exact source to this directory.
3. From a checkout of that exact source, regenerate the manifest:

   ```sh
   nix run github:nix-community/bun2nix/0456acb1b7394fc14c414b056aa889df5124943a#bun2nix -- \
     -l bun.lock -o /path/to/urio-nur/pkgs/storyforge/bun.nix
   ```

4. Review the lockfile compatibility patches. If changing the generator, update
   the bun2nix source pin/hash/version in `bun-support.nix`, refresh the vendored
   modules (preserving the cache helper path adjustments), and review the adapter.
5. Build with sandboxing and IFD disabled:

   ```sh
   nix build .#storyforge --no-link \
     --option sandbox true --option allow-import-from-derivation false
   ```

When testing untracked package files, use `path:.#storyforge` instead of
`.#storyforge` so the flake includes those files without staging them.
