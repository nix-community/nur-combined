# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

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
  
  # Lingmo OS 桌面套件
  lib_lingmo = pkgs.callPackage ./pkgs/lib_lingmo { };
  lingmoui = pkgs.callPackage ./pkgs/lingmoui { };
  lingmo-core = pkgs.callPackage ./pkgs/lingmo-core { inherit lingmoui; };
  lingmo-settings = pkgs.callPackage ./pkgs/lingmo-settings { inherit lingmoui lingmo-core lib_lingmo; };
  lingmo-dock = pkgs.callPackage ./pkgs/lingmo-dock { inherit lingmoui lingmo-core lib_lingmo; };
  lingmo-launcher = pkgs.callPackage ./pkgs/lingmo-launcher { inherit lingmoui lingmo-core lib_lingmo; };
  lingmo-desktop = pkgs.libsForQt5.callPackage ./pkgs/lingmo-desktop { };
  lingmo-daemon = pkgs.libsForQt5.callPackage ./pkgs/lingmo-daemon { };
  lingmo-filemanager = pkgs.callPackage ./pkgs/lingmo-filemanager { inherit lingmoui lingmo-core lib_lingmo; };
  lingmo-kwin-plugins = pkgs.callPackage ./pkgs/lingmo-kwin-plugins { inherit lingmoui lingmo-core lib_lingmo; };
  lingmo-screenlocker = pkgs.callPackage ./pkgs/lingmo-screenlocker { inherit lingmoui lingmo-core lib_lingmo; };
  lingmo-polkit-agent = pkgs.callPackage ./pkgs/lingmo-polkit-agent { inherit lingmoui lingmo-core lib_lingmo; };
  lingmo-sddm-theme = pkgs.callPackage ./pkgs/lingmo-sddm-theme { inherit lingmoui lingmo-core lib_lingmo; };
}
