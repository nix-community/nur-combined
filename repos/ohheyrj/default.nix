
{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  lib = import ./lib { inherit pkgs; };

  generated = import ./_sources/generated.nix {
    inherit (pkgs) fetchurl fetchgit fetchFromGitHub dockerTools;
  };
in rec {
  inherit lib;

  modules = import ./modules;
  overlays = import ./overlays;

  # Packages
  chatterino = lib.callPackage "chatterino" ./pkgs/chat/chatterino;
  kobo-desktop = pkgs.callPackage ./pkgs/media/kobo-desktop { };
  openaudible = lib.callPackage "openaudible" ./pkgs/media/openaudible;
  ps-remote-play = lib.callPackage "ps-remote-play" ./pkgs/gaming/ps-remote-play;
  alfred5 = pkgs.callPackage ./pkgs/utilities/alfred5 { };
  balenaEtcher = lib.callPackage "balenaEtcher" ./pkgs/utilities/balenaEtcher;
  garmin-basecamp = lib.callPackage "garmin-basecamp" ./pkgs/other/garmin-basecamp;
  bartender5 = lib.callPackage "bartender5" ./pkgs/utilities/bartender5;
  cryptomator = lib.callPackage "cryptomator" ./pkgs/utilities/cryptomator;
  handbrake = lib.callPackage "handbrake" ./pkgs/media/handbrake;
  signal-desktop = lib.callPackage "signal-desktop" ./pkgs/chat/signal-desktop;
  hazel = lib.callPackage "hazel" ./pkgs/utilities/hazel;
  
  komiser = pkgs.callPackage ./pkgs/utilities/komiser {
    generatedDarwinArm64 = generated."komiser-darwin-arm64";
    generatedDarwinX86   = generated."komiser-darwin-x86";
    generatedLinuxX86    = generated."komiser-linux-x86";
  };

  gitkraken-cli = pkgs.callPackage ./pkgs/utilities/gitkraken-cli {
    generatedDarwinArm64 = generated."gitkraken-cli-darwin-arm64";
    generatedDarwinX86   = generated."gitkraken-cli-darwin-x86";
  };
}

