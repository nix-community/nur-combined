{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  out = buildGoPackage {
    name = "gopls-git";
    goPackagePath = "golang.org/x/tools";
    src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));
    goDeps = ./deps.nix;
    subPackages = [ "gopls" ];
  };
in out
