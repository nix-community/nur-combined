{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:

let
  pkgsLib = lib;
  inherit (pkgsLib) versionOlder;
  applyIf = f: p: x: if p x then f x else x;
  applyIf' = f: p: x: if p then f x else x;

  break = p: p.overrideAttrs (o: { meta = o.meta // { broken = true; }; });
  breakIf = applyIf break;
  breakIf' = applyIf' break;

  min-cargo-vendor = "0.1.23";
  packageOlder = p: v: p != null && versionOlder (pkgsLib.getVersion p) v;
  cargoVendorTooOld = cargo-vendor: packageOlder cargo-vendor min-cargo-vendor;
  needsNewCargoVendor = p: breakIf' (cargoVendorTooOld p);
  needsNewCargoVendor' = needsNewCargoVendor (pkgs.cargo-vendor or null);
in rec {
  lib = import ./lib { inherit pkgs lib; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # # applications

  # ## applications.graphics

  shotgun = needsNewCargoVendor'
    (pkgs.callPackage ./pkgs/applications/graphics/shotgun { });

  # # tools

  # ## tools.misc

  hacksaw = needsNewCargoVendor'
    (pkgs.callPackage ./pkgs/tools/misc/hacksaw { });
}
