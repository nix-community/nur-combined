{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-24";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "c395baa5e0c7bb8376b84e13c55f4b8781a718d5";
      hash = "sha256-emX5Uzy5zrFP7TOP780l8H0fXN7Jut/eape9i1IgD68=";
    };
  }
)
