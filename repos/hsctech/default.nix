{ pkgs ? import <nixpkgs> { } }:

{
  overlays = import ./overlays;

  blobl_lsp = pkgs.callPackage ./pkgs/blobl_lsp { };
}
