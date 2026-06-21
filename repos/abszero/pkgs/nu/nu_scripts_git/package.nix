{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-06-21";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "800e6223ab0f91bf1097c4be2b9a3647b9d666e3";
      hash = "sha256-OfcKKaoVOdI7y+LZp3MajAPWF0QyuBllwJkCCTe1Y1Q=";
    };
  }
)
