{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

rec {
  # If you have lib, modules, overlays (optional)
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
  
  # Explicitly list your packages
  chatterino = lib.callPackage "chatterino" ./pkgs/chat/chatterino;
  kobo-desktop = pkgs.callPackage ./pkgs/media/kobo-desktop { };
  openaudible = pkgs.callPackage ./pkgs/media/openaudible { };
  ps-remote-play = pkgs.callPackage ./pkgs/gaming/ps-remote-play { };
}
