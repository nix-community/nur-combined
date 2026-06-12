# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv) hostPlatform;
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
  // ifSupported (with pkgs; rec {
    snapshot-yazi = callPackage ./pkgs/snapshot-yazi {};
    gateway-st = callPackage ./pkgs/gateway-st {};
    rclone_zus = callPackage ./pkgs/rclone_zus {};
    rosec = callPackage ./pkgs/rosec {};
    rosec-bitwarden-pm = pkgsCross.wasi32.callPackage ./pkgs/rosec/provider/rosec-bitwarden-pm.nix {inherit rosec;};
    rosec-bitwarden-sm = pkgsCross.wasi32.callPackage ./pkgs/rosec/provider/rosec-bitwarden-sm.nix {inherit rosec;};
    rosec-gnome-keyring = pkgsCross.wasi32.callPackage ./pkgs/rosec/provider/rosec-gnome-keyring.nix {inherit rosec;};
    rosecFull = callPackage ./pkgs/rosec {
      provider = [
        rosec-bitwarden-pm
        rosec-bitwarden-sm
        rosec-gnome-keyring
      ];
    };
    xdg-terminal-exec = callPackage ./pkgs/xdg-terminal-exec {};
    xmclib = callPackage ./pkgs/xmclib {};
    gaia = callPackage ./pkgs/gaia {};
    essentia = callPackage ./pkgs/essentia {inherit gaia;};
  })
