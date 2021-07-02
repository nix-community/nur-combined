{ pkgs ? import <nixpkgs> { } }:

rec {
  # Custom lib, modules and other stuff
  modules = import ./modules/default.nix;

  lib = import ./lib/default.nix { inherit (pkgs) lib; };

  # Custom packages
  rofi-unwrapped-git = pkgs.callPackage ./pkgs/rofi-unwrapped-git { };
  emojipicker = pkgs.callPackage ./pkgs/emojipicker { };
  powermenu =
    pkgs.callPackage ./pkgs/adi1090x/powermenu { inherit rofi-unwrapped-git; };
  launchers-git = pkgs.callPackage ./pkgs/adi1090x/launchers-git {
    inherit rofi-unwrapped-git;
  };
  polybar-1 = pkgs.callPackage ./pkgs/adi1090x/polybar-themes/polybar-1 { };
  polybar-3 = pkgs.callPackage ./pkgs/adi1090x/polybar-themes/polybar-3 { };

  dwm-patches = pkgs.callPackage ./pkgs/dwm/patches.nix { };
  dwm = pkgs.callPackage ./pkgs/dwm/dwm.nix { };

  caia = pkgs.callPackage ./pkgs/caia { inherit caia-unwrapped; };
  caia-unwrapped = pkgs.callPackage ./pkgs/caia/unwrapped.nix { };

  digital = pkgs.callPackage ./pkgs/digital { };

  ytfzf = pkgs.callPackage ./pkgs/ytfzf { };

  # build-support
  makeDevEnv = pkgs.callPackage ./pkgs/build-support/makeDevEnv { };
}
