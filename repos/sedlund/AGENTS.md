# AGENTS.md

## Scope

- This file applies to the entire repository.

## Repo Shape

- NUR package entrypoint: `default.nix`
- Flake entrypoint: `flake.nix` (uses `flake-parts`)
- Main package currently exported: `ghoten` (`pkgs/ghoten/default.nix`)

## Expectations

- Keep package expressions in nixpkgs style where possible.
- Keep `ghoten` on `buildGo126Module` unless explicitly changed.
- Preserve `flake.legacyPackages` output for NUR compatibility.
- Keep `treefmt-nix` and `git-hooks.nix` integration intact.

## Formatting and Hooks

- Formatter: `treefmt` (`nixfmt` + `prettier`)
- Pre-commit hooks are managed by `git-hooks.nix` in `flake.nix`.
- Conventional commit enforcement is enabled via `convco` (`commit-msg` stage).

## Dev Environment

- Direnv is enabled via `.envrc` (`use flake`).
- Default dev shell is exposed at `.#devShells.<system>.default`.

## CI Notes

- Workflow file: `.github/workflows/build.yml`
- Cron should remain in 5-minute increments and inside the documented random window.
