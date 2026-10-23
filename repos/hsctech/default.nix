{ pkgs ? import <nixpkgs> { } }:

{
  overlays = import ./overlays;

  blobl_lsp = pkgs.callPackage ./pkgs/blobl_lsp { };
  helix-blobl = pkgs.callPackage ./pkgs/helix-blobl { };
  tree-sitter-bloblang = pkgs.callPackage ./pkgs/tree-sitter-bloblang { };
}
