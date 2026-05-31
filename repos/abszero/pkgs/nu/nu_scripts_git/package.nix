{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-31";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "3e869d0b5ad1fc76537226d0cc9cb1660f27bda6";
      hash = "sha256-C1/3ndIfVpxELsR2dojqwPylbOCdqYFh8+gIXSOrkvc=";
    };
  }
)
