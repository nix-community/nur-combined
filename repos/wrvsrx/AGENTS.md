# Repository Guidelines

## Project Structure & Module Organization

This is a personal NUR-style Nix package repository. The root `flake.nix` exposes the overlay, packages, templates, formatter, and NixOS modules. Package expressions live in `pkgs/<name>/default.nix`; related patches stay beside the package, such as `pkgs/fcitx5-rime/restore-ascii.patch`. Shared overlays are under `pkgs/*-overlay/`, generated nvfetcher sources are in `pkgs/_sources/`, NixOS modules are in `nixos/modules/`, and starter flakes are in `templates/`. The `externals/` tree vendors external material and is excluded from normal formatting.

## Build, Test, and Development Commands

- `nix develop`: enter the shell with `nvfetcher`, `nix-update`, `treefmt`, `taplo`, and `nixfmt`.
- `nix flake check`: evaluate outputs and catch broken package/module wiring.
- `nix build .#<package>`: build one exported package, for example `nix build .#djot-tools`.
- `nix eval .#packages.x86_64-linux.<package>.version`: inspect an attribute without building.
- `treefmt`: format Nix and TOML files according to `treefmt.toml`.
- `nvfetcher`: refresh generated sources in `pkgs/_sources/` after editing `pkgs/nvfetcher.toml`.

## Coding Style & Naming Conventions

Use `nixfmt` for `*.nix` files and `taplo format` for TOML; both are run by `treefmt`. Keep Nix expressions small: prefer `callPackage`, explicit inputs, and package-local patches. Package directories and attributes should match existing lowercase or hyphenated names. Do not hand-edit `pkgs/_sources/generated.nix`; update source definitions and regenerate instead.

## Testing Guidelines

There is no separate test suite. For an isolated package change, run `nix build .#<package>` for each changed derivation; a full `nix flake check` is not required. Run `nix flake check` when changing shared package wiring, overlays, flake outputs, templates, or NixOS modules. For formatter-only changes, run `treefmt`. When changing overlays, build or evaluate an attribute from the affected set, such as `.#python3Packages.<name>`.

## Commit & Pull Request Guidelines

Recent history uses concise Conventional Commit-style messages with scopes, especially version bumps: `feat(pkgs/djot-tools): 0.17.0 -> 0.18.0`. Use `<type>(<scope>): <summary>`, with scopes such as `pkgs/<name>`, `nixos`, `templates`, or `flake`. Prefer `feat` for package additions and bumps, `fix` for corrections, `chore` for maintenance, and `docs` for docs-only changes. Keep the subject under about 72 characters and omit a trailing period. For version updates, write `old -> new`; for multi-part changes, add a short body explaining why. Pull requests should describe the changed package or module, list commands run, mention source regeneration, and link upstream releases or issues.

## Agent-Specific Instructions

Keep edits narrowly scoped. Avoid modifying vendored `externals/` content or generated source files unless the task explicitly requires it. Before changing a derivation, inspect its current build style and preserve local patterns.
