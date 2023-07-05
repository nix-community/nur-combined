{ pkgs ? import <nixpkgs> { } }:

with pkgs; with lib; {
  lib = import ../lib { inherit pkgs; };
  modules = import ../modules;
  overlays = import ../overlays;

  a2ln = python3Packages.callPackage ./a2ln { };
  arkenfox-userjs = callPackage ./arkenfox-userjs { };
  bibata-cursors-tokyonight = callPackage ./bibata-cursors-tokyonight { };
  ceserver = callPackage ./ceserver { };
  gruvbox-plus-icons = callPackage ./gruvbox-plus-icons { };
  mpris-ctl = callPackage ./mpris-ctl { };
  proton-ge = callPackage ./proton-ge { };
  protonhax = callPackage ./protonhax { };
  reshade-shaders = callPackage ./reshade-shaders { };
  rpcs3 = libsForQt5.callPackage ./rpcs3 { };
  seadrive-fuse = callPackage ./seadrive-fuse { };
  waydroid-script = callPackage ./waydroid-script { };

  inherit (callPackage ./rosepine-gtk {}) rosepine-gtk-theme rosepine-gtk-icons;
  inherit (callPackage ./tokyonight-gtk {}) tokyonight-gtk-theme tokyonight-gtk-icons;
  roundcubePlugins = dontRecurseIntoAttrs (callPackage ./roundcube-plugins { });
}
