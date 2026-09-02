# AGENTS.md

Personal [NUR](https://github.com/nix-community/NUR) flake (`nur.repos.xyenon`).
Nix package set plus NixOS / Home Manager modules and overlays.

## Commands

- **Build a top-level package**: `nix build .#<package>` (e.g. `nix build .#caddy`)
- **Build a nested package**: `nix build .#<set>.<name>` (e.g. `nix build .#yaziPlugins.ouch`) or `nix-build -A <set>.<name>`
- **CI-style build**: `nix run nixpkgs#nix-fast-build -- --no-nom --skip-cached --file ci.nix -A cacheOutputAttrs`
- **Format / lint**: `nix fmt` (treefmt: deadnix, statix, nixfmt, jsonfmt, shellcheck, shfmt, stylua, taplo, toml-sort, yamlfmt, rubocop)
- **Update sources**: `./scripts/update.sh` (nvfetcher + nixpkgs `update.nix` / `passthru.updateScript`)
- **Flake lock**: `nix flake update --commit-lock-file`
- **Eval (flake attrs)**: `nix eval .#packages.x86_64-linux --apply builtins.attrNames`
- **Eval (NUR CI)**:

  ```bash
  nix-env -f . -qa '*' --meta --xml \
    --allowed-uris https://static.rust-lang.org \
    --option restrict-eval true \
    --option allow-import-from-derivation true \
    --drv-path --show-trace \
    -I nixpkgs="$(nix-instantiate --find-file nixpkgs)" \
    -I "$PWD"
  ```

Flake `packages` is only top-level derivations. Nested sets (`yaziPlugins`, `mpvScripts`, `nginxModules`, `catppuccin`) live on `legacyPackages` and in `default.nix`. New files must be `git add`ed before `nix build` (flakes ignore untracked files).

## Layout

- `default.nix` — NUR entry; `callPackage` every package here. Do not import `<nixpkgs>` except as the default `pkgs` argument.
- `flake.nix` — `legacyPackages` / `packages` / `cacheOutputAttrs` / `nixosModules` / `homeModules` / `overlays` / `formatter`.
- `pkgs/<name>/default.nix` — package derivations.
- `nixos-modules/` — NixOS modules; `home-modules/` — Home Manager modules.
- `overlay.nix` — full overlay: every NUR attr except reserved names (`lib`, `overlays`, `nixosModules`, `homeModules`, `darwinModules`, `flakeModules`). Attrsets that already exist in nixpkgs (`nginxModules`, `mpvScripts`, …) are merged.
- `overlays/` — named flake overlays; each pulls one package from `prev.nur.repos.xyenon` (NUR overlay must be applied first).
- `lib/` — extra `lib` functions (currently unused).
- `nvfetcher.toml` → `_sources/generated.nix` — generated; never edit `_sources/` by hand.
- `ci.nix` — buildable/cacheable outputs. Skips `meta.broken`, unfree, and `preferLocalBuild`.
- `treefmt.nix` — formatter config; `_sources/**` excluded.
- `scripts/update.sh` — scheduled updater.

## Packages

Wire a new package in `default.nix` with `callPackage` (or `kdePackages.callPackage` when matching existing KDE packages). Nested sets use `lib.makeScope` + `lib.recurseIntoAttrs`.

```nix
foo = callPackage ./pkgs/foo { };
bar = callPackage ./pkgs/bar { inherit sources; };
# nested example: pkgs/yazi/plugins/default.nix, pkgs/catppuccin/default.nix
```

Prefer `__structuredAttrs = true`. Prefer `buildXxx (finalAttrs: { ... })` over `rec` when the derivation self-references `version` / `src`.

Every derivation needs `meta` with at least `description`, `homepage`, `license`, and `maintainers = with lib.maintainers; [ xyenon ];`. Add `platforms`, `mainProgram`, `changelog`, or `broken` when they apply. `ci.nix` will not cache broken, unfree, or `preferLocalBuild` packages.

Custom `installPhase` / other phases must call `runHook preInstall` / `runHook postInstall` (and the matching hooks for that phase).

## Sources and updates

Two update paths; pick one and match nearby packages.

1. **nvfetcher** — add an entry in `nvfetcher.toml`, consume `sources.<name>` in the derivation. Used for caddy plugins, catppuccin themes, rime dictionaries, nh, yazi-rs plugins.
2. **`passthru.updateScript`** — inline `fetchFromGitHub` / `fetchFromCodeberg` and let nixpkgs `update.nix` run:
   - tagged releases: `nix-update-script { }`
   - git HEAD: `nix-update-script { extraArgs = [ "--version=branch" ]; }`
   - some git packages use `unstableGitUpdater` instead

`./scripts/update.sh` runs nvfetcher (`-k ~/.config/nvchecker/keyfile.toml`) then nixpkgs `maintainers/scripts/update.nix` with `overlay.nix`, committing changes. After nvfetcher it also:

- rewrites `pkgs/caddy/default.nix` `hash` via ast-grep + nurl (plugin FOD)
- regenerates `pkgs/yazi/plugins/yazi-rs/plugins.json` from `yaziPlugins.yazi-rs.passthru.generate`

Do not hand-edit those generated hashes / JSON except to unblock a rebuild the same way the script does.

Caddy plugins: add a `nvfetcher.toml` source with `passthru.isCaddyPlugin = "true"` and `passthru.moduleName = "github.com/…"`, plus `git.date_format` / `git.date_tz` like the existing plugin entries.

## Modules and overlays

- Register NixOS modules in `nixos-modules/default.nix`, Home Manager modules in `home-modules/default.nix`.
- Package options typically use `lib.mkPackageOption pkgs "nur.repos.xyenon.<pkg>" { }` (or `lib.mkPackageOption pkgs.nur.repos.xyenon "<pkg>" { }`).
- Named overlay: `overlays/<name>/default.nix` as `_final: prev: { inherit (prev.nur.repos.xyenon) <name>; }` and list it in `overlays/default.nix`.

## Style

- Nix: `nixfmt`; no unused bindings (`deadnix`); no statix anti-patterns. Do not add comments unless they document a non-obvious constraint.
- Shell: `shfmt` with tabs (`indent_size = 0`) and `shellcheck`. `update.sh` uses `#!/usr/bin/env nix-shell` shebangs.
- Follow existing `callPackage` / overlay / module patterns instead of inventing a parallel layout.

## Commits

Follow [nixpkgs commit conventions](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#commit-conventions). One commit per logical unit; squash fixup/"forgot" commits. No period at the end of the subject. After the colon, use lowercase (`init at`, `fix build`, not `Init at`). Do not use Conventional Commits (`feat:`, `chore:`, `fix:`).

```
(attr | nixos/<module> | home/<module>): (from -> to | init at version | refactor | etc)

(Motivation for change. Link to release notes. Additional information.)
```

Prefix is the **attribute path** (or module path), not the filesystem path. `->` and `→` are both fine.

| Kind | Subject |
| --- | --- |
| Version bump | `caddy: 2.11.3 -> 2.11.4` |
| Nested package | `yaziPlugins.ouch: 0.7.1-unstable-2026-08-18 -> 0.7.2-unstable-2026-08-20` |
| New package | `lazyrsync: init at 0.1.1` |
| Fix / refactor | `pleroma: fix beam package scope compatibility` |
| Several packages | `yaziPlugins.{clipboard,yafg}: fix build` |
| Remove | `kvrocks: remove` |
| NixOS module | `nixos/telemikiya: init` / `nixos/telemikiya: add bazBaz option` |
| Home Manager module | `home/zsh-smart-suggestion: init` |
| Overlay | `overlays/caddy: init` |
| Script | `scripts/update.sh: use nurl` |
| CI workflow | `ci: run scheduled package updates only on default branch` |
| Cross-cutting | `treewide: rename modules dir` |
| lib | `lib: expose nixpkgs lib` |

Version bumps may be a one-line subject. If there are release notes, put the URL in the body. Fixes and refactors need a body that says *why*.

Leave titles produced by automation as-is (`nix flake update --commit-lock-file` → `flake.lock: Update`; nvfetcher; Dependabot `build(deps): bump …`). When writing the commit yourself after a source update, use the attribute path (`yaziPlugins.yazi-rs: …`, not the nvfetcher key `yazi-rs-plugins:`).

Run `nix fmt` on touched files before committing. Do not push unless asked.

## CI

`.github/workflows/build.yml` builds on `ubuntu-latest`, `ubuntu-24.04-arm`, and `macos-latest` (nixpkgs-unstable + nixos-unstable for the channel job). It evaluates with `nix-env`, builds with `nix-fast-build` against `ci.nix` / `.#cacheOutputAttrs.<system>`, pushes to Cachix (`nur-xyenon`) and Attic, and pings the NUR registry on push.

`.github/workflows/update.yml` runs daily: weekly `nix flake update`, then `./scripts/update.sh`, force-pushes `auto-update`, and opens/updates the automated PR.
