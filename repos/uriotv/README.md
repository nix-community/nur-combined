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

| Package | Version | Description | Public cache |
|---|---|---|---|
| `bbport` | `0.6` | Native Linux port of Bloodborne (needs your own game dump) | Yes |
| `cybergrub2077` | `2.0.1-unstable-2026-02-28` | Cyberpunk 2077 inspired GRUB theme | Yes |
| `nmssaveeditor` | `1.21.0` | Save editor for No Man's Sky | No: unfree |
| `pig` | `0.5.3` | Pi coding agent rebuilt in Go as a native binary | Yes |
| `rimsort-appimage` | `1.17.4` | RimWorld mod manager | Yes |
| `scopebuddy` | `1.5.0` | Gamescope manager | Yes |
| `storyforge` | `2.0.10` | Story Forge desktop application, built independently of the upstream flake | Yes |
| `wowup-cf` | `2.24.1` | World of Warcraft addon manager with CurseForge support | Yes |
| `linux-cachyos-latest-x86_64-v3` | `7.3.0` | CachyOS kernel, x86-64-v3, non-LTO | Yes |
| `linux-cachyos-bore-x86_64-v3` | `7.3.0` | CachyOS kernel with BORE scheduler, x86-64-v3, non-LTO | Yes |

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

The overlay builds ordinary packages against your system's nixpkgs. The two CachyOS
kernels are the exception: the flake overlay takes them from this repository's
`flake.lock`, so you get exactly the derivations CI publishes, whatever your nixpkgs
is. Only their out-of-tree modules (`linuxPackagesFor`) use your nixpkgs. Direct
flake outputs (`urio-nur.packages.<system>.<name>`) also use this repository's lock.

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
| `kernel.yml` "Build CachyOS kernel (self-hosted)" | on every push to `main`, after a successful update run, or manually | Builds the two kernels from source on our self-hosted builder (or realises them when already published), then publishes them after a licence check. |
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
| `ATTIC_TOKEN` | Push access to the private attic cache `urio` (`https://attic.urio.dev`), used after the cachix publication on `main`. Without it the attic push fails and the `cache` branch is not promoted. |

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
- **Repository nixpkgs:** the kernels are built with this repository's nixpkgs from
  `flake.lock`, like every other package. Your own nixpkgs is not used, so a
  consumer that overrides `nixpkgs` gets different derivations.
- **Updates:** the daily updater moves a kernel's `source.json` only when CachyOS
  publishes a strictly newer kernel version. `flake.lock` is updated weekly, which
  changes the toolchain and rebuilds both kernels.
- **Builds:** kernels are built on our own builder and published only to `uriotv`.
  Third-party kernel caches are not used as substituters.

These derivations are not the same as xddxdd's: they use this repository's nixpkgs
and our source records, so do not expect substitution from xddxdd's cache. Compare
`drvPath` before relying on substitution.

To check which derivation your system gets:

```console
nix eval --raw github:urioTV/urio-nur#packages.x86_64-linux.linux-cachyos-bore-x86_64-v3.drvPath
```

See [the kernel recipe notes](lib/cachyos/README.md) for details.

## Cache branch: consume only verified state

The `cache` branch is a copy of a `main` commit whose publications all succeeded:
packages and both kernels were pushed to `uriotv` and to the private attic cache,
and the outputs were verified. It is moved only forward, never forced, and only by
the automated workflow.

Use it as your flake input to get exactly that state and nothing unverified:

```nix
# flake.nix
inputs.urio-nur.url = "github:urioTV/urio-nur/cache";
```

Use the flake overlay and no `inputs.nixpkgs.follows` on this input (see above);
otherwise the kernel derivation is not the published one.

The public cache `uriotv` serves every eligible package and both kernels at that
commit. Packages that are not redistributable are never published, so they build
locally. The private attic cache is for the owner only.

## Adding a package

See **[Adding and maintaining packages](docs/adding-packages.md)**. In short, add
`pkgs/<name>/default.nix` with complete metadata and an executable `update.sh`,
then run the offline tests and check the CI manifest. No workflow edits are needed.

Tests: [tests/README.md](tests/README.md).
