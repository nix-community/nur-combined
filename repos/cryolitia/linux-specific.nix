# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  ryzen-smu = pkgs.linuxPackages.callPackage ./pkgs/linux/ryzen-smu.nix { };

  bmi260 = pkgs.linuxPackages.callPackage ./pkgs/linux/bmi260.nix { };

  ryzen-smu-zen = pkgs.linuxPackages_zen.callPackage ./pkgs/linux/ryzen-smu.nix { };

  bmi260-zen = pkgs.linuxPackages_zen.callPackage ./pkgs/linux/bmi260.nix { };

  ryzen-smu-latest = pkgs.linuxPackages_latest.callPackage ./pkgs/linux/ryzen-smu.nix { };

  bmi260-latest = pkgs.linuxPackages_latest.callPackage ./pkgs/linux/bmi260.nix { };
}
