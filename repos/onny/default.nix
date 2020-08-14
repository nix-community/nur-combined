# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # applications/audio
  ocenaudio = pkgs.callPackage ./pkgs/applications/audio/ocenaudio { }; # FIXME
  
  # applications/audio
  # popcorntime = pkgs.callPackage ./pkgs/applications/video/popcorntime { }; # FIXME

  # applications/misc
  passwordsafe = pkgs.callPackage ./pkgs/applications/misc/passwordsafe { };

  # applications/networking/p2p
  fragments = pkgs.callPackage ./pkgs/applications/networking/p2p/fragments { };

  # applications/office
  foliate = pkgs.callPackage ./pkgs/applications/office/foliate { };

  # services/security
  inherit (pkgs.callPackage ./pkgs/services/security/opensnitch {}) opensnitchd opensnitch-ui;

  inherit (pkgs.callPackages ./pkgs/node-packages {}) hyperpotamus;

}

