# AGENTS.md - Zerozawa's NUR Repository

This repository is a **Nix User Repository (NUR)** with package definitions, a small library surface, CI filtering logic, and local `.opencode` command/skill metadata.

## Source of Truth

When updating code or documentation, treat these files as authoritative:

- `default.nix` - exported packages plus reserved attrs `lib`, `modules`, `overlays`
- `lib/default.nix` - exported library helpers (currently `fetchPixiv`)
- `flake.nix` - flake outputs (`legacyPackages`, filtered `packages`)
- `ci.nix` - CI build/cache filtering rules
- `modules/default.nix` - current modules namespace (placeholder)
- `overlays/default.nix` - current overlays namespace (placeholder)
- `.opencode/command/*.md` - repo-local OpenCode command docs
- `.opencode/skill/nix-packaging/SKILL.md` - repo-local Nix packaging skill
- `.opencode/opencode.jsonc` - OpenCode config and remote `context7` MCP setup

## Current Repository Shape

```text
nur/
├── default.nix              # main export surface
├── flake.nix                # flake outputs and cache config
├── ci.nix                   # CI package/output filtering
├── pkgs/                    # 22 exported package definitions
├── lib/                     # library helpers (currently fetchPixiv)
├── modules/                 # placeholder NixOS modules namespace
├── overlays/                # placeholder overlays namespace
└── .opencode/               # local command/skill/config metadata
```

## Current Exports

### Reserved attrs

- `lib`
- `modules`
- `overlays`

### Library helpers

- `fetchPixiv` - configurable Pixiv fetch helper with mirror and extension fallback

### Modules and overlays

- `modules/default.nix` currently exports `{ }`
- `overlays/default.nix` currently exports `{ }`

Do not document modules or overlays as active features unless they have been implemented.

## Package Inventory Summary

The repo currently exports 22 packages from `default.nix`, grouped roughly as:

- SR Vulkan ecosystem: `sr-vulkan` and four model packages
- Qt/Python readers: `JMComic-qt`, `picacg-qt`
- Media and streaming tools: `StartLive`, `bilibili_live_tui`, `lightnovel-crawler`, `mihomo-smart`
- MCP and developer tools: `agentic-contract`, `hyprland-mcp-server`, `mcp-cli`, `wechat-web-devtools-linux`
- Themes and utilities: `grub-theme-yorha`, `sddm-eucalyptus-drop`, `waybar-vd`, `zsh-url-highlighter`, `mikusays`, `fortune-mod-*`

Always derive exact package names from `default.nix`, not from README snippets or memory files.

## Common Build Patterns Actually Used Here

This repo is not limited to one packaging style. Examples worth following:

- `python3Packages.buildPythonApplication` / `buildPythonPackage`
  - Examples: `pkgs/JMComic-qt.nix`, `pkgs/picacg-qt.nix`, `pkgs/sr-vulkan.nix`
- `buildGoModule`
  - Example: `pkgs/mihomo-smart.nix`
- `rustPlatform.buildRustPackage`
  - Example: `pkgs/waybar-vd/default.nix`
- `buildNpmPackage`
  - Example: `pkgs/hyprland-mcp-server.nix`
- `bun` + `stdenvNoCC.mkDerivation`
  - Example: `pkgs/mcp-cli.nix`
- `stdenv.mkDerivation` / `stdenvNoCC.mkDerivation`
  - Example: `pkgs/grub-theme-yorha.nix`

## Repo-Specific Packaging Notes

### Export wiring

- Add new packages to `default.nix` with `pkgs.callPackage`.
- Add new library helpers to `lib/default.nix`.
- Reserved attrs `lib`, `modules`, and `overlays` are not normal package targets.

### CI behavior (`ci.nix`)

CI excludes reserved attrs and flattens derivations recursively when `recurseForDerivations = true`.

Filtering behavior:

- `meta.broken = true` -> excluded from CI builds
- unfree licenses -> excluded from build/cache sets
- `preferLocalBuild = true` -> buildable locally but excluded from cache set

### Flake behavior (`flake.nix`)

- `legacyPackages.<system>` imports `default.nix`
- `packages.<system>` filters derivations by platform compatibility
- `nixpkgs` is pinned to `nixpkgs-unstable`
- the flake config also publishes Cachix substituters and trusted keys

### Current implementation quirks worth remembering

- `JMComic-qt` and `picacg-qt` rely on `sr-vulkan-with-models`, not plain `sr-vulkan`
- `hyprland-mcp-server` is a wrapped npm package with runtime PATH injection for Hyprland tooling
- `fetchPixiv` intentionally uses `fetchurl` with ordered `urls` fallback rather than a single URL

## Quick Commands

```bash
# Build a package from default.nix
nix-build -A JMComic-qt

# Build from flake output
nix build .#mcp-cli

# Build what CI caches
nix-build ci.nix -A cacheOutputs

# Inspect flake outputs
nix flake show

# Check nixpkgs version in the current channel setup
nix-instantiate --eval -E '(import <nixpkgs> {}).lib.version'
```

## `.opencode` Inventory

### Commands

- `.opencode/command/build.md`
- `.opencode/command/check.md`
- `.opencode/command/commit.md`
- `.opencode/command/update.md`
- `.opencode/command/update-all.md`

These should stay aligned with real attr names from `default.nix` and real workflows from `ci.nix`, `flake.nix`, and package definitions.

### Skills

- `.opencode/skill/nix-packaging/SKILL.md`

This skill should stay grounded in the packaging styles actually present in this repo, not only generic nixpkgs examples.

### Config

- `.opencode/opencode.jsonc` configures the provider and a remote `context7` MCP server.
- `.opencode/package.json` currently depends on `@opencode-ai/plugin`.
- `.opencode/.gitignore` excludes local dependency and lockfile state.

## Documentation Maintenance Rules

Update docs when any of the following changes:

- package exports in `default.nix`
- library exports in `lib/default.nix`
- CI behavior in `ci.nix` or `.github/workflows/build.yml`
- flake outputs or cache settings in `flake.nix`
- local OpenCode commands, skills, or config under `.opencode/`

Specific expectations:

- `README.md` should describe the current export surface and user-facing usage.
- `AGENTS.md` should describe contributor/agent workflow and source-of-truth files.
- `.opencode/command/*.md` should describe current commands using actual attr names and workflows.
- `.opencode/skill/nix-packaging/SKILL.md` should reflect current repo packaging patterns.

## Common Pitfalls

1. **Documenting from memory instead of code**
   - Re-read `default.nix`, `lib/default.nix`, and `.opencode/` before editing docs.

2. **Treating placeholders as implemented features**
   - `modules` and `overlays` are currently empty placeholders.

3. **Using stale package lists**
   - Derive package names from `default.nix`, not from old README tables or update scripts.

4. **Forgetting CI/cache filters**
   - A package being exported does not automatically mean it is cacheable.

5. **Over-generalizing packaging guidance**
   - Match the builder and style already used by the closest package in this repo.
