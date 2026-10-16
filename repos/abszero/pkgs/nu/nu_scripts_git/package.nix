{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-16";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "232aef4f1f69921b7de6d092cf8014de28b1b198";
      hash = "sha256-CzheXDme0Qo/5zNyPBcmekXnq8y/z2W05yDXOqPFt+w=";
    };
  }
)
