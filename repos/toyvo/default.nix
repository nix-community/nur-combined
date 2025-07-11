# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs ? import <nixpkgs> { },
}:
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  catppuccin-papirus-folders-frappe-red = pkgs.catppuccin-papirus-folders.override {
    flavor = "frappe";
    accent = "red";
  };
  catppuccin-papirus-folders-latte-red = pkgs.catppuccin-papirus-folders.override {
    flavor = "latte";
    accent = "red";
  };
  catppuccin-papirus-folders-latte-pink = pkgs.catppuccin-papirus-folders.override {
    flavor = "latte";
    accent = "pink";
  };
  catpuccin-kde-frappe-red = pkgs.catppuccin-kde.override {
    flavour = [ "frappe" ];
    accents = [ "red" ];
    winDecStyles = [ "classic" ];
  };
  catpuccin-kde-latte-red = pkgs.catppuccin-kde.override {
    flavour = [ "latte" ];
    accents = [ "red" ];
    winDecStyles = [ "classic" ];
  };
  catpuccin-kde-latte-pink = pkgs.catppuccin-kde.override {
    flavour = [ "latte" ];
    accents = [ "pink" ];
    winDecStyles = [ "classic" ];
  };
  libpcpnatpmp = pkgs.callPackage ./pkgs/libpcpnatpmp.nix { };
  purpurServers = pkgs.callPackages ./pkgs/purpur { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
