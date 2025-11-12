# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  zju-connect = pkgs.callPackage ./pkgs/zju-connect {};
  wpsoffice = pkgs.libsForQt5.callPackage ./pkgs/wpsoffice { };
  wpsoffice-cn = pkgs.libsForQt5.callPackage ./pkgs/wpsoffice { useCn=true; };
  wechat-universal-bwrap = pkgs.callPackage ./pkgs/wechat-universal-bwrap { };
  wemeet-bin-bwrap = pkgs.libsForQt5.callPackage ./pkgs/wemeet-bin-bwrap { };
  wemeet-bin-bwrap-wayland-screenshare = pkgs.libsForQt5.callPackage ./pkgs/wemeet-bin-bwrap { useWaylandScreenshare = true; };
  nvim-vscode-colorscheme = pkgs.callPackage ./pkgs/nvim-vscode-colorscheme { };
  suyu = pkgs.callPackage ./pkgs/suyu { };
  latex-chinese-fonts = pkgs.callPackage ./pkgs/latex-chinese-fonts { };
  zzz = pkgs.callPackage ./pkgs/zzz { };
  wpsoffice-365 = pkgs.libsForQt5.callPackage ./pkgs/wpsoffice-365 { };
  FuzzyMarks = pkgs.callPackage ./pkgs/FuzzyMarks { };
  vita3k = pkgs.callPackage ./pkgs/vita3k { };
  gedit = pkgs.callPackage ./pkgs/gedit { };
  zen-browser-bin = pkgs.callPackage ./pkgs/zen-browser { };
  wechat-appimage = pkgs.callPackage ./pkgs/wechat-appimage { };
  dingtalk = pkgs.callPackage ./pkgs/dingtalk {};
  baidunetdisk = pkgs.callPackage ./pkgs/baidunetdisk {
    electron_11 = pkgs.callPackage ./pkgs/baidunetdisk/electron_11.nix {};
  };
  shotcut-bin = pkgs.callPackage ./pkgs/shotcut {};
  hmcl = pkgs.callPackage ./pkgs/hmcl {};
  mangowc = pkgs.callPackage ./pkgs/mangowc {};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
}
