{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-06-03";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "ca79ff62bd3fe0d31cd50762dcb1c8a46883044e";
      hash = "sha256-pk29HELNbBfQZDoXeLotUUZlRbQx7k168Rcw1JUOnvU=";
    };
  }
)
