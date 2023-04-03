# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  youtube-tui = pkgs.callPackage ./pkgs/youtube-tui { };
  # ytermusic = pkgs.callPackage ./pkgs/ytermusic { };
  bilibili_live_tui = pkgs.callPackage ./pkgs/bilibili_live_tui { };
  aichat = pkgs.callPackage ./pkgs/aichat { };
  swww = pkgs.callPackage ./pkgs/swww { };
  chatgpt-cli = pkgs.callPackage ./pkgs/chatgpt-cli { };
  go-musicfox = pkgs.callPackage ./pkgs/go-musicfox { };
  catppuccin-cursors = pkgs.callPackage ./pkgs/catppuccin-cursors { };
  catppuccin-latte-gtk = pkgs.callPackage ./pkgs/catppuccin-latte-gtk { };
  catppuccin-frappe-gtk = pkgs.callPackage ./pkgs/catppuccin-frappe-gtk { };
  fcitx5-pinyin-zhwiki = pkgs.callPackage ./pkgs/fcitx5-pinyin-zhwiki { };
  fcitx5-pinyin-moegirl = pkgs.callPackage ./pkgs/fcitx5-pinyin-moegirl { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
