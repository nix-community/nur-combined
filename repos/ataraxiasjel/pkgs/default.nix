{ pkgs ? import <nixpkgs> { } }:

with pkgs; with lib; {
  lib = import ../lib { inherit pkgs; };
  modules = import ../modules;
  overlays = import ../overlays;

  a2ln = python3Packages.callPackage ./a2ln { };
  proton-ge = callPackage ./proton-ge { };
  arkenfox-userjs = callPackage ./arkenfox-userjs { };
  bibata-cursors-tokyonight = callPackage ./bibata-cursors-tokyonight { };
  ceserver = callPackage ./ceserver { };
  mpris-ctl = callPackage ./mpris-ctl { };
  protonhax = callPackage ./protonhax { };
  reshade-shaders = callPackage ./reshade-shaders { };
  seadrive-fuse = callPackage ./seadrive-fuse { };
  waydroid-script = callPackage ./waydroid-script { };

  inherit (callPackage ./rosepine-gtk {}) rosepine-gtk-theme rosepine-gtk-icons;
  inherit (callPackage ./tokyonight-gtk {}) tokyonight-gtk-theme tokyonight-gtk-icons;
  roundcubePlugins = dontRecurseIntoAttrs (callPackage ./roundcube-plugins { });
}
