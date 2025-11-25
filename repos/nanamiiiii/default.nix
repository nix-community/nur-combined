{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  #microsoft-edge = pkgs.callPackage ./pkgs/microsoft-edge { };
  sddm-astronaut = pkgs.callPackage ./pkgs/sddm-astronaut { };
  clock-tui = pkgs.callPackage ./pkgs/clock-tui { };
  xpipe = pkgs.callPackage ./pkgs/xpipe { };
  wl-x11-clipsync = pkgs.callPackage ./pkgs/wl-x11-clipsync { };
  md2puki = pkgs.callPackage ./pkgs/md2puki { };
}
