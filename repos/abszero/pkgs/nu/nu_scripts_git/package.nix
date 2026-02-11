{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-10";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "5b96d5331f95526eadbbf89e8372b1e3ff93722d";
      hash = "sha256-yAFy/OzorK0wkZ8Lq/4moHdyAnPrTNxzz8hw4YPMWgU=";
    };
  }
)
