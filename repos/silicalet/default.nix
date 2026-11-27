# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

let
  lockedInput =
    name:
    let
      inherit ((builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.${name}.locked)
        owner
        repo
        rev
        narHash
        ;
    in
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = narHash;
    };
in
{
  cangjieBuildPkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/50ab793786d9de88ee30ec4e4c24fb4236fc2674.tar.gz";
    sha256 = "sha256-/bVBlRpECLVzjV19t5KMdMFWSwKLtb5RyXdjz3LJT+g=";
  }) { system = pkgs.stdenv.hostPlatform.system; },
  craneSrc ? lockedInput "crane",
  rustOverlaySrc ? lockedInput "rust-overlay",
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules;
  homeModules = import ./home-modules;
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
  neomacs-bin = pkgs.callPackage ./pkgs/apps/neomacs/binary.nix { };
  neu-cli = pkgs.callPackage ./pkgs/tools/neu-cli { };
  nodecode-bin = pkgs.callPackage ./pkgs/tools/nodecode/binary.nix { };
  # nyaterm source builds are too heavy; use nyaterm-bin.
  # nyaterm = pkgs.callPackage ./pkgs/apps/nyaterm { };
  nyaterm-bin = pkgs.callPackage ./pkgs/apps/nyaterm/binary.nix { };
  oh-dsh-bin = pkgs.callPackage ./pkgs/apps/oh-dsh/binary.nix { };
  qrypt-bin = pkgs.callPackage ./pkgs/tools/qrypt/binary.nix { };
  quarkpan = pkgs.callPackage ./pkgs/tools/quarkpan { };
  quien = pkgs.callPackage ./pkgs/tools/quien { };
  rea = pkgs.callPackage ./pkgs/ctf/rea { };
  rea-full = pkgs.callPackage ./pkgs/ctf/rea/full.nix {
    rea = pkgs.callPackage ./pkgs/ctf/rea { };
    reaDependencies = (import ./lib { inherit pkgs; }).reaDependencies;
  };
  seekey = pkgs.callPackage ./pkgs/apps/seekey { };
  uipro-cli = pkgs.callPackage ./pkgs/tools/uipro-cli { };
  winpodx-bin = pkgs.callPackage ./pkgs/apps/winpodx/binary.nix { };
  zlib-cli = pkgs.callPackage ./pkgs/tools/zlib-cli { };
}
//
  pkgs.lib.optionalAttrs
    (builtins.elem pkgs.stdenv.hostPlatform.system [
      "x86_64-linux"
      "aarch64-linux"
    ])
    {
      honk = pkgs.callPackage ./pkgs/tools/honk {
        craneLib = import craneSrc { inherit pkgs; };
        rust-bin = (pkgs.buildPackages.extend (import rustOverlaySrc)).rust-bin;
      };
      honk-bin = pkgs.callPackage ./pkgs/tools/honk/binary.nix { };
    }
// (pkgs.callPackage ./pkgs/apps/craft-suite { })
