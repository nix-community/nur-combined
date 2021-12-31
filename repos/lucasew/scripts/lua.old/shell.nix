{ pkgs ? import <nixpkgs> { } }:
let
  lua = pkgs.luajit.withPackages (ps: with ps; [
    lpeg
    lua-lsp
    luacheck
  ]);
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    lua
  ];
}
