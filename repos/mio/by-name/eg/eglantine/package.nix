{
  lib,
  pkgs,
  fetchFromGitHub,
}:
let
  src = fetchFromGitHub {
    owner = "Eglantine-Community";
    repo = "Eglantine";
    rev = "ed46267d81d34cde07e129132aa3c145bb104c25";
    hash = "sha256-+lELtnbGYLktWBERR5BTYiDmLLMRApvdviGDqh+oG4Y=";
  };
  tools = import ./build-eden-emulator.nix { inherit lib pkgs; };
in
pkgs.callPackage ./upstream.nix {
  inherit src;
  version = "0.1.0-rc4-unstable-2026-11-26";
  inherit (tools) buildEdenEmulator;
}
