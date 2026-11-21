{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-11-21";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "9bd0c65b9eee45ee748bfba00b2ac50c2fb62c10";
      hash = "sha256-fmqsDDtvHYPl72LA/pYJ9tWEUjQtHxA/U8m/OQnVhYQ=";
    };
  }
)
