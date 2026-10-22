# urio-nur

My personal [NUR](https://github.com/nix-community/NUR) repository: a few
packages, two CachyOS kernels, and a public binary cache at
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

| Package | Description | Public cache |
|---|---|---|
| `bbport` | Native Linux port of Bloodborne (needs your own game dump) | Yes |
| `cybergrub2077` | Cyberpunk 2077 inspired GRUB theme | Yes |
| `nmssaveeditor` | Save editor for No Man's Sky | No: unfree |
| `pig` | Pi coding agent rebuilt in Go as a native binary | Yes |
| `rimsort-appimage` | RimWorld mod manager | Yes |
| `scopebuddy` | Gamescope manager | Yes |
| `storyforge` | Story Forge desktop application, built independently of the upstream flake | Yes |
| `wowup-cf` | World of Warcraft addon manager with CurseForge support | Yes |
| `linux-cachyos-latest-x86_64-v3` | CachyOS kernel, x86-64-v3, non-LTO | Yes |
| `linux-cachyos-bore-x86_64-v3` | CachyOS kernel with BORE scheduler, x86-64-v3, non-LTO | Yes |

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

The overlay builds packages against your system's nixpkgs. Direct flake outputs
(`urio-nur.packages.<system>.<name>`) use this repository's `flake.lock`. A different
nixpkgs revision changes store paths, which can cause cache misses.

### Enabling the cache

```nix
nix.settings = {
  extra-substituters = [ "https://uriotv.cachix.org" ];
  extra-trusted-public-keys = [ "uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI=" ];
};
```

Apply this once before building packages. The cache is public and read-only for
users; only the repository's `main` workflows can write to it.

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

Four workflows, one daily clock.

| Workflow | When | What it does |
|---|---|---|
| `update.yml` "Update packages" | every day at **02:00 `Europe/Warsaw`** (IANA timezone, follows DST), or manually | Checks every registered package for a newer upstream version and updates its pin. Successful changes go into one `auto-update-packages` PR with squash auto-merge. |
| `build.yml` "Build and populate cache" | on PRs, on pushes to `main`, after a successful update run on `main`, or manually | Runs offline tests and Nix evaluation checks, then builds every eligible package on GitHub-hosted runners. On `main` it publishes eligible outputs to `uriotv` and verifies each `StorePath`. |
| `kernel.yml` "Build CachyOS kernel (self-hosted)" | on pushes to `main` that touch a kernel directory, `lib/cachyos/`, or the gate script; or manually | Builds the two kernels from source on our self-hosted builder, then publishes them automatically after a licence check. |
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

Two non-LTO kernels for x86-64-v3 CPUs, named like upstream
[xddxdd/nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel):

- `linux-cachyos-latest-x86_64-v3` (EEVDF scheduler)
- `linux-cachyos-bore-x86_64-v3` (BORE scheduler)

Use them in NixOS:

```nix
boot.kernelPackages = pkgs.linuxPackages-cachyos-bore-x86_64-v3;
# or pkgs.linuxPackages-cachyos-latest-x86_64-v3
```

How they are defined:

- **Independent recipe:** `lib/cachyos/default.nix` builds each kernel with
  `buildLinux`. Nothing is imported from xddxdd's flake.
- **Pinned sources:** each `pkgs/<kernel>/source.json` pins the CachyOS release
  archive, the kernel config, and the `kernel-patches` tree, with hashes.
- **Own toolchain pin:** `lib/cachyos/nixpkgs.json` pins the nixpkgs used to build
  the kernels. It is separate from this repository's `flake.lock` and from your
  nixpkgs, so the kernel derivation does not change when you update your system.
- **Updates:** the daily updater moves a kernel's `source.json` only when CachyOS
  publishes a strictly newer kernel version. Nixpkgs and the toolchain pin are never
  changed automatically.
- **Builds:** kernels are built on our own builder and published only to `uriotv`.
  Third-party kernel caches are not used as substituters.

### Compatibility with xddxdd

The initial 7.2.11 kernels produce the same derivations and output paths as
xddxdd revision `893cfece885f2af90edc71fd0d8f95a83d72c7e2`. You can keep using
xddxdd's flake and add only our cache, as long as you do not override its nixpkgs:

```nix
# flake.nix
inputs.nix-cachyos-kernel.url =
  "github:xddxdd/nix-cachyos-kernel/893cfece885f2af90edc71fd0d8f95a83d72c7e2";
```

```nix
{ inputs, ... }: {
  nix.settings.substituters = [ "https://uriotv.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI="
  ];
  boot.kernelPackages = inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux
    .linuxPackages-cachyos-bore-x86_64-v3;
}
```

A matching version number is not enough. Source hashes, nixpkgs, and the build
configuration must match too. Following xddxdd's `master` or `release` branch may
miss our cache. Compare `drvPath` before relying on substitution. Our kernels
also move on their own schedule, so they will not stay identical to upstream.

To check which derivation your system gets:

```console
nix eval --raw github:urioTV/urio-nur#packages.x86_64-linux.linux-cachyos-bore-x86_64-v3.drvPath
```

See [the kernel recipe notes](lib/cachyos/README.md) for details.

## Adding a package

See **[Adding and maintaining packages](docs/adding-packages.md)**. In short, add
`pkgs/<name>/default.nix` with complete metadata and an executable `update.sh`,
then run the offline tests and check the CI manifest. No workflow edits are needed.

Tests: [tests/README.md](tests/README.md).
