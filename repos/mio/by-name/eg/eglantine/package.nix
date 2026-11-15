{
  lib,
  pkgs,
  fetchFromGitHub,
}:
let
  src = fetchFromGitHub {
    owner = "Eglantine-Community";
    repo = "Eglantine";
    rev = "cf6cfe9caa6e160d3562742308a38eb3c9014789";
    hash = "sha256-uthxYLTWVefybE06oUjmZ2OfCb5GGaVW3gLUnETozuk=";
  };
  tools = import ./build-eden-emulator.nix { inherit lib pkgs; };
in
pkgs.callPackage ./upstream.nix {
  inherit src;
  version = "0.1.0-rc4-unstable-2026-11-15";
  inherit (tools) buildEdenEmulator;
}
