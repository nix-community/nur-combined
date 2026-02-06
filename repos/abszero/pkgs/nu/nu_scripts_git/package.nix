{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-05";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "4444335709d0c9f8291ac925b0854d91132f6ffc";
      hash = "sha256-50uIcHHV3yPX91KRxDrMmG1eaSfw08CNG/S86CM08P0=";
    };
  }
)
