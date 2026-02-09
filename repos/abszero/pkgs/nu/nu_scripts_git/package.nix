{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-09";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "e95f3580453fb03f2fabb5e8d64aa240cab103bb";
      hash = "sha256-+8M+pLnOyHphqtzU1E9wFihmakRIyv1aEspessRobec=";
    };
  }
)
