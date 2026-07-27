#!/usr/bin/env nu

def main [
    name: string
] {
    mkdir $"pkgs/($name)"
    $"[($name)]\n" | save $"pkgs/($name)/nvfetcher.toml"
    $"{
      sources,

      lib,
      stdenv,
    }:
    stdenv.mkDerivation {
      inherit \(sources.($name)) pname version src;

      # meta = {
      #   description = \"\";
      #   homepage = \"\";
      #   license = null;
      #   platforms = [];
      #   sourceProvenance = [];
      #   mainProgram = "";
      #   maintainers = [ lib.maintainers.bandithedoge ];
      # };
    }" | nixfmt - | save $"pkgs/($name)/package.nix"
    print $"created new package at pkgs/($name)"
}
