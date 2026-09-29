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
  # NUR evaluation (`nix-env -f .`, `ci.nix`) runs against several nixpkgs
  # channels (nixpkgs-unstable, nixos-unstable, nixos-26.05, ...). A package
  # that references a nixpkgs attribute missing from an older channel (e.g.
  # pkgs.tinycast) must not fail the whole evaluation — the affected packages
  # are simply omitted on that channel.
  #
  # - safeSet wraps package *sets* merged with // below: on evaluation
  #   failure it falls back to {} so the merge still succeeds.
  # - safePred makes the final filter exception-safe, so single packages
  #   whose derivation fails to evaluate are skipped instead of aborting.
  safeSet =
    path:
    let
      result = builtins.tryEval (callPackage path);
    in
    if result.success then result.value else { };
  safePred =
    _: v:
    let
      result = builtins.tryEval (
        lib.isDerivation v && ourLib.forSystem pkgs.stdenv.hostPlatform.system v
      );
    in
    result.success && result.value;
  nixosModules = import ./modules/nixos; # NixOS modules
  homeModules = import ./modules/home; # Home Manager modules
  darwinModules = import ./modules/darwin; # nix-darwin modules
  flakeModules = import ./modules/flake; # flake-parts modules

  VintagestoryServers = safeSet ./pkgs/VintagestoryServers;
  fabricServers = safeSet ./pkgs/fabricServers;
  neoforgeServers = safeSet ./pkgs/neoforgeServers;
  papermcServers = safeSet ./pkgs/papermcServers;
  purpurServers = safeSet ./pkgs/purpurServers;
  tinycastPackages = safeSet ./pkgs/tinycast;
  packages = {
    ghostex = callPackage ./pkgs/ghostex;
    jellyfin-plugin-ldap-authentication = callPackage ./pkgs/jellyfin-plugin-ldap-authentication;
    libpcpnatpmp = callPackage ./pkgs/libpcpnatpmp;
    mcsmanager = callPackage ./pkgs/mcsmanager;
    network-inventory = callPackage ./pkgs/network-inventory;
    odysseus = callPackage ./pkgs/odysseus;
    pre-commit = callPackage ./pkgs/pre-commit;
    pre-push = callPackage ./pkgs/pre-push;
    setup-sops = callPackage ./pkgs/setup-sops;
    technitium-exporter = callPackage ./pkgs/technitium-exporter;
    toyvo-helix = callPackage ./pkgs/toyvo-helix;
    toyvo-neovim = callPackage ./pkgs/toyvo-neovim;
    # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  }
  // VintagestoryServers
  // fabricServers
  // neoforgeServers
  // papermcServers
  // purpurServers
  // tinycastPackages;
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
// lib.filterAttrs safePred packages
