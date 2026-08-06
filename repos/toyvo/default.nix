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
  lib = import ./lib {
    inherit (pkgs) lib;
    inherit inputs;
  }; # functions
  nixosModules = import ./modules/nixos; # NixOS modules
  homeModules = import ./modules/home; # Home Manager modules
  darwinModules = import ./modules/darwin; # nix-darwin modules
  flakeModules = import ./modules/flake; # flake-parts modules
in
{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  inherit
    lib
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

  example-package = pkgs.callPackage ./pkgs/example-package { };
  jellyfin-plugin-ldap-authentication =
    pkgs.callPackage ./pkgs/jellyfin-plugin-ldap-authentication
      { };
  mcsmanager = pkgs.callPackage ./pkgs/mcsmanager { };
  network-inventory = pkgs.callPackage ./pkgs/network-inventory { };
  pre-commit = pkgs.callPackage ./pkgs/pre-commit { };
  purpurServers = pkgs.callPackage ./pkgs/purpurServers { };
  technitium-exporter = pkgs.callPackage ./pkgs/technitium-exporter { };
  toyvo-neovim = pkgs.callPackage ./pkgs/toyvo-neovim {
    lib = pkgs.lib // lib;
    inherit inputs;
  };
  fabricServers = pkgs.callPackage ./pkgs/fabricServers { };
  libpcpnatpmp = pkgs.callPackage ./pkgs/libpcpnatpmp { };
  neoforgeServers = pkgs.callPackage ./pkgs/neoforgeServers { };
  papermcServers = pkgs.callPackage ./pkgs/papermcServers { };
  pre-push = pkgs.callPackage ./pkgs/pre-push { };
  setup-sops = pkgs.callPackage ./pkgs/setup-sops { };
  toyvo-helix = pkgs.callPackage ./pkgs/toyvo-helix {
    lib = pkgs.lib // lib;
  };
  VintagestoryServers = pkgs.callPackage ./pkgs/VintagestoryServers { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
