# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  inputs ? { },
}:
let
  inherit (pkgs) lib;
  ourLib = import ./lib {
    inherit (pkgs) lib;
    inherit inputs;
  }; # functions
  lib' = pkgs.lib.recursiveUpdate pkgs.lib ourLib; # functions
  # nixpkgs lib extended with repo maintainers, so packages can use
  # `with lib.maintainers; [ toyvo ];`
  callPackage =
    ep:
    pkgs.newScope { lib = lib'; } ep {
      lib = lib';
      inherit inputs;
    };
  nixosModules = import ./modules/nixos; # NixOS modules
  homeModules = import ./modules/home; # Home Manager modules
  darwinModules = import ./modules/darwin; # nix-darwin modules
  flakeModules = import ./modules/flake; # flake-parts modules

  VintagestoryServers = callPackage ./pkgs/VintagestoryServers;
  purpurServers = callPackage ./pkgs/purpurServers;
  neoforgeServers = callPackage ./pkgs/neoforgeServers;
  papermcServers = callPackage ./pkgs/papermcServers;
  fabricServers = callPackage ./pkgs/fabricServers;
  packages = {
    jellyfin-plugin-ldap-authentication = callPackage ./pkgs/jellyfin-plugin-ldap-authentication;
    mcsmanager = callPackage ./pkgs/mcsmanager;
    network-inventory = callPackage ./pkgs/network-inventory;
    pre-commit = callPackage ./pkgs/pre-commit;
    technitium-exporter = callPackage ./pkgs/technitium-exporter;
    toyvo-neovim = callPackage ./pkgs/toyvo-neovim;
    libpcpnatpmp = callPackage ./pkgs/libpcpnatpmp;
    pre-push = callPackage ./pkgs/pre-push;
    setup-sops = callPackage ./pkgs/setup-sops;
    toyvo-helix = callPackage ./pkgs/toyvo-helix;
    # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  }
  // VintagestoryServers
  // purpurServers
  // neoforgeServers
  // papermcServers
  // papermcServers
  // fabricServers;
in
{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = ourLib;
  inherit
    nixosModules
    homeModules
    darwinModules
    flakeModules
    ;
  modules = {
    nixos = nixosModules;
    home = homeModules;
    darwin = darwinModules;
    flake = flakeModules;
  };
  overlays = import ./overlays; # nixpkgs overlays
}
// lib.filterAttrs (
  _: v: lib.isDerivation v && ourLib.forSystem pkgs.stdenv.hostPlatform.system v
) packages
