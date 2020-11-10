[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# NixOS-QChem
Nix derivations for HPC/Quantum chemistry software packages.

The goal of this project is to integrate software packages
into nixos to make it suitable for running it on a HPC cluster. 

# Usage

The repository comes as a nixpkgs overlay (see [Nixpkgs manual](https://nixos.org/nixpkgs/manual/#chap-overlays) for how to install an overlay).

There is a branch for every stable version of nixpkgs.

## Configuration

The overlay will check for environment variables to configure some features:

* `NIXQC_SRCURL`: URL for non-free packages. This will override `requireFile` function of nixpkgs to pull all non-free packages from the specified URL
* `NIXQC_OPTPATH`: path to packages that reside outside the nix store. This is mainly relevant for Gaussian and Matlab.
* `NIXQC_LICMOLPRO`: Molpro license token strings required to run molpro
* `NIXQC_AVX`: when this variable is set to "1" some packages will be explicitly compiled with AVX/AVX2 support


