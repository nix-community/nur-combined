# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  lib = import ./lib { inherit pkgs; };

  # Same as pkgs.callPackage, but every package also receives the `maintainers`
  # attribute from ./lib/maintainers.nix.
  callPackage = pkgs.lib.callPackageWith (pkgs // { inherit (lib) maintainers; });

  # The special attributes above are not packages, so a directory of the same
  # name under ./pkgs is ignored rather than silently overriding one of them.
  reservedNames = [
    "lib"
    "overlays"
    "nixosModules"
    "homeModules"
    "darwinModules"
    "flakeModules"
  ];

  # Every subdirectory of ./pkgs that holds a default.nix becomes an attribute,
  # so adding a package is just creating ./pkgs/<name>/default.nix:
  #
  #     ./pkgs/feishin/default.nix  ->  feishin = callPackage ./pkgs/feishin { };
  #
  # Directories without a default.nix (helper scripts, notes, ...) are skipped,
  # so ./pkgs can hold other things than packages.
  #
  # Caveat with flakes: only git-tracked files are visible, so `git add
  # pkgs/<name>` is required before the new package shows up in `nix build .#`.
  packagesDir = ./pkgs;
  isPackageDir = name: type:
    type == "directory"
    && !(builtins.elem name reservedNames)
    && builtins.pathExists (packagesDir + "/${name}/default.nix");

  packages = pkgs.lib.mapAttrs
    (name: _: callPackage (packagesDir + "/${name}") { })
    (pkgs.lib.filterAttrs isPackageDir (builtins.readDir packagesDir));
in

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special

  inherit lib; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays
}
// packages
// {
  # Variants of a package that don't map 1:1 to a directory name, hence listed
  # by hand. A qt5 package would go here too:
  #     some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };

  tm-mumble-link-tui = callPackage ./pkgs/tm-mumble-link { tuiVersion = true; };
}
