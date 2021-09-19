[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# NixOS-QChem
Nix derivations for HPC/Quantum chemistry software packages.

The goal of this project is to integrate software packages
into nixos to make it suitable for running it on a HPC cluster.
It provides popular quantum chemsitry packages and performance
optionization to upstream nixpkgs.

[Package list](./package_list.md)

## Usage

### Overlay
The repository comes as a nixpkgs overlay (see [Nixpkgs manual](https://nixos.org/nixpkgs/manual/#chap-overlays) for how to install an overlay).
The contents of the overlay will be placed in an attribute set under nixpkgs (default `qchem`). The original, but overriden nixpkgs will be placed in `qchem.pkgs`. This allows for composition of the overlay with different variants.

There is a branch (release-XX.XX) for every stable version of nixpkgs (nixos-XX.XX).

### Channel
Via `release.nix` a nix channels compatible nixexprs tarball can be generated:
`nix-build release.nix -A channel`


### NUR
The applications from the overlay are also available via [Nix User Repository (NUR)](https://github.com/nix-community/NUR) (qchem repo).
Access via e.g.: `nix-shell -p nur.repos.qchem.<package name>`.

### Binary cache
The latest builds for the master branch and stable version are stored on [Cachix](https://app.cachix.org/):
* Cache URL: https://nix-qchem.cachix.org
* Public key: nix-qchem.cachix.org-1:ZjRh1PosWRj7qf3eukj4IxjhyXx6ZwJbXvvFk3o3Eos=

## Configuration

The overlay can be configured either via an attribute set or via environment variables.
If no attribute set is given the configuration the environment variables are automatically
considered (impure).

### Configuration via nixpkgs
Configuration options can be set directly via `config.qchem-config` alongside other nixpkgs config options.

* `allowEnv` : Allow to override the configuration from the environment (default false when `config.qchem-config` is used).
* `prefix`: The packages of the overlay will be placed in subset specified by `prefix` (default `qchem`).
* `srcurl`: URL for non-free packages. If set this will override the `requireFile` function of nixpkgs to pull all non-free packages from the specified URL
* `optpath`: Path to packages that reside outside the nix store. This is mainly relevant for Gaussian and Matlab.
* `licMolpro`: Molpro license token string required to run molpro.
* `optArch`: Set gcc compiler flags (mtune and march) to optmize for a specfic architecture. Some upstream packages will be overriden to use make use of AVX (see `nixpkgs-opt.nix`). Note, that this also overrides the stdenv
* `useCuda`: Uses Cuda features in selected packages.


### Configuation via environment variables
The overlay will check for environment variables to configure some features:

* `NIXQC_PREFIX`
* `NIXQC_SRCURL`
* `NIXQC_OPTPATH`
* `NIXQC_LICMOLPRO`
* `NIXQC_AVX`: see `optAVX`, setting this to 1 corresponds to `true`.
* `NIXQC_OPTARCH`
* `NIXQC_CUDA`: see `useCuda`, setting this to 1 corresponds to `true`.
