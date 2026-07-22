# Repository Guidelines

## Project Structure & Module Organization

This repository is a personal Nix User Repository (NUR). Package definitions live in `pkgs/<package>/default.nix`; package-specific patches, lockfiles, and platform expressions stay beside that definition. Export every active package from the root `default.nix`. `overlay.nix` exposes those packages as a nixpkgs overlay, while `overlays/`, `modules/`, and `lib/` hold reusable overlays, NixOS modules, and helper functions. `ci.nix` selects buildable, cacheable outputs for CI. Automation is defined in `.github/workflows/`, and update helpers live in `scripts/` or the relevant package directory.

## Build, Test, and Development Commands

- `nix fmt` formats Nix files with the flake-provided `nixfmt` configuration.
- `nix flake check` evaluates flake outputs and catches structural errors.
- `nix build .#clock-tui` builds one exported package; replace `clock-tui` with the attribute being changed.
- `nix-build ci.nix -A cacheOutputs` builds the same cacheable output set used by CI.
- `nix-env -f . -qa '*' --meta --drv-path --show-trace` evaluates all repository packages without building them.
- `nix-shell -p nix-update --run "nix-update clock-tui"` updates a package that uses a standard `passthru.updateScript`.

## Coding Style & Naming Conventions

Use two-space indentation and let `nix fmt` determine Nix layout. Name package directories and exported attributes with lowercase kebab-case, such as `git-credential-1password`. Keep `pname`, `version`, source hashes, `passthru`, and `meta` explicit. Use nixpkgs helpers such as `fetchFromGitHub`, `callPackage`, and `lib.licenses` instead of custom fetching or metadata conventions. Keep platform-specific logic in separate files when it materially differs, as in `pkgs/proton-pass/{linux,darwin}.nix`.

## Testing Guidelines

There is no separate unit-test suite or coverage requirement. Treat evaluation and successful package builds as the required checks. Before submitting, run `nix fmt`, `nix flake check`, and build each changed package. For platform-specific changes, verify every available target or clearly document untested platforms in the pull request.

## Commit & Pull Request Guidelines

Follow the concise history style: package-scoped subjects such as `proton-pass: init at v1.37.0` or imperative maintenance subjects such as `Bump package version`. Keep each commit focused. Pull requests should explain the package or infrastructure change, list verification commands, and link the upstream release or issue when relevant. Include screenshots only for changes where visual behavior is meaningful, and call out hash, license, platform, or unfree-package changes explicitly.
