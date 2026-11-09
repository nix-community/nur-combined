# urio-nur

My personal [NUR](https://github.com/nix-community/NUR) repository: a few
packages, a CachyOS kernel, and a public binary cache at
[uriotv.cachix.org](https://uriotv.cachix.org).

[![Build and populate cache](https://github.com/urioTV/urio-nur/actions/workflows/build.yml/badge.svg)](https://github.com/urioTV/urio-nur/actions/workflows/build.yml)
[![Update packages](https://github.com/urioTV/urio-nur/actions/workflows/update.yml/badge.svg)](https://github.com/urioTV/urio-nur/actions/workflows/update.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-uriotv-blue.svg)](https://uriotv.cachix.org)

## Important: the cache is temporary

The cache runs on the **free Cachix plan**. It has a storage limit, and older
store paths can be removed to make room for newer ones. Nothing is kept forever.

- **Update regularly.** Run `nix flake update urio-nur` in your configuration
  every so often. A current lock points at packages that are most likely still
  cached.
- **Missing paths are not an error.** If a path has been removed, Nix builds it
  from source. That is slow for the kernels (roughly 1.5 hours on 8 cores).
- **Compare before you rely on it.** Substitution happens only when the exact
  derivation hash matches. For kernels, see [CachyOS kernels](#cachyos-kernels).

## Packages

Every package is checked for upstream updates daily, built in CI on
`x86_64-linux`, and published to the cache only if its license explicitly permits
redistribution.

| Package | Version | Description | Public cache |
|---|---|---|---|
| `lantern-engine` | `0.9.38` | Lantern Engine by Awaken, built from source (needs your own game dump) | Yes |
| `wordcraft` | `0.16.0` | Word processor (official binary release) | No: redistribution review pending |
| `gridcraft` | `0.17.0` | Spreadsheet editor (official binary release) | No: redistribution review pending |
| `deckcraft` | `0.16.0` | Presentation editor (official binary release) | No: redistribution review pending |
| `pdfcraft` | `0.19.0` | PDF viewer and editor (official binary release) | No: redistribution review pending |
| `photocraft` | `0.21.0` | Image editor (official binary release) | No: redistribution review pending |
| `filmcraft` | `0.18.0` | Video editor (official binary release) | No: redistribution review pending |
| `soundcraft` | `0.18.0` | Digital audio workstation (official binary release) | No: redistribution review pending |
| `meitou-launcher` | `1.9.0` | Source-built launcher that downloads Meitou versions (requires Kenshi) | Yes |
| `cybergrub2077` | `2.0.1-unstable-2026-02-28` | Cyberpunk 2077 inspired GRUB theme | Yes |
| `nmssaveeditor` | `1.21.0` | Save editor for No Man's Sky | No: unfree |
| `pig` | `0.7.0` | Pi coding agent rebuilt in Go as a native binary | Yes |
| `rimsort-appimage` | `1.17.4` | RimWorld mod manager | Yes |
| `scopebuddy` | `1.5.0` | Gamescope manager | Yes |
| `storyforge` | `2.0.11` | Story Forge desktop application, built independently of the upstream flake | Yes |
| `wowup-cf` | `2.25.4` | World of Warcraft addon manager with CurseForge support | Yes |
| `linux-cachyos-latest-x86_64-v3` | `7.3.1` | CachyOS kernel, x86-64-v3, non-LTO | Yes |

## Using the packages

```console
nix build github:urioTV/urio-nur#pig
nix run github:urioTV/urio-nur#pig
```

In a NixOS flake, add `urio-nur.url = "github:urioTV/urio-nur";` to your inputs and
apply the overlay:

```nix
{ pkgs, urio-nur, ... }: {
  nixpkgs.overlays = [ urio-nur.overlays.default ];
  environment.systemPackages = [ pkgs.pig pkgs.scopebuddy ];
}
```

The flake's `overlays.default` takes every registered package recipe from this
repository's `legacyPackages`, pinned by its `flake.lock`. Therefore package
`drvPath`s match the direct flake outputs and CI/cache regardless of the consumer's
nixpkgs, overlays, or package configuration. The `rimsort` compatibility alias
points to the pinned `rimsort-appimage` derivation.

The CachyOS `linuxPackages-*` convenience sets are the exception: they are built
with the consumer's `linuxPackagesFor` so out-of-tree modules match the consumer's
kernel package machinery, while the kernel derivations themselves remain pinned.
The ordinary NUR overlay (`urio-nur.overlays.unpinned`) is also available explicitly
for consumers who want recipes evaluated against their own nixpkgs. Direct flake
outputs (`urio-nur.packages.<system>.<name>`) use this repository's lock as well.

Do not set `inputs.nixpkgs.follows` on the `urio-nur` input. It replaces this
repository's nixpkgs with yours, which changes the kernel derivation and makes Nix
compile the kernel locally. The NUR `default.nix` overlay has no lock of its own and
always follows the consumer's nixpkgs.

### Enabling the cache

```nix
nix.settings = {
  extra-substituters = [ "https://uriotv.cachix.org" ];
  extra-trusted-public-keys = [ "uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI=" ];
};
```

Apply this once before building packages. The cache is public and read-only for
users; only the repository's `main` workflows can write to it.

### Meitou Launcher

`meitou-launcher` builds the launcher from C# sources, not an AppImage. Run
`nix run github:urioTV/urio-nur#meitou-launcher` to manage settings and download
official game versions. Downloads are upstream binaries managed by the launcher,
not built or updated by Nix; an FHS environment provides Linux compatibility on
NixOS. A legal Kenshi installation and a Vulkan-capable GPU are required.

The launcher's NuGet dependencies include prebuilt native libraries. The
launcher manages downloaded game binaries and their updates independently of Nix.

By default the launcher excludes Mesa's llvmpipe Vulkan driver: some Meitou
versions can rank this CPU renderer above an integrated GPU. Explicit Vulkan or
Mesa device selections are respected. To deliberately allow software rendering,
launch with `VK_LOADER_DRIVERS_DISABLE="" meitou-launcher`.

### ArtCraft applications

WordCraft, GridCraft, DeckCraft, PdfCraft, PhotoCraft, FilmCraft and SoundCraft
are packaged from upstream's official x86_64 Linux tarballs, not AppImages or
Flatpaks. Vulkan, Wayland/X11, ALSA and VA-API libraries are available at runtime;
actual GPU/video acceleration and audio devices depend on the host drivers.
These packages run without Flatpak's sandbox. Public Cachix publication is disabled
pending a review of the binaries' bundled assets and redistribution terms.

### Story Forge

Use `urio-nur.packages.${pkgs.system}.storyforge` or `pkgs.storyforge` after enabling
the overlay. No StoryForge flake input is needed.

```console
nix build .#storyforge
```

See [the package guide](pkgs/storyforge/README.md). Daily updates follow stable
releases and regenerate the Cargo/Bun artifacts together. The current snapshot is
kept until a strictly newer, descendant release exists.

## How CI works

Five workflows: one daily clock, one weekly lock update, and one branch that marks verified state.

| Workflow | When | What it does |
|---|---|---|
| `update.yml` "Update packages" | every day at **02:00 `Europe/Warsaw`** (IANA timezone, follows DST), or manually | Checks every registered package for a newer upstream version and updates its pin. Successful changes go into one `auto-update-packages` PR with squash auto-merge. |
| `build.yml` "Build and populate cache" | on PRs, on pushes to `main`, after a successful update run on `main`, or manually | Runs offline tests and Nix evaluation checks, then builds every eligible package on GitHub-hosted runners. On `main` it publishes eligible outputs to `uriotv` and verifies each `StorePath`. |
| `kernel.yml` "Build CachyOS kernel (self-hosted)" | on every push to `main`, after a successful update run, or manually | Builds the kernel from source on our self-hosted builder (or realises it when already published), then publishes it after a licence check. |
| `flake-update.yml` "Update flake.lock" | every **Sunday 03:00 `Europe/Warsaw`**, or manually | Updates every flake input in one PR with squash auto-merge. Kernels and packages then rebuild against the new lock. |
| `cache-branch.yml` "Update cache branch" | after the build or kernel workflow completes on `main`, or manually | Moves the `cache` branch to the current `main` commit, only when every cache publication for that commit succeeded. |
| `test-gate` (inside `build.yml`) | after every build run | Blocks merges unless the offline tests and package build both succeed. |

Details:

- **Registry:** `pkgs/<name>/default.nix` is the only place a package is listed.
  NUR, the overlay, the flake, CI and the updater discover it from there.
- **Builds:** every supported, non-broken package and all its outputs are built,
  including unfree packages. Packages with `meta.ciBuild = false` are built by
  their own workflow instead (the kernels).
- **Publication:** only from `main`, only for eligible outputs. Pull requests and
  the updater have no cache write token. A package is eligible when its licence
  explicitly allows redistribution. Unknown or empty licence metadata fails closed.
  See [the licence policy](docs/adding-packages.md#licenses-and-public-cache).
- **Kernel licence gate:** before the kernel is pushed, `scripts/check-kernel-closure.py`
  checks the whole runtime closure. Every path needs explicit licence evidence,
  and every path must be redistributable. Any gap blocks publication.
- **NUR notification:** after a successful publication, the workflow asks NUR to
  refresh. NUR rate-limits globally (HTTP 429). That is reported as a deferred
  notification, not a failure; NUR also refreshes on its own schedule.
- **Schedule:** GitHub can delay scheduled workflows, so the cron time is not a
  delivery guarantee.

Required repository secrets:

| Secret | Purpose |
|---|---|
| `PAT_FOR_UPDATES` | Token that creates the update PR and enables auto-merge. It must trigger PR CI, so `GITHUB_TOKEN` cannot be used. |
| `CACHIX_AUTH_TOKEN` | Write access to `uriotv`, used only in the publication steps on `main`. |

## CachyOS kernels

One non-LTO kernel for x86-64-v3 CPUs, named like upstream
[xddxdd/nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel):

- `linux-cachyos-latest-x86_64-v3` (EEVDF scheduler)

Use it in NixOS:

```nix
boot.kernelPackages = pkgs.linuxPackages-cachyos-latest-x86_64-v3;
```

The former `linuxPackages-cachyos-bore-x86_64-v3` output has been removed;
consumers using it must switch to the standard kernel before updating this input.

How it is defined:

- **Independent recipe:** `lib/cachyos/default.nix` builds the kernel with
  `buildLinux`. Nothing is imported from xddxdd's flake.
- **Pinned sources:** `pkgs/linux-cachyos-latest-x86_64-v3/source.json` pins the CachyOS release
  archive, the kernel config, and the `kernel-patches` tree metadata, with hashes.
  The standard kernel does not apply patches from that tree.
- **Repository nixpkgs:** the kernel is built with this repository's nixpkgs from
  `flake.lock`, like every other package. Your own nixpkgs is not used, so a
  consumer that overrides `nixpkgs` gets different derivations.
- **Updates:** the daily updater moves a kernel's `source.json` only when CachyOS
  publishes a strictly newer kernel version. `flake.lock` is updated weekly, which
  changes the toolchain and rebuilds the kernel.
- **Builds:** the kernel is built on our own builder and published only to `uriotv`.
  Third-party kernel caches are not used as substituters.

These derivations are not the same as xddxdd's: they use this repository's nixpkgs
and our source records, so do not expect substitution from xddxdd's cache. Compare
`drvPath` before relying on substitution.

To check which derivation your system gets:

```console
nix eval --raw github:urioTV/urio-nur#packages.x86_64-linux.linux-cachyos-latest-x86_64-v3.drvPath
```

See [the kernel recipe notes](lib/cachyos/README.md) for details.

## Cache branch: consume only verified state

The `cache` branch is a copy of a `main` commit whose eligible package and kernel
outputs were published to `uriotv` and whose StorePaths were verified. It is moved
only forward, never forced, and only by the automated workflow.

Use it as your flake input to get exactly that state and nothing unverified:

```nix
# flake.nix
inputs.urio-nur.url = "github:urioTV/urio-nur/cache";
```

Use the flake overlay and no `inputs.nixpkgs.follows` on this input (see above);
otherwise the kernel derivation is not the published one.

The public cache `uriotv` serves every eligible package and the kernel at that
commit. Packages that are not redistributable are never published, so they build
locally.

## Adding a package

See **[Adding and maintaining packages](docs/adding-packages.md)**. In short, add
`pkgs/<name>/default.nix` with complete metadata and an executable `update.sh`,
then run the offline tests and check the CI manifest. No workflow edits are needed.

Tests: [tests/README.md](tests/README.md).

### Lantern Engine (modified Nix build)

`lantern-engine` builds the C/C++ engine and Avalonia/.NET launcher from the pinned
upstream source tag, rather than repackaging the Linux release tarball. NuGet
inputs are hash-locked. This is a modified Nix build, not an official upstream
release; upstream credit and licensing notices are installed with the package.
Updates are managed by Nix (the launcher's binary self-updater is disabled).
Settings, generated files, saves and mods live under
`${XDG_DATA_HOME:-$HOME/.local/share}/lantern-engine`, outside the store.
Your legally obtained Bloodborne dump and a working Vulkan driver are required.
Optional proprietary DLSS/FSR assets and precompiled shader catalogs are not
bundled. A successful build/launcher smoke test does not verify gameplay.

The shared package registry exports it through NUR, the flake and both overlays.
The pinned flake overlay yields the same derivation as CI. The existing successful
`main` build workflow publishes eligible outputs and their closures to `uriotv`;
publication still requires its Cachix secret and is not performed by local builds.
