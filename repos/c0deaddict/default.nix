# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  keyhub-cli = pkgs.callPackage ./pkgs/keyhub-cli {};

  import-garmin-connect = pkgs.python3Packages.callPackage ./pkgs/import-garmin-connect {};

  salt-py3 = pkgs.callPackage ./pkgs/salt-py3 {};

  salt-lint = pkgs.callPackage ./pkgs/salt-lint {
    salt = salt-py3;
  };

  prometheus-unbound-exporter = pkgs.callPackage ./pkgs/prometheus-unbound-exporter {};

  tplink-configurator = pkgs.callPackage ./pkgs/tplink-configurator {};

  pg_flame = pkgs.callPackage ./pkgs/pg_flame {};

  goreleaser = pkgs.callPackage ./pkgs/goreleaser {};

  rofi-pulse = pkgs.callPackage ./pkgs/rofi-pulse { my-lib = lib; };

  bitwarden-rofi = pkgs.callPackage ./pkgs/bitwarden-rofi {};

}
