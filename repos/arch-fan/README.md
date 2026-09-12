# nur-packages

Personal NUR-style package set (flake, `x86_64-linux`).

## Packages

| Package | Description |
| --- | --- |
| `crunchyroll` | Desktop entry launching Crunchyroll as a Chromium `--app` window (WideVine enabled) |
| `limusic` | [Limusic](https://github.com/SimoHypers/limusic): native desktop YouTube Music client (Tauri, ad-free playback via libmpv), wrapped from the upstream AppImage |

## Use

```console
nix run .#limusic
```

As a flake input (NixOS example):

```nix
environment.systemPackages = [
  inputs.nur-packages.packages.x86_64-linux.limusic
  inputs.nur-packages.packages.x86_64-linux.crunchyroll
];
```

## Updates

A scheduled workflow (`.github/workflows/update.yaml`, nightly + manual dispatch)
runs `nix run .#update` and opens a **single** PR (`updates/packages`) if anything
changed. The app (`scripts/update.sh`) assumes CI conditions — repo root as working
directory, `nix-update` on `PATH` via the app's `runtimeInputs` — and updates every
directory in `pkgs/`, skipping any package containing a `no-auto-update` file.

Conventions:

- **Normal packages** need nothing special: `nix-update --flake <name>` finds
  `packages.x86_64-linux.<name>`, compares against upstream releases, and rewrites
  `version` + `hash` in `pkgs/<name>/default.nix`. Keep the fetch URL interpolating
  `${version}` so the bump is a two-line diff.
- **Per-package flags** (e.g. `--version-regex`, `--url`, `--version=branch`) go in
  the derivation itself, the nixpkgs-idiomatic way:

  ```nix
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  ```

  The app passes `-u`, which runs `passthru.updateScript` when present and falls
  back to the default behavior otherwise — so no workflow change is needed.
- **Opting out**: a package nix-update cannot evaluate (no `version`, e.g. the
  hand-rolled `crunchyroll` desktop entry) cannot be skipped from inside nix-update —
  not even with `--version skip`, which is honored only *after* successful evaluation.
  For those, add `pkgs/<name>/no-auto-update` containing the reason; the app skips
  the package before invoking nix-update.
