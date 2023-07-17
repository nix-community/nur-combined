# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: rec {
  git-credential-manager = pkgs.callPackage ./pkgs/git-credential-manager {};
  github-linguist = pkgs.callPackage ./pkgs/github-linguist {};
  millipixels = pkgs.callPackage ./pkgs/millipixels {};
  nanoemoji = pkgs.callPackage ./pkgs/nanoemoji {};
  openmoji = pkgs.callPackage ./pkgs/openmoji {inherit nanoemoji;};
  pkcs11-provider = pkgs.callPackage ./pkgs/pkcs11-provider.nix {};
  sea-orm-cli = pkgs.callPackage ./pkgs/sea-orm-cli {};
  swayaudioidleinhibit = pkgs.callPackage ./pkgs/swayaudioidleinhibit.nix {};
  synapse-find-unreferenced-state-groups = pkgs.callPackage ./pkgs/synapse-find-unreferenced-state-groups.nix {};
}
