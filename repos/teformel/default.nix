# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  # LingmoOS packages temporarily disabled (2026-06-23)
  # Was using pinned nixpkgs for Qt6/KF5 — reactivate when ready to build LingmoOS
  #
  # pkgsKF5 = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/600b15aea1b36eeb43833a50b0e96579147099ff.tar.gz";
  #   sha256 = "1hhr6zg8mrpbjmyqk70l296prs4241qwx0yx9lwsldxiqxcc7l2k";
  # }) { system = pkgs.system; };
  # pkgsQt6Legacy = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/600b15aea1b36eeb43833a50b0e96579147099ff.tar.gz";
  #   sha256 = "1hhr6zg8mrpbjmyqk70l296prs4241qwx0yx9lwsldxiqxcc7l2k";
  # }) { system = pkgs.system; };
in
rec {
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  # 在这里导出你的包
  clash-party = pkgs.callPackage ./pkgs/clash-party { };
  ww-manager = pkgs.callPackage ./pkgs/ww-manager { };
  
  # Lingmo OS 桌面套件（2026-06-23 暂时禁用）
  # 启用时需要同步恢复 let 中的 pkgsKF5 / pkgsQt6Legacy
  # lib_lingmo = pkgsQt6Legacy.callPackage ./pkgs/lib_lingmo { qt6 = pkgsQt6Legacy.kdePackages; };
  # lingmoui = pkgsQt6Legacy.callPackage ./pkgs/lingmoui { qt6 = pkgsQt6Legacy.kdePackages; };
  # lingmo-core = pkgsQt6Legacy.callPackage ./pkgs/lingmo-core { qt6 = pkgsQt6Legacy.kdePackages; inherit lingmoui; };
  # lingmo-settings = pkgsQt6Legacy.callPackage ./pkgs/lingmo-settings { qt6 = pkgsQt6Legacy.kdePackages; inherit lingmoui lingmo-core lib_lingmo; };
  # lingmo-dock = pkgsQt6Legacy.callPackage ./pkgs/lingmo-dock { qt6 = pkgsQt6Legacy.kdePackages; inherit lingmoui lingmo-core lib_lingmo; };
  # lingmo-launcher = pkgsQt6Legacy.callPackage ./pkgs/lingmo-launcher { qt6 = pkgsQt6Legacy.kdePackages; inherit lingmoui lingmo-core lib_lingmo; };
  # lingmo-desktop = pkgsKF5.libsForQt5.callPackage ./pkgs/lingmo-desktop { };
  # lingmo-daemon = pkgsKF5.libsForQt5.callPackage ./pkgs/lingmo-daemon { };
  # lingmo-filemanager = pkgsQt6Legacy.callPackage ./pkgs/lingmo-filemanager { qt6 = pkgsQt6Legacy.kdePackages; inherit lingmoui lingmo-core lib_lingmo; };
  # lingmo-kwin-plugins = pkgsQt6Legacy.callPackage ./pkgs/lingmo-kwin-plugins { qt6 = pkgsQt6Legacy.kdePackages; inherit lingmoui lingmo-core lib_lingmo; };
  # lingmo-screenlocker = pkgsKF5.libsForQt5.callPackage ./pkgs/lingmo-screenlocker { };
  # lingmo-polkit-agent = pkgsQt6Legacy.callPackage ./pkgs/lingmo-polkit-agent { qt6 = pkgsQt6Legacy.kdePackages; inherit lingmoui lingmo-core lib_lingmo; };
  # lingmo-sddm-theme = pkgs.callPackage ./pkgs/lingmo-sddm-theme { };
  # lingmo-statusbar = pkgsQt6Legacy.callPackage ./pkgs/lingmo-statusbar { qt6 = pkgsQt6Legacy.kdePackages; inherit lingmoui lingmo-core lib_lingmo; };
}
