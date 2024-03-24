# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

builtins.trace "「我书写，则为我命令。我陈述，则为我规定。」"

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  maa-assistant-arknights = pkgs.callPackage ./pkgs/maa-assistant-arknights { };

  maa-assistant-arknights-beta = maa-assistant-arknights.override { isBeta = true; };

  onnxruntime-cuda-bin = pkgs.callPackage ./pkgs/maa-assistant-arknights/onnxruntime-cuda-bin.nix { };

  MaaX = pkgs.callPackage ./pkgs/MaaX { };

  maa-cli = pkgs.callPackage ./pkgs/maa-assistant-arknights/maa-cli.nix { inherit maa-assistant-arknights; };

  rime-latex = pkgs.callPackage ./pkgs/rimePackages/rime-latex.nix { };

  rime-project-trans = pkgs.callPackage ./pkgs/rimePackages/rime-project-trans.nix { };

  telegram-desktop-fix-webview = pkgs.qt6Packages.callPackage ./pkgs/common/telegram-desktop.nix { };
}
