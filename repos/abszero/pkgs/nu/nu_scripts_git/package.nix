{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-11-11";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "19c49e09e1970a11db235fd38477dd5fa44e56bc";
      hash = "sha256-+mTo7YXCtQEvEEdrxE3ntvB34PEt1m5tjFhI2jFXYBU=";
    };
  }
)
