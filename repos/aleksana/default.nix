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

  # example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...

  my-grimblast = pkgs.callPackage ./pkgs/my-grimblast { };
  gvim-lily = pkgs.callPackage ./pkgs/gvim-lily { };
  neovim-remote-go = pkgs.callPackage ./pkgs/neovim-remote-go { };
  yofi = pkgs.callPackage ./pkgs/yofi { };
  fcitx5-pinyin-cedict = pkgs.callPackage ./pkgs/fcitx5-pinyin-cedict { };
  fcitx5-pinyin-chinese-idiom = pkgs.callPackage ./pkgs/fcitx5-pinyin-chinese-idiom { };
  fcitx5-pinyin-ff14 = pkgs.callPackage ./pkgs/fcitx5-pinyin-ff14 { };
  fcitx5-pinyin-moegirl = pkgs.callPackage ./pkgs/fcitx5-pinyin-moegirl { };
  fcitx5-pinyin-zhwiki = pkgs.callPackage ./pkgs/fcitx5-pinyin-zhwiki { };
}
