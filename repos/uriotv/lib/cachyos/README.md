# Independent CachyOS kernel recipes

`default.nix` is our minimal shared `buildLinux` constructor for two non-LTO,
x86-64-v3 kernels: EEVDF (`linux-cachyos-latest-x86_64-v3`) and BORE
(`linux-cachyos-bore-x86_64-v3`). Package entry points select the variant and read
only their own `source.json`. No evaluation or updater needs the xddxdd flake.

## Inputs and updates

- Kernel archive: `CachyOS/linux` release asset (URL and SHA-256).
- Kernel config: pinned commit/file in `CachyOS/linux-cachyos` (URL and SHA-256).
- Patch tree: pinned `CachyOS/kernel-patches` commit, filtered by `patchVersion/`
  using nixpkgs `fetchgit` with `rootDir` (revision and tree SHA-256).
- Toolchain and Nix kernel builder: the repository nixpkgs from `flake.lock`, passed
  in by `callPackage` as `pkgs`. A lock update changes the toolchain, so it rebuilds
  both kernels; the weekly lock workflow makes this a single reviewed change.

The package updater checks CachyOS directly and changes only the package's
`source.json` for a strictly newer kernel version. Changing patches/config or the
nixpkgs pin is not an automatic same-version kernel update. Keep archive,
config, patch branch and hashes consistent; never just edit `version`.

## Evaluation checks

`tests/cachyos-eval.nix` evaluates both kernels without compiling and checks the
exported packages through the overlay fixpoint and NixOS's `boot.kernelPackages`
override path. Run:

```console
nix eval --json --no-write-lock-file .#ci.x86_64-linux.kernelTests
```

The 7.2.11 derivations of the previous independent pin are no longer produced;
the switch to `flake.lock` replaces them and their cached outputs are obsolete.
Fetcher parameters, `linux-src-patched` name, patch order, config install script,
`pname`, `modDirVersion` and the configuration merge are unchanged.

Consumers should use our flake package or overlay and `linuxPackagesFor` with
that kernel. No override of their main nixpkgs changes the kernel's private pin.
Extra kernel patches/configuration may intentionally produce a different hash.
These kernels are not hash-identical to xddxdd's. Users of xddxdd's cache do not
get substitution from ours; see the root README.

## Provenance and licence

The builder/configuration logic is adapted from xddxdd/nix-cachyos-kernel at
revision `893cfece885f2af90edc71fd0d8f95a83d72c7e2`:

- https://github.com/xddxdd/nix-cachyos-kernel/blob/893cfece885f2af90edc71fd0d8f95a83d72c7e2/kernel-cachyos/mkCachyKernel.nix
- https://github.com/xddxdd/nix-cachyos-kernel/blob/893cfece885f2af90edc71fd0d8f95a83d72c7e2/kernel-cachyos/cachySettings.nix

The adapted recipe is GPL-2.0-only; the upstream licence text is retained in
`COPYING`. This licence is scoped to this directory, not a relicensing of the
whole repository. CachyOS/Linux sources and patches retain their own copyright
and licence notices. Publication still requires redistribution/source obligations
to be satisfied for the complete runtime closure.
