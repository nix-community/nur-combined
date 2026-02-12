{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-12";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "cc94140f4942116e065a97d73c3ce430a092fef2";
      hash = "sha256-KRZtbZTzkQvizZSkorLnYpqI70lE8y4ERtbPQkb6ALo=";
    };
  }
)
