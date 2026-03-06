# AGENTS.md — Coding Agent Guide for nur-packages

This is a personal [NUR (Nix User Repository)](https://nur.nix-community.org/)
containing Nix package definitions. The entire codebase is written in the Nix
expression language, with a few shell helper scripts.

## Build Commands

```sh
# Build a single package (the primary workflow)
nix-build -A <package-name>
# Example: nix-build -A gloc

# Build using flakes
nix build .#<package-name>

# Evaluate all packages without building (quick syntax/type check)
nix-env -f . -qa \* --meta --xml --allowed-uris https://static.rust-lang.org

# Run the full CI evaluation (what GitHub Actions does)
nix-build ci.nix -A buildOutputs
```

There are no separate lint, test, or format commands. Correctness is verified
entirely through `nix-build`. If a package builds successfully, it is correct.

## Auto-update a Package

```sh
# Bump a package to its latest GitHub release (fetches version, updates hashes, commits)
_scripts/autoupdate <package-name>

# Only recompute hashes without checking for new versions
_scripts/autoupdate --skip-update <package-name>
```

The autoupdate script relies on `meta.homepage` pointing to a GitHub repository.

## Project Structure

```
default.nix          # Package registry — the single source of truth
flake.nix            # Thin flake wrapper over default.nix
ci.nix               # CI filtering logic (buildable, cacheable)
overlay.nix          # Nixpkgs overlay entry point
pkgs/<name>/default.nix  # Individual package definitions
_scripts/            # Shell automation (autoupdate, bump-firefox)
templates/           # Nix flake templates (go, generic, simple)
lib/                 # Library functions (placeholder)
modules/             # NixOS modules (placeholder)
overlays/            # Additional overlays (placeholder)
```

## Adding a New Package

1. Create `pkgs/<package-name>/default.nix` with the derivation.
2. Register it in `default.nix` under the appropriate section comment:
   ```nix
   package-name = pkgs.callPackage ./pkgs/package-name { };
   ```
3. Verify with `nix-build -A package-name`.

Always use `pkgs.callPackage` with an empty override set `{ }`. Never pass
overrides at the top level. Never import `<nixpkgs>` inside a package file —
all dependencies come via `callPackage` injection.

## Code Style

### Formatting

- 2-space indentation, no tabs.
- Line length generally under 100 characters.
- Opening `{` on the same line; closing `}` on its own line.
- One blank line between logical groups of attributes.
- Short lists inline: `[ "-s" "-w" ]`. Long lists one-per-line.
- Use `rec` on the same line as the builder: `buildGoModule rec {`.

### Function Arguments (package inputs)

Preferred style (trailing comma, one per line):

```nix
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
```

Older packages may use single-line `{ lib, buildGoModule, fetchFromGitHub }:`
or leading-comma style. When editing existing packages, match the file's
current style. For new packages, use the trailing-comma style above.

### Package Definition Pattern

**Go:**
```nix
buildGoModule rec {
  pname = "example";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "...";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-...";
  };

  vendorHash = "sha256-...";
  ldflags = [ "-s" "-w" ];

  meta = {
    description = "...";
    homepage = "https://github.com/...";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "example";
  };
}
```

**Rust:**
```nix
rustPlatform.buildRustPackage rec {
  pname = "example";
  version = "1.0.0";

  src = fetchFromGitHub { ... };
  cargoHash = "sha256-...";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  doCheck = false;

  meta = { ... };
}
```

**Python:**
```nix
python3Packages.buildPythonPackage rec {
  pname = "example";
  version = "1.0.0";
  format = "pyproject";

  src = fetchFromGitHub { ... };
  propagatedBuildInputs = with python3Packages; [ ... ];

  meta = { ... };
}
```

### Naming Conventions

- Package attribute names use **kebab-case**: `gh-issues-to-rss`, `html-to-markdown`.
- `pname` must match the attribute name in `default.nix` and the directory name under `pkgs/`.
- Directory structure: `pkgs/<pname>/default.nix`.

### Source and Hash Conventions

- Use `fetchFromGitHub` for all GitHub-hosted sources.
- Use SRI-format hashes: `hash = "sha256-...";` (preferred) or `sha256 = "sha256-...";`.
- For Go: use `vendorHash`. For Rust: use `cargoHash`.
- `rev` field: use `"v${version}"` if upstream tags have a `v` prefix, otherwise `version` directly.
- To recompute hashes during development, temporarily set the hash to `lib.fakeSha256` and build. The error output will contain the correct hash.

### Meta Attributes

Required fields: `description`, `homepage`, `license`.
Recommended fields: `maintainers`, `mainProgram`.

- `homepage` should be a GitHub URL (the autoupdate script depends on this).
- Personal packages typically use `lib.licenses.asl20` (Apache 2.0).
- Use `lib.` prefix style (not `with lib;`) in `meta` for new packages.

### Disabling Packages

Comment out the line in `default.nix` with `#`. Leave the `pkgs/<name>/`
directory in place as historical reference.

## Version Control

The repository uses **Jujutsu (jj)** as a Git-compatible VCS frontend.

### Commit Message Format

```
<package-name>: <description>
```

Examples:
- `esa: v0.2.0 -> v0.3.0` (version bump)
- `prr: init at 0.17.0` (new package)
- `html-to-markdown: init at 2.3.0` (new package)
- `gloc: recompute` (hash update only)

## CI/CD

- GitHub Actions builds all non-broken, free-licensed packages on push/PR.
- Tests against `nixos-unstable`, `nixpkgs-unstable`, and `nixos-24.11`.
- Built artifacts are cached via [Cachix](https://meain.cachix.org).
- Packages are marked unbuildable via `meta.broken = true`.
- The CI entry point is `ci.nix`, which imports `default.nix` and filters
  packages by `meta.broken`, `meta.license.free`, and `preferLocalBuild`.
