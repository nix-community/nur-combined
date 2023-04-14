# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  github-linguist = pkgs.callPackage ./pkgs/github-linguist {};
  pkcs11-provider = pkgs.callPackage ./pkgs/pkcs11-provider.nix {};
  sea-orm-cli = pkgs.callPackage ./pkgs/sea-orm-cli {};
  swayaudioidleinhibit = pkgs.callPackage ./pkgs/swayaudioidleinhibit.nix {};
  waybar-mpris = pkgs.callPackage ./pkgs/waybar-mpris.nix {};
}
