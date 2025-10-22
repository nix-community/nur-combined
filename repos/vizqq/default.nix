# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { overlays = builtins.attrValues (import ./overlays); },
}:
let
  sources = pkgs.callPackage ./_sources/generated.nix { };

in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  thinkpad-uefi-sign = pkgs.callPackage ./pkgs/thinkpad-uefi-sign {
    source = sources.thinkpad-uefi-sign;
  };
  huawei-password-tool = pkgs.callPackage ./pkgs/huawei-password-tool {
    source = sources.huawei-password-tool;
  };

  webcrack = pkgs.callPackage ./pkgs/webcrack { source = sources.webcrack; };

  pa = pkgs.callPackage ./pkgs/pa { source = sources.pa; };

  sway-disable-titlebar = import ./pkgs/sway-disable-titlebar { inherit pkgs; };
}
