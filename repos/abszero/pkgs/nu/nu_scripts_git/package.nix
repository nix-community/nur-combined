{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-20";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "8514f5e6a829854d622fbbd5929597b920c2ada4";
      hash = "sha256-iJJw6XVrYOJQMET7/Yr/Q2q8J6re+n9MrTflhzqh8Zg=";
    };
  }
)
