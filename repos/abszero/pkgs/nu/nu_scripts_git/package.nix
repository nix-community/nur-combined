{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-11-19";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "da6d0414663c0e4b3dd29e87346c01bb8f7aef07";
      hash = "sha256-0PStN0Jc5kTlYQZAnuf81mG3nr8OJWnfGdo0UB5W6OY=";
    };
  }
)
