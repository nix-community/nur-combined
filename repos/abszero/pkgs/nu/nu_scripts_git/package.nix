{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-06-21";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "693cb5b2ba69ecd4c3cfa6f645aafbcf906334ff";
      hash = "sha256-9CmOezg2z19lh/MgAMvLuItjStBDoi6rea4gkV7MeYA=";
    };
  }
)
