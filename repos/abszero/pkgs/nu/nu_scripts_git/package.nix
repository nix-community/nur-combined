{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-14";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "68af8db2fc540343affe089008c8292f767ca16e";
      hash = "sha256-O4p2cYr8MSgYLiYstPN1rPT+nCCjReCDfdEi0tuOjyU=";
    };
  }
)
