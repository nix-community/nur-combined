# default.nix - Package expression and NUR entrypoint for SEOWebChecker
# Homepage: https://seowebchecker.com/
{ pkgs ? import <nixpkgs> { } }:

rec {
  # Main CLI derivation
  seowebchecker = pkgs.callPackage ./nix/package.nix { };
  default = seowebchecker;

  # NixOS modules namespace for NUR and system configurations
  modules = {
    seowebchecker = ./nix/module.nix;
    default = ./nix/module.nix;
  };

  # Overlays
  overlays = {
    default = final: prev: {
      seowebchecker = prev.callPackage ./nix/package.nix { };
    };
  };
}
