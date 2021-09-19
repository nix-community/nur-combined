{
  stdenv, lib,
  fetchFromGitHub,
  linuxManualConfig,
  linuxKernel,
  ...
}:
# with import <nixpkgs> {};

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
let
  modDirVersion = "${linuxKernel.kernels.linux_xanmod.modDirVersion}-lantian";

  kernel = linuxManualConfig rec {
    inherit stdenv lib modDirVersion;
    inherit (linuxKernel.kernels.linux_xanmod) version src;

    configfile = ./config;
    config = import ./config.nix;
    allowImportFromDerivation = true;
  };

  passthru = rec {
    inherit (linuxKernel.kernels.linux_xanmod) version;
    inherit modDirVersion;
    kernelOlder = lib.versionOlder version;
    kernelAtLeast = lib.versionAtLeast version;
    passthru = kernel.passthru // (removeAttrs passthru [ "passthru" ]);
  };

  finalKernel = lib.extendDerivation true passthru kernel;
in
  finalKernel
