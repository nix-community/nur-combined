{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-03-12";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "196d94338d382561e7bacb29948ffcfa5ff1b2a1";
      hash = "sha256-5FKqphXxVSgqGXbqOL3aiZEGFSr5SMjMVIWzB0dA/+I=";
    };
  }
)
