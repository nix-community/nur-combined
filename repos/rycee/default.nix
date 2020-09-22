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

  firefox-addons-generator =
    pkgs.haskellPackages.callPackage ./pkgs/firefox-addons-generator { };

  nix-stray-roots = pkgs.callPackage ./pkgs/nix-stray-roots { };

  dbus-codegen-rust = pkgs.callPackage ./pkgs/dbus-codegen-rust { };

  weylus = if versionOlder pkgsVersion "20.09" then
    pkgs.callPackage ./pkgs/weylus { }
  else
    pkgs.writeShellScriptBin "unsupported" "echo unsupported Nixpkgs version";
}
