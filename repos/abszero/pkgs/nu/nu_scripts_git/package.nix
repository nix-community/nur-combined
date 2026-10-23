{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-23";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "ce434708a3d55a2ee0112330a191dec83a35d617";
      hash = "sha256-uFddCJp620/9cKDvm6okTke5KSs6VwgduGuk1THNksA=";
    };
  }
)
