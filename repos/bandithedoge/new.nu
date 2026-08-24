#!/usr/bin/env nu

def main [name: string] {
    mkdir $"pkgs/($name)"
    $"{
      lib,
      nix-update-script,
      stdenv,
    }:
    stdenv.mkDerivation {
      pname = \"($name)\";
      version = \"\";
      src = null;

      passthru.updateScript = nix-update-script {};

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
