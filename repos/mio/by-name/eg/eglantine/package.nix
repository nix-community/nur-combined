{
  lib,
  pkgs,
  fetchFromGitHub,
}:
let
  src = fetchFromGitHub {
    owner = "Eglantine-Community";
    repo = "Eglantine";
    rev = "67f3b57e9811424c5d4f627ca52b71a9dd545713";
    hash = "sha256-i/+2n/ZQX7ALLD1t47atoOrkpxlZl3gC9IMx3TxzN+I=";
  };
  tools = import ./build-eden-emulator.nix { inherit lib pkgs; };
in
pkgs.callPackage ./upstream.nix {
  inherit src;
  version = "0.1.0-rc4-unstable-2026-11-25";
  inherit (tools) buildEdenEmulator;
}
