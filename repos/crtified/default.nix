# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ldap-sshkp = pkgs.haskellPackages.callPackage ./pkgs/ldap-sshkp { };

  mfbot = pkgs.callPackage ./pkgs/mfbot { };

  mfc_l2710dn = pkgs.callPackage ./pkgs/mfc_l2710dn { };
  hl_l2370dn = pkgs.callPackage ./pkgs/hl_l2370dn { };
  phaser_3020 = pkgs.callPackage ./pkgs/phaser_3020 { };

  python3Packages = pkgs.recurseIntoAttrs
    (pkgs.python3Packages.callPackage ./pkgs/python-pkgs { });

  self-service-password = pkgs.callPackage ./pkgs/self-service-password { };

  unflac = pkgs.callPackage ./pkgs/unflac { };
}
