# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  cangjieBuildPkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/50ab793786d9de88ee30ec4e4c24fb4236fc2674.tar.gz";
    sha256 = "sha256-/bVBlRpECLVzjV19t5KMdMFWSwKLtb5RyXdjz3LJT+g=";
  }) { system = pkgs.stdenv.hostPlatform.system; },
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  amber-lsp = pkgs.callPackage ./pkgs/tools/amber-lsp { };
  cangjie = pkgs.callPackage ./pkgs/lang/cangjie { inherit cangjieBuildPkgs; };
  cangjie-bin = pkgs.callPackage ./pkgs/lang/cangjie/binary.nix { };
  code996 = pkgs.callPackage ./pkgs/tools/code996 { };
  dnspick = pkgs.callPackage ./pkgs/tools/dnspick { };
  folia-major-bin = pkgs.callPackage ./pkgs/apps/folia-major/binary.nix { };
  ghost-downloader-3 = pkgs.callPackage ./pkgs/apps/ghost-downloader-3 { };
  ipgw = pkgs.callPackage ./pkgs/tools/ipgw { };
  kuake-cli = pkgs.callPackage ./pkgs/tools/kuake-cli { };
  meatshell = pkgs.callPackage ./pkgs/apps/meatshell { };
  meatshell-bin = pkgs.callPackage ./pkgs/apps/meatshell/binary.nix { };
  modeltrace = pkgs.callPackage ./pkgs/apps/modeltrace { };
  neomacs-bin = pkgs.callPackage ./pkgs/apps/neomacs/binary.nix { };
  # nyaterm source builds are too heavy; use nyaterm-bin.
  # nyaterm = pkgs.callPackage ./pkgs/apps/nyaterm { };
  nyaterm-bin = pkgs.callPackage ./pkgs/apps/nyaterm/binary.nix { };
  oh-dsh-bin = pkgs.callPackage ./pkgs/apps/oh-dsh/binary.nix { };
  quarkpan = pkgs.callPackage ./pkgs/tools/quarkpan { };
  quien = pkgs.callPackage ./pkgs/tools/quien { };
  seekey = pkgs.callPackage ./pkgs/apps/seekey { };
  uipro-cli = pkgs.callPackage ./pkgs/tools/uipro-cli { };
  winpodx-bin = pkgs.callPackage ./pkgs/apps/winpodx/binary.nix { };
  zlib-cli = pkgs.callPackage ./pkgs/tools/zlib-cli { };
}
