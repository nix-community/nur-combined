# Agents Guide

## Setup

If `nix` is not installed, use the Determinate Systems installer:

```sh
$ curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
$ . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Ensure flake inputs are downloaded before running in an offline sandbox:

```sh
$ nix flake archive
$ nix flake archive ./internal/
```

## Testing

```sh
$ nix flake check --show-trace --print-build-logs --keep-going
```

These flags will give you the most verbose output for debugging. When running in an offline sandox, you should append `--offline`.

## Formatting

`nix flake check` will also check if source files are formatted correctly. If there is a formatting issue, run `nix fmt` to fix it.

## Ordering

`nixfmt` does not reorder anything, so these are maintained by hand. They follow the de-facto convention in `NixOS/nixpkgs`, which is role-based rather than alphabetical.

### Package arguments

Order the `callPackage` argument set by role, and alphabetize only within the dependency group:

1. `lib`
2. Builder — `stdenv`, `stdenvNoCC`, `buildGoModule`, `python3Packages`, `rustPlatform`, `swiftPackages`, `terraform-providers`
3. Source — `fetchFromGitHub`, `fetchurl`, `fetchzip`, and `nur` (it supplies `src`)
4. Dependencies, alphabetized. Packages a test consumes belong here, not in the group below
5. Passthru machinery — `nix-update-script`, `runCommand`, `testers`, `writeText`

```nix
{
  lib,
  buildGoModule,
  fetchFromGitHub,

  age,
  jq,
  restic,

  nix-update-script,
  runCommand,
  testers,
}:
```

Keep the list flat below eight arguments; separate the groups with blank lines at eight or more. Add `#` comments only when the groups are not self-evident, as in `pkgs/ceph/librados.nix`.

### Derivation attributes

Order attributes by the build lifecycle:

`pname` → `version` → format flags (`pyproject`, `__structuredAttrs`, `outputs`) → `src` → `patches`/`postPatch` → hashes (`vendorHash`, `cargoHash`) → inputs (`build-system`, `nativeBuildInputs`, `buildInputs`, `dependencies`) → build configuration (`env`, `ldflags`, `cmakeFlags`) → phases in lifecycle order → check attributes → `passthru` → `meta`

`pname` is always first and `meta` is always last, with `passthru` immediately before it.

### Exceptions

Files vendored verbatim from nixpkgs keep upstream's ordering so they stay easy to rebase — `pkgs/helm/kubernetes-helm_3.nix` is a copy of `pkgs/applications/networking/cluster/helm/default.nix`.

`internal/*.nix` mix nixpkgs dependencies with caller-supplied derivation parameters (`src`, `pname`, `chartName`, `helmValues`). Keep nixpkgs dependencies first, then the parameters, then the `?`-defaulted ones; do not interleave them.
