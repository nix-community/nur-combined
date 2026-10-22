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
- Toolchain and Nix kernel builder: `nixpkgs.json`, imported by `nixpkgs.nix`.
  This pin is separate from the repository/consumer flake.lock. Moving it is a
  deliberate maintenance operation that requires new builds and cache review.

The package updater checks CachyOS directly and changes only the package's
`source.json` for a strictly newer kernel version. Changing patches/config or the
nixpkgs pin is not an automatic same-version kernel update. Keep archive,
config, patch branch and hashes consistent; never just edit `version`.

## Cache-compatible migration

The initial 7.2.11 inputs and constructor reproduce these derivations:

| Variant | Derivation store hash |
| --- | --- |
| latest v3 | `33c51nimafiap906qxj3rwkj0fvzf33i` |
| BORE v3 | `r53x7r5ykgp7f75lgc27ka21hqill90z` |

`tests/cachyos-cache-baseline.json` freezes their source records, nixpkgs pin,
derivation and all output paths. `tests/cachyos-eval.nix` evaluates these fixtures
without compiling and checks the actual exported packages through NixOS's
`boot.kernelPackages` override path. Run:

```console
nix eval --json --no-write-lock-file .#ci.x86_64-linux.kernelTests
```

Keeping filenames/layout in this repo is not required for substitution; keeping
the generated derivation is. In particular, preserve the fetcher parameters,
`linux-src-patched` name, patch order, config install script, kernel `pname`,
`modDirVersion`, configuration merge/force semantics, and toolchain. The frozen
regression deliberately fails if the constructor/toolchain changes the old
build recipe; review any such change rather than updating hashes blindly.
Equal derivation/output paths allow existing cached NARs to be reused. This is
not a claim that a fresh recompilation was tested for bit-for-bit reproducibility.

Consumers should use our flake package or overlay and `linuxPackagesFor` with
that kernel. No override of their main nixpkgs changes the kernel's private pin.
Extra kernel patches/configuration may intentionally produce a different hash.
Existing xddxdd users can use our cache for the matching initial revision; see
the root README for an example. Future revisions are independently maintained,
not automatically ABI/hash-identical to xddxdd's moving branches.

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
