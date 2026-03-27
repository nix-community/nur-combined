# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}, ...}: let
  inherit (builtins) isAttrs;
  inherit
    (pkgs)
    lib
    callPackage
    ;
  inherit
    (lib)
    isDerivation
    recurseIntoAttrs
    filesystem
    filterAttrs
    mapAttrs
    ;

  normalizePackage = v:
    if isDerivation v
    then v
    else if isAttrs v && v ? default && isDerivation v.default
    then v.default
    else v;

  recurseCallPackage = path: recurseIntoAttrs (callPackage path {});

  discoveredPackages = filesystem.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./pkgs;
  };

  allPackages = filterAttrs (_: isDerivation) (mapAttrs (_: normalizePackage) discoveredPackages);
in
  {
    # The `lib`, `modules`, and `overlays` names are special
    lib = import ./lib {inherit pkgs;}; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays
    hmModules = import ./hm-modules; # Home Manager modules.

    fishPlugins = recurseCallPackage ./pkgs/fish-plugins;
    opencodePlugins = recurseCallPackage ./pkgs/opencode-plugins;
    spicetifyExtensions = recurseCallPackage ./pkgs/spicetify-extensions;
    yaziPlugins = recurseCallPackage ./pkgs/yazi-plugins;
  }
  // allPackages
