# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: rec {
  cargo-vibe = pkgs.callPackage ./pkgs/cargo-vibe {};
  explode = pkgs.callPackage ./pkgs/explode {};
  github-linguist = pkgs.callPackage ./pkgs/github-linguist {};
  openmoji = pkgs.callPackage ./pkgs/openmoji {};
  openmojiPackage = pkgs.callPackage ./pkgs/openmoji/single.nix {inherit openmoji;};
  pkcs11-provider = pkgs.callPackage ./pkgs/pkcs11-provider.nix {};
  subwoofer = pkgs.callPackage ./pkgs/subwoofer {};
  swayaudioidleinhibit = pkgs.callPackage ./pkgs/swayaudioidleinhibit.nix {};
  synapse-find-unreferenced-state-groups = pkgs.callPackage ./pkgs/synapse-find-unreferenced-state-groups.nix {};
  what = pkgs.callPackage ./pkgs/what {};
  wys = pkgs.callPackage ./pkgs/wys {};
}
