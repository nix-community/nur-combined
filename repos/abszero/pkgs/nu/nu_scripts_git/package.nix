{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-27";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "5d5c923104765035f584ae3734e2bef51733264c";
      hash = "sha256-UalqOSSAZwfT4aNmXaTJ7PNaelOmebFUoVJVgwqAgy0=";
    };
  }
)
