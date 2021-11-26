{
  stdenv, lib,
  fetchFromGitHub,
  linuxManualConfig,
  linuxKernel,
  kernelPatches ? [],
  ...
}:
# with import <nixpkgs> {};

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
linuxManualConfig rec {
  inherit stdenv lib kernelPatches;
  inherit (linuxKernel.kernels.linux_xanmod) version src;

  modDirVersion = "${linuxKernel.kernels.linux_xanmod.modDirVersion}-lantian";
  configfile = ./config;
  config = import ./config.nix;
  allowImportFromDerivation = true;

  extraMeta.broken = linuxKernel.kernels.linux_xanmod.meta.broken;
}
