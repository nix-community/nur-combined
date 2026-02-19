{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-19";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "492cad098a44ebe4cabc28c131729932075cb6dc";
      hash = "sha256-5ARyJxBrQsNyosiNcG5RAYAbgHNxZNmJqlS181K8DmE=";
    };
  }
)
