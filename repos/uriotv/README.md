# urio-nur

My personal [NUR](https://github.com/nix-community/NUR) repository.

[![Build and populate cache](https://github.com/urioTV/urio-nur/actions/workflows/build.yml/badge.svg)](https://github.com/urioTV/urio-nur/actions/workflows/build.yml)
[![Update packages](https://github.com/urioTV/urio-nur/actions/workflows/update.yml/badge.svg)](https://github.com/urioTV/urio-nur/actions/workflows/update.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-uriotv-blue.svg)](https://uriotv.cachix.org)

## Packages

Every package is checked for upstream updates **daily**, built in CI on
**x86_64-linux**, and published to Cachix **only if its license permits it**.

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

## Usage

```console
nix build github:urioTV/urio-nur#pig
nix run github:urioTV/urio-nur#pig
```

For a NixOS configuration, add `urio-nur.url = "github:urioTV/urio-nur"` to your
flake inputs, then use the overlay in a module:

```nix
{ pkgs, urio-nur, ... }: {
  nixpkgs.overlays = [ urio-nur.overlays.default ];
  environment.systemPackages = [ pkgs.pig pkgs.scopebuddy ];
}
```

Pass `urio-nur` into the module scope through your flake outputs or `specialArgs`.
The overlay uses your system's nixpkgs; direct flake outputs use this repository's
lock file. A different nixpkgs revision can change store paths and cache hits.

To use the public cache (activate this before building packages):

```nix
nix.settings = {
  extra-substituters = [ "https://uriotv.cachix.org" ];
  extra-trusted-public-keys = [ "uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI=" ];
};
```

### Story Forge

Use `urio-nur.packages.${pkgs.system}.storyforge` in your package list, or
`pkgs.storyforge` after enabling the overlay. No StoryForge flake input is required.

```console
nix build .#storyforge
```

See [the package guide](pkgs/storyforge/README.md). Daily updates follow stable
releases and regenerate the Cargo/Bun artifacts together. The current snapshot
is preserved until a strictly newer, descendant release is available.

## CI/CD contract

- **One registry:** `pkgs/<name>/default.nix` automatically becomes a NUR export,
  overlay entry, supported-system flake package and CI entry. No duplicate lists.
- **Full builds:** every supported, non-broken package and all its outputs are
  built, including unfree packages and those with `preferLocalBuild = true`.
  Exception: packages with `meta.ciBuild = false` are built out of band (see
  Compute below).
  Cached results may be substituted; CI does not force a costly rebuild.
- **Separate publication:** metadata must explicitly allow redistribution
  (`license.redistributable`, or `license.free` when absent). Unknown/empty
  license metadata fails closed. `preferLocalBuild` is only a scheduling hint.
  See [the license policy](docs/adding-packages.md#licenses-and-public-cache).
- **Daily updates:** 03:00 UTC (`update.yml`) checks every registered package.
  Successful changes create/update one `auto-update-packages` PR and enable
  squash auto-merge. Missing updaters are errors, never silently skipped.
- **Partial failures:** a failed updater is rolled back; successful updates can
  still form a PR. The workflow reports failure after creating the PR, so broken
  upstream checks are visible rather than silently green. Each updater has a
  15-minute timeout.
- **Required gate:** `test-gate` waits for offline tests and the complete package
  build job. A failed, skipped or cancelled build blocks merge. GitHub branch
  protection must require `test-update-scripts` and `test-gate` (strict mode).
- **Public cache:** only successful builds on `main` publish eligible outputs to
  `uriotv.cachix.org`, verify their narinfo `StorePath`, then notify NUR. PRs and
  the updater have no Cachix write token. Daily build check: 03:17 UTC.
  NUR's global HTTP 429 throttle is explicitly reported as a deferred request,
  not a successful notification or package failure; its periodic sync remains
  the fallback. Other HTTP/transport failures still fail CI after bounded retries.
- **Compute:** GitHub-hosted runners (`ubuntu-latest`) build all packages in
  `build.yml`, except `meta.ciBuild = false`. Both CachyOS x86-64-v3 kernels
  (`linux-cachyos-latest-x86_64-v3` and `linux-cachyos-bore-x86_64-v3`, non-LTO)
  are built sequentially by `kernel.yml` on the
  self-hosted runner `[self-hosted, nixos, cachix-builder]` (labels: `nixos`,
  `cachix-builder`). It triggers only on push to `main` that changes
  either kernel package directory or `kernel.yml`, and on manual dispatch of
  `main`; never on pull requests. If every output of the current pin is already
  in `uriotv`, the build is skipped (dispatch with `force = true` to rebuild). Publication to `uriotv` happens only on a manual
  dispatch with `publish = true`, after the closure licence review. It is not part
  of `test-gate`, so a kernel failure does not block merges. Its job is disabled
  unless the repository variable `KERNEL_BUILDER_ENABLED` is `true`.

GitHub can delay scheduled workflows; the cron time is not a delivery guarantee.
Builds and the updater use the same `flake.lock` pin. The updater does not move
the lock automatically. Updating nixpkgs is a deliberate maintenance change.

Required repository Actions secrets:

| Secret | Purpose |
|---|---|
| `PAT_FOR_UPDATES` | Owner token for creating the update PR and enabling auto-merge; must trigger PR CI and satisfy collaborators-only PR access |
| `CACHIX_AUTH_TOKEN` | Write access to `uriotv`, used only in the main publication step |

The update PAT needs repository contents and pull-request write permissions. Do
not replace it with `GITHUB_TOKEN`: PRs made with that token do not trigger this CI.
Dependabot updates action versions weekly; its PRs are not automatically merged
by the package updater. There are no secrets required to build a PR.

## CachyOS kernels (upstream-compatible names)

We export exactly two non-LTO, x86-64-v3 kernels, named just like upstream:

- `linux-cachyos-latest-x86_64-v3`
- `linux-cachyos-bore-x86_64-v3` (BORE scheduler)

- **Source of truth:** each `pkgs/<kernel>/default.nix` pins the
  upstream `xddxdd/nix-cachyos-kernel` commit (`rev` and `hash`). The daily
  `update.sh` moves that pin only when upstream's corresponding `linux-cachyos`
  or `linux-cachyos-bore` version is newer;
  upstream's near-daily nixpkgs-only bumps are ignored, so a rebuild means a real
  kernel update. It never changes `flake.lock`.
- **Build from scratch:** the kernel is built on our builder. Upstream and
  third-party kernel caches are not substituters. Only `cache.nixos.org` (nixpkgs
  dependencies) and `uriotv` are used.
- **Same derivation everywhere:** the kernel is evaluated with upstream's own
  flake.lock, so its `drvPath` does not depend on the nixpkgs pinned by a consumer.
  Overriding urio-nur's `nixpkgs` input does not change it. CI records the
  `drvPath` in the `kernel.yml` job summary. Consumers can compare with:
  `nix eval --raw github:urioTV/urio-nur#packages.x86_64-linux.linux-cachyos-latest-x86_64-v3.drvPath`
- **Consumers** (laptop, desktop) take the package from the `urio-nur` overlay or
  `packages.x86_64-linux`. Pin `urio-nur` in their `flake.lock` to a commit that
  contains this package, and build the kernel from that source. Changing the pin
  is a deliberate `nix flake update urio-nur`.

### Using uriotv with xddxdd directly

The public cache is not tied to our flake's attribute namespace. Our builds keep
upstream's package names, derivations and output paths unchanged. You can use
xddxdd's repository directly and add only our cache:

```nix
# flake.nix: this revision matches the initial latest and BORE v3 builds.
inputs.nix-cachyos-kernel.url =
  "github:xddxdd/nix-cachyos-kernel/893cfece885f2af90edc71fd0d8f95a83d72c7e2";
# Do not override this input's nixpkgs (no follows).
```

```nix
# NixOS module, with inputs available as a module argument:
{ inputs, ... }: {
  nix.settings.substituters = [ "https://uriotv.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI="
  ];
  boot.kernelPackages = inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux
    .linuxPackages-cachyos-bore-x86_64-v3;
  # Or .linuxPackages-cachyos-latest-x86_64-v3 for the non-BORE kernel.
}
```

A matching version string is not sufficient: the upstream revision, its locked
nixpkgs and kernel configuration must match. This repository ignores upstream's
nixpkgs-only updates until the next kernel release, so following upstream's latest
`master` or `release` can miss our cache even with the same kernel version. Use
the revision in the corresponding package's `default.nix`; each variant may have
its own pin after updates. Overriding the kernel or using a different nixpkgs can
also cause a cache miss. Missing outputs build locally; BORE is not available in
uriotv until its first self-hosted build and reviewed publication complete.

## Adding a package

See **[Adding and maintaining packages](docs/adding-packages.md)**. In short, add
`pkgs/<name>/default.nix` with complete metadata and an executable `update.sh`,
then run the offline tests and inspect the CI manifest. No workflow edits needed.

Test commands and scope: [tests/README.md](tests/README.md).
