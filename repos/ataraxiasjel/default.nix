{ pkgs ? import <nixpkgs> { } }:

with pkgs; with lib; {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  a2ln = python3Packages.callPackage ./pkgs/a2ln { };
  proton-ge = callPackage ./pkgs/proton-ge { };
  arkenfox-userjs = callPackage ./pkgs/arkenfox-userjs { };
  bibata-cursors-tokyonight = callPackage ./pkgs/bibata-cursors-tokyonight { };
  ceserver = callPackage ./pkgs/ceserver { };
  mpris-ctl = callPackage ./pkgs/mpris-ctl { };
  protonhax = callPackage ./pkgs/protonhax { };
  reshade-shaders = callPackage ./pkgs/reshade-shaders { };
  seadrive-fuse = callPackage ./pkgs/seadrive-fuse { };
  waydroid-script = callPackage ./pkgs/waydroid-script { };

  inherit (callPackage ./pkgs/rosepine-gtk {}) rosepine-gtk-theme rosepine-gtk-icons;
  inherit (callPackage ./pkgs/tokyonight-gtk {}) tokyonight-gtk-theme tokyonight-gtk-icons;
  roundcubePlugins = dontRecurseIntoAttrs (callPackage ./pkgs/roundcube-plugins { });
}
