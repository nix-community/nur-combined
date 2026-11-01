{ pkgs ? import <nixpkgs> { } }:

{
  overlays = import ./overlays;

  blobl_lsp = pkgs.callPackage ./pkgs/blobl_lsp { };
  blobl_dbg = pkgs.callPackage ./pkgs/blobl_dbg { };
  helix-blobl = pkgs.callPackage ./pkgs/helix-blobl { };
  tree-sitter-bloblang = pkgs.callPackage ./pkgs/tree-sitter-bloblang { };
}
