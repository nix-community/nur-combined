{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

rec {
  # If you have lib, modules, overlays (optional)
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
  
  # Explicitly list your packages
  chatterino = lib.callPackage "chatterino" ./pkgs/chat/chatterino;
  kobo-desktop = pkgs.callPackage ./pkgs/media/kobo-desktop { };
  openaudible = lib.callPackage "openaudible" ./pkgs/media/openaudible;
  ps-remote-play = lib.callPackage "ps-remote-play" ./pkgs/gaming/ps-remote-play;
  alfred5 = pkgs.callPackage ./pkgs/utilities/alfred5 { };
  balenaEtcher = lib.callPackage "balenaEtcher" ./pkgs/utilities/balenaEtcher;
  garmin-basecamp = lib.callPackage "garmin-basecamp" ./pkgs/other/garmin-basecamp;
}
