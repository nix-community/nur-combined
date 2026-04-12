{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-11";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "341154f469b0fbb5bc5b69e591ba97ebf0e58fdb";
      hash = "sha256-94u6d6WyyyamUn4a4p8O9Ujl9R56p1JxthuS03B4auw=";
    };
  }
)
