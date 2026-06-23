# AGENTS.md

Personal NUR (Nix User Repository) at `github.com/teformel/nur-packages`. Hosts LingmoOS desktop packages plus a few standalone apps.

## Building

- **Cannot build on Windows.** Use a NixOS machine (developer uses a VM at `192.168.70.128`, user `maorila`, SSH key `~/.ssh/id_ed25519`).
- Evaluate all packages: `nix flake check --no-build` (fast, catches eval errors)
- Build a single package on the NixOS host: `nix build .#<name> --no-link`
- CI builds via `nix-build-uncached ci.nix -A cacheOutputs`; `ci.nix` filters out `meta.broken` and non-free packages.

## Architecture: three nixpkgs tiers

`default.nix` imports three different nixpkgs instances. Do not collapse them:

| Tier | Symbol | nixpkgs | Packages |
|---|---|---|---|
| Latest | `pkgs` | flake input (`nixpkgs-unstable`) | `clash-party`, `ww-manager`, `lingmo-sddm-theme` |
| KF5 / Qt5 | `pkgsKF5` | pinned `600b15aea1b3...` (2024-04-07) | `lingmo-desktop`, `lingmo-daemon`, `lingmo-screenlocker` |
| Qt6 / KF6 | `pkgsQt6Legacy` | same pinned commit | `lib_lingmo`, `lingmoui`, `lingmo-core`, + 7 dependents |

The pinned commit (`600b15aea1b36eeb43833a50b0e96579147099ff`) is shared by both `pkgsKF5` and `pkgsQt6Legacy`. **Do not bump it without rebuilding every LingmoOS package** — upstream is pinned to Qt 6.6 / KF 6.0 APIs and breaks on newer nixpkgs (Qt 6.11 removed private headers; KScreen 6.6 removed `isPrimary`/`setPrimaryOutput`).

### LingmoOS Qt6 dependency chain

Build order matters. The base libraries must build before dependents:

```
lib_lingmo ─┐
lingmoui ────┼─→ lingmo-core ─→ {lingmo-settings, lingmo-dock, lingmo-launcher,
                                 lingmo-filemanager, lingmo-kwin-plugins,
                                 lingmo-polkit-agent, lingmo-statusbar}
```

All Qt6 LingmoOS packages take `{ qt6 = pkgsQt6Legacy.kdePackages; ... }` so Qt versions stay unified.

## Nix packaging quirks (hard-earned)

- **Source hash ritual**: New LingmoOS packages have `# TODO: 首次构建将报错，请将报错提供的 Hash 填入此处` comments. Run the build, copy the `got: sha256-...` from the error into `hash = `, repeat. See `lingmo-polkit-agent` for the fixed pattern.
- **`lib_lingmo` needs both C++20 flags**: `cmakeFlags` sets `CMAKE_CXX_STANDARD=20` but the upstream `CMakeLists.txt` has `set(CMAKE_CXX_STANDARD 17)` which shadows the cache var. The `env.CXXFLAGS = "-std=c++20"` line is load-bearing — libkscreen headers need C++20. Do not remove it thinking cmakeFlags alone suffices.
- **`lingmoui` postPatch — do NOT globally replace `::GuiPrivate`**: An earlier `sed 's/::GuiPrivate/::Gui/g'` broke Qt6 private header include paths (`qxkbcommon_p.h`, `qtx11extras_p.h`). The current fix only deletes the offending `find_package(Qt6 COMPONENTS GuiPrivate)` line in `thirdparty/QHotkey/CMakeLists.txt`. If you see private-header build errors in lingmoui, check whether someone re-added the global sed.
- **Hardcoded install paths**: LingmoOS upstreams hardcode `/usr/` and `/etc/` in CMakeLists. Every LingmoOS package has a `postPatch` rewriting these to relative paths. Copy the pattern from `lingmo-sddm-theme` when adding new packages.
- **QML install dir interception**: lib_lingmo and lingmoui override `ecm_query_qt(INSTALL_QMLDIR ...)` / `query_qmake(...)` to force `${CMAKE_INSTALL_PREFIX}/lib/qt-6/qml`. Keeps QML plugins inside the nix sandbox.
- **`lingmo-core` python shebang**: `lingmo-wallpaper-color-pick` gets a patched shebang embedding `python3.withPackages([dbus-python pillow opencv4 scipy numpy])`. Update the package list there if the script's imports change.
- **`lingmo-core` exposes a session**: `passthru.providedSessions = [ "lingmo-xsession" ]` for NixOS display-manager auto-discovery.

## CI

- `nurRepo: teformel` in `.github/workflows/build.yml`. Matrix runs against `nixpkgs-unstable`, `nixos-unstable`, `nixos-25.11`.
- No cachix. Don't add cachix steps without a signing key in repo secrets.
- The "Trigger NUR update" step has an inverted guard (`!= 'teformel'`) that is always false — it never fires. This is a known template artifact, not a bug to "fix".
- **Pushing workflow changes requires a PAT with `workflow` scope.** The current developer token lacks it; workflow edits stay local until the token is updated.

## flake.lock

The committed `flake.lock` pins nixpkgs to `600b15aea1b3` (2024-04-07) — the same commit as the pinned tarballs. This is intentional: it keeps `nix flake check` reproducible against the same nixpkgs the LingmoOS packages expect. Running `nix flake update` will bump it to latest nixpkgs-unstable and is fine for the standalone packages, but the LingmoOS packages will still import their own pinned nixpkgs regardless of the flake input.

## Repo conventions

- Comment style: Chinese comments are common in `default.nix` and package `postPatch` blocks. Match the surrounding language.
- `version = "main"` for LingmoOS packages means they track a pinned upstream commit (not a release tag). Bump `rev` + `hash` together when updating.
- Standalone apps (`clash-party`, `ww-manager`) use real semver versions.
- Mark packages that can't build with `meta.broken = true` — CI skips them.
