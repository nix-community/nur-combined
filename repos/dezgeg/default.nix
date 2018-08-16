{ pkgs ? import <nixpkgs> {} }:

let
  callPackage = pkgs.newScope self;
  self = rec {
    bootlinToolchains = callPackage ./bootlin-toolchains {};
    kernelOrgToolchains = callPackage ./kernel-org-toolchains {};
    ubootDevShell = callPackage ./u-boot-dev-shell/shell.nix {};
    buildmanConfig = callPackage ./u-boot-dev-shell/buildman-config.nix {};
  };
in self
