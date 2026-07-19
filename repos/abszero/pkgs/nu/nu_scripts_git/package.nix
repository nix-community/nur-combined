{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-07-18";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "8311fa45e8c9d3f467fd668c7338f3e9390404bf";
      hash = "sha256-uH3l/wwiUP2kDJe1GE9vKlkTRYG3fnaspCrDEfgeMYI=";
    };
  }
)
