---
name: nur-packager
description: Package projects (GitHub repos, npm packages, curl scripts, release binaries) into NUR derivations. Analyzes the project, selects the best packaging strategy, creates the nix derivation, registers it, and tests the build.
license: MIT
metadata:
  author: lmdevv
  version: "1.0.0"
---

# NUR Packager

Package projects into Nix User Repository (NUR) derivations end-to-end.

## Workflow

1. **Analyze** the input (URL, package name, GitHub repo) to determine what it is and how it distributes releases
2. **Select** the packaging strategy (npm source build, binary release, GitHub source build, etc.)
3. **Create** the derivation under `pkgs/<name>/default.nix` and register it in the repo root `default.nix`
4. **Test** the build with `nix build` and verify the result works
5. **Automate** updates with a script and GitHub Actions workflow if applicable

## Strategy Selection

| Input Type | Strategy | Rule File |
|---|---|---|
| npm/node package on registry | `buildNpmPackage` or `node2nix` | [npm-packaging](rules/npm-packaging.md) |
| GitHub repo with release binaries | Multi-platform `fetchurl` + hashes | [binary-release](rules/binary-release.md) |
| GitHub repo with source builds | `buildGoModule`, `buildRustPackage`, etc. | [github-source](rules/github-source.md) |
| Curl script / direct download | Extract API, fetch per-platform hashes | [binary-release](rules/binary-release.md) |
| AppImage + DMG | `appimageTools` / `undmg` | [binary-release](rules/binary-release.md) |

## Quick Reference

| Step | Command |
|---|---|
| Analyze project | Read README, check releases, inspect package.json |
| Create derivation | `pkgs/<name>/default.nix` |
| Register package | Add `name = pkgs.callPackage ./pkgs/name { };` to root `default.nix` |
| Build | `nix build .#<name>` |
| Build (unfree) | `NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#<name>` |
| Test binary | `./result/bin/<name> --help` |
| Format check | `nix fmt -- --check` (if alexnix/fmt or nixfmt is configured) |
| Prefetch hash | `nix store prefetch-file --json <url>` |

## Repo Conventions

- Each package lives in `pkgs/<name>/default.nix`
- Register with `pkgs.callPackage ./pkgs/<name> { }` in root `default.nix`
- Update scripts go in `scripts/update-<name>.sh` or `pkgs/<name>/update.sh`
- GitHub Actions workflows for auto-updates go in `.github/workflows/update-<name>.yml`
- All multi-platform binary packages use `sha256BySystem` or `sources` attrsets
- Maintainer field: `maintainers = [ "lmdevv" ]`
- Meta fields: `description`, `homepage`, `license`, `platforms`, `mainProgram`

## Related Skills

- **nix-packaging-best-practices**: Binary packaging details (autoPatchelfHook, dependencies, FHS env)
- **nix-best-practices**: Flake structure, overlays, unfree handling
- **nix**: Running packages, evaluating expressions, troubleshooting

## Rule Files

| Topic | File |
|---|---|
| Analyzing a project | [analyze-project](rules/analyze-project.md) |
| Node.js/npm packaging | [npm-packaging](rules/npm-packaging.md) |
| Binary release packaging | [binary-release](rules/binary-release.md) |
| GitHub source builds | [github-source](rules/github-source.md) |
| Creating and registering derivations | [create-derivation](rules/create-derivation.md) |
| Testing builds | [testing](rules/testing.md) |
| Update automation | [update-automation](rules/update-automation.md) |

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`