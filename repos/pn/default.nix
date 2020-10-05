# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
  wrapNeomutt = pkgs.callPackage ./pkgs/neomutt_configurable/wrapper.nix { };
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  st = pkgs.callPackage ./pkgs/st { };
  dwm = pkgs.callPackage ./pkgs/dwm { };
  pndwm = pkgs.callPackage ./pkgs/dwm/pndwm.nix { };
  dwmblocks = pkgs.callPackage ./pkgs/dwmblocks { };
  dmenu = pkgs.callPackage ./pkgs/dmenu { };
  xwallpaper = pkgs.callPackage ./pkgs/xwallpaper { };
  libthinkpad = pkgs.callPackage ./pkgs/libthinkpad { };
  dockd = pkgs.callPackage ./pkgs/dockd { };
  larbs-mail = pkgs.callPackage ./pkgs/larbs-mail { };
  larbs-news = pkgs.callPackage ./pkgs/larbs-news { };
  dmenuunicode = pkgs.callPackage ./pkgs/dmenuunicode { };
  larbs-nvim = pkgs.callPackage ./pkgs/larbs-nvim { };

  #fx = (pkgs.callPackage ./pkgs/fx { }).package;
  # xcb-util = pkgs.callPackage ./pkgs/xcb-util { }; #unknown error
  amfora = pkgs.callPackage ./pkgs/amfora { };
  # ...
}
