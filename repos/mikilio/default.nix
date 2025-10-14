# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib hostPlatform;
  ifSupported = with lib; (
    attr:
      mapAttrsRecursiveCond
      (as: as?recurseForDerivations && as.recurseForDerivations)
      (_: v:
        if (meta.availableOn hostPlatform v)
        then v
        else null)
      attr
  );
in
  {
    # The `lib`, `modules`, and `overlay` names are special
    lib = import ./lib {inherit pkgs;}; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays {inherit pkgs;}; # nixpkgs overlays
  }
  // ifSupported (with pkgs; {
    rclone_zus = callPackage ./pkgs/rclone_zus {};
    xdg-terminal-exec = callPackage ./pkgs/xdg-terminal-exec {};
    ttf-ms-fonts = callPackage ./pkgs/ttf-ms-fonts {};
    xmclib = callPackage ./pkgs/xmclib {};
  })
