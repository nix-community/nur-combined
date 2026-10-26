# NUR Packages

[![build](https://github.com/codgician/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/codgician/nur-packages/actions/workflows/build.yml)
[![evergreen](https://github.com/codgician/nur-packages/actions/workflows/evergreen.yml/badge.svg)](https://github.com/codgician/nur-packages/actions/workflows/evergreen.yml)

NUR Packages from codgician.

Packages are built on GitHub Actions via [atelier](https://github.com/stepbrobd/atelier) for `x86_64-linux`, `aarch64-linux` and `aarch64-darwin`.

## Kernel modules

Out-of-tree kernel modules (packages whose expression takes a `kernel` argument, such as `cix-vpu-driver`) must be built against the kernel that loads them. Use them through `boot.kernelPackages`:

- **NixOS**: import the `kernel-modules` NixOS module (`modules.kernel-modules` of this repository, e.g. `nur.legacyPackages.<system>.repos.codgician.modules.kernel-modules`, or this flake's `nixosModules.kernel-modules`), then reference `config.boot.kernelPackages.<name>`:

  ```nix
  { config, ... }:
  {
    boot.extraModulePackages = [ config.boot.kernelPackages.cix-vpu-driver ];
  }
  ```

- **Other `pkgs` instances**, including read-only `nixpkgs.pkgs` such as `pkgs.testers.runNixOSTest` nodes: apply `overlays.kernel-modules` where `pkgs` is constructed. Every `linuxPackages*` set then contains the modules.

The top-level attribute (e.g. `cix-vpu-driver`) is built against nixpkgs' default kernel for CI and caching. Use it directly only for kernel-independent outputs such as UAPI headers.

### GPU unlock

`gpu-unlock` packages [gpu-unlock-ada](https://github.com/JustAResearcher/gpu-unlock-ada); `gpu-unlock-firmware` generates its pinned NVIDIA firmware assets and preserves their license notices. Import this flake's `nixosModules.gpu-unlock` (or the NUR repository's `modules.gpu-unlock`), then opt in explicitly:

```nix
hardware.gpu-unlock = {
  enable = true;
  targets = [ "0000:01:00.0" ]; # Replace with the intended GPU's full PCI address.
};
```

The module adds the kernel module and firmware to the initrd and orders `gpu_unlock` before normally ordered NVIDIA initrd modules. It is disabled by default. Experimental RTX 4090 D, RTX 4070 Ti SUPER and RTX 4060 Ti 16GB support requires the corresponding `rtx4090dExperimental`, `ad103Experimental` or `ad106Experimental` option; AD103/AD106 also require exactly one PCI address.

Follow upstream's cold-boot and recovery instructions, keep a stock boot entry, and verify the hardware result independently. Compilation and a successful module load do not establish that a GPU was unlocked. Modified-memory boards are not validated by these package checks. This does not replace the normal NVIDIA driver's GSP firmware or repair VBIOS power-state tables.

## Automatic build repairs

When a package build or check fails on the current `main` revision, build-completion automation invokes Pi and opens one PR per failing package on `bot/repair-<package>`. Multiple platform failures for the same package share one repair. Existing open repair PRs prevent duplicate creation; stale builds, cancelled runs, and harness or unattributed infrastructure failures do not create repair PRs.

Main-build fixes preserve the package version. They share the existing bot-PR repair pipeline, including package-only changes, updater idempotence, formatting, build and smoke validation, signed publication, and revision freshness checks. Failed builds on eligible bot-owned, same-repository, single-package PRs update the same PR, with at most three AI repair commits. Human-authored and fork PRs are not repaired automatically.

Repairs use the existing `DENDRO_API_KEY`, `APP_PRIVATE_KEY`, and `APP_CLIENT_ID` configuration. The repository's `bot-build-fix` label distinguishes same-version repairs from updates. Agent execution has read-only repository permissions; only the separate publisher receives the GitHub App write token. AI-assisted PRs require human review and normal PR CI before merging.

## Binary cache

- **Cache URL**: `https://cache.codgician.me/nur-packages`
- **Public Key**: `nur-packages:AbWm/DsIy5+TtVaW6GhiZX98nU6y5913NqjEXeeV8mA=`
