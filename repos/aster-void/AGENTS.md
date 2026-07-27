# Repository Guidelines

## Project Structure & Module Organization

```
.
├── flake.nix          # flake entry
├── flake.lock         # dependency pins
├── AGENTS.md          # AI agent instructions
├── packages/
│   └── <name>/
│       ├── default.nix   # thin wrapper
│       └── package.nix   # build logic
├── modules/
│   ├── home/*.nix     # Home Manager modules
│   └── nixos/*.nix    # NixOS modules
└── docs/              # user docs; update when behavior changes
```

## Scripts

```sh
# Enter dev shell
# No action required, automatically done via .envrc

# Format all files
treefmt

# Build a package
nix build .#<name> # example: nix build .#osgrep
```

## Coding Style & Naming Conventions

- Naming: directories/attrs use kebab‑case (e.g., `osgrep`); keep `default.nix` thin; put logic in `package.nix`.
- One package per folder; modules end with `.nix` and expose options under clear namespaces (e.g., `programs.osgrep`).
- package's name should usually follow their executable name:
  - e.g. when something exposes an excutable as `ruv-swarm` then `pname = "ruv-swarm";` at `./packages/ruv-swarm`

## Testing Guidelines

- No dedicated unit test framework. Validate by building:
  - `nix build .#<name>` for packages
  - For modules, smoke‑test in a throwaway HM/NixOS config.
- Keep derivations reproducible. avoid "latest" tags and URLs.
- do not spam read BashOutput. if it failed at least 3 times, ask the user for what to do next.

## Commit & Pull Request Guidelines

- Commit style: imperative, lowercase; scope prefix.
  - Examples: `packages: init osgrep`, `packages/osgrep: fixed XXX`, `modules: init osgrep`, `gh action: update cachix`

## Nix Knowledge

- You must `git add` new files so that flake can see it.

## Packaging Examples

- [Go](docs/internal/example-go.md) - `buildGoModule`
- [Rust](docs/internal/example-rust.md) - `buildRustPackage`
- [JavaScript](docs/internal/example-javascript.md) - npm, pnpm, bun
- [meta field](docs/internal/example-meta.md) - always see

## Packaging Workflow

### 1. Create package directory

```sh
mkdir -p packages/<name>
```

### 2. Read the appropriate example

- [Go](docs/internal/example-go.md) - `buildGoModule`
- [Rust](docs/internal/example-rust.md) - `buildRustPackage`
- [JavaScript](docs/internal/example-javascript.md) - npm, pnpm, bun
- [meta field](docs/internal/example-meta.md) - always see

### 3. Create files

- `packages/<name>/default.nix` - thin wrapper calling `package.nix`.
  - usually just `{pkgs}: pkgs.callPackage ./package.nix {}`, unless package requires specific versions of toolchain.
  - when it does, it will become something like `{pkgs}: pkgs.callPackage ./package.nix { nodejs = nodejs_24; }`
- `packages/<name>/package.nix` - build logic (copy from example, adjust)

### 4. Build and fix hashes

```sh
git add packages/<name>  # required for flake to see new files
nix build .#<name>       # will fail with hash mismatch
# copy correct hash from error message, update package.nix, repeat
```

### 5. Commit

```sh
git add packages/<name>
git commit -m "packages: init <name>"
```

### 6. (Optional) Add to auto-update

Add entry to `auto-update.json` for automatic version updates:

```json
{
  "packages": [
    { "name": "my-package" },
    { "name": "my-package", "nixAttr": "my-package.unwrapped" },
    { "name": "my-package", "method": "custom" }
  ]
}
```

Options:

- `name` (required): package directory name
- `nixAttr`: nix attribute to update (default: `name`)
- `buildAttr`: nix attribute to build (default: `name`)
- `method`: `"nix-update"` (default) or `"custom"`

### Optional scripts in package directory

- `update.sh` - custom update script (when `method: "custom"`)
- `check.sh` - post-build verification (runs after successful build)

## JavaScript Package Size Optimization

To reduce package size, use `bun build --minify` to bundle JS/TS into a single file:

### For packages WITHOUT native modules

```nix
buildPhase = ''
  bun build src/index.ts --outfile build/app.js --target node --minify
'';

installPhase = ''
  mkdir -p $out/share/<name> $out/bin
  cp build/app.js $out/share/<name>/
  makeWrapper ${lib.getExe nodejs} $out/bin/<name> \
    --add-flags "$out/share/<name>/app.js"
'';
```

Use `--target bun` if the package can run on bun runtime (smaller closure).

### For packages WITH native modules (better-sqlite3, duckdb, etc.)

Native modules cannot be bundled. Instead, clean up node_modules:

```nix
installPhase = ''
  cp -r node_modules $out/libexec/<name>/

  # Clean up to reduce size
  find $out/libexec/<name>/node_modules -type d -name obj.target -prune -exec rm -rf {} +
  find $out/libexec/<name>/node_modules -name '*.o' -delete
  find $out/libexec/<name>/node_modules -name '*.a' -delete
  find $out/libexec/<name>/node_modules -type d -name 'test' -prune -exec rm -rf {} +
  find $out/libexec/<name>/node_modules -type d -name 'tests' -prune -exec rm -rf {} +
  find $out/libexec/<name>/node_modules -type d -name 'docs' -prune -exec rm -rf {} +
  find $out/libexec/<name>/node_modules -name '*.md' -delete
  find $out/libexec/<name>/node_modules -name '*.map' -delete
'';
```
