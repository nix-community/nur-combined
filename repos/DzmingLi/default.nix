# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  lib = pkgs.lib;
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  _115browser = pkgs.callPackage ./pkgs/115br { };
  baidupcs-go = pkgs.callPackage ./pkgs/baidupcs-go { };
  blueprint-mcp = pkgs.callPackage ./pkgs/blueprint-mcp { };
  context7-mcp = pkgs.callPackage ./pkgs/context7-mcp { };
  genryumin-tc = pkgs.callPackage ./pkgs/genryumin { };
  gotham-fonts = pkgs.callPackage ./pkgs/gotham-fonts { };
  huiwen-mincho = pkgs.callPackage ./pkgs/huiwen-mincho { };
  moonbit = pkgs.callPackage ./pkgs/moonbit { };
  nix-plugin-pijul = pkgs.callPackage ./pkgs/nix-plugin-pijul { };
  quarkpantool = pkgs.callPackage ./pkgs/quarkpantool { };
  TRWUDMincho = pkgs.callPackage ./pkgs/TRWUDMincho { };
  waydroid-script = pkgs.callPackage ./pkgs/waydroid-script { };
  wechat = pkgs.callPackage ./pkgs/wechat { };
  windows-fonts = pkgs.callPackage ./pkgs/windows-fonts { };
}
