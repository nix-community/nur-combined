{ pkgs ? import <nixpkgs> { } }:

let

  inherit (pkgs) lib;
  inherit (lib) optionalAttrs versionOlder;

  pkgsVersion = lib.versions.majorMinor lib.version;

in {
  lib = import ./lib { inherit (pkgs) lib; };
  modules = import ./modules; # NixOS modules.
  overlays = import ./overlays; # Nixpkgs overlays.
  hmModules = import ./hm-modules; # Home Manager modules.
  ndModules = import ./nd-modules; # nix-darwin modules.

  firefox-addons =
    pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });

  materia-theme = pkgs.callPackage ./pkgs/materia-theme { };

  mozilla-addons-to-nix =
    pkgs.haskellPackages.callPackage ./pkgs/mozilla-addons-to-nix { };

  nix-stray-roots = pkgs.callPackage ./pkgs/nix-stray-roots { };

  dbus-codegen-rust = pkgs.callPackage ./pkgs/dbus-codegen-rust { };
}
