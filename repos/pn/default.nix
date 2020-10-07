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


  libthinkpad = pkgs.callPackage ./pkgs/libthinkpad { };
  dockd = pkgs.callPackage ./pkgs/dockd { };
  simple-mtpfs = pkgs.callPackage ./pkgs/simple-mtpfs { };
  task-spooler = pkgs.callPackage ./pkgs/task-spooler { };

  st = pkgs.callPackage ./pkgs/larbs/st { };
  dwm = pkgs.callPackage ./pkgs/larbs/dwm { };
  dwmblocks = pkgs.callPackage ./pkgs/larbs/dwmblocks { };
  dmenu = pkgs.callPackage ./pkgs/larbs/dmenu { };

  larbs-mail = pkgs.callPackage ./pkgs/larbs-mail { };
  larbs-news = pkgs.callPackage ./pkgs/larbs-news { };
  larbs-nvim = pkgs.callPackage ./pkgs/larbs-nvim { };
  larbs-scripts = pkgs.callPackage ./pkgs/larbs-scripts { };

  #fx = (pkgs.callPackage ./pkgs/fx { }).package;
  # xcb-util = pkgs.callPackage ./pkgs/xcb-util { }; #unknown error
  # ...
}
