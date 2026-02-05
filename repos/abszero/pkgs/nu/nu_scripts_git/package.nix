{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-05";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "00f8a98b7aee45ed8cefdfc497058cbee315a4c9";
      hash = "sha256-O5M1fmQBuFXGBMvhJtRJkZWDGyhV9VbL3tvqbKor2Uo=";
    };
  }
)
