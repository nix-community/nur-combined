{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-09-20";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "a571833566d71671151566e1a2cda4e6338f27bb";
      hash = "sha256-LKONPdLlXfDZ03tEHiJ7rH49vwPHaiFIE0Zvi3bh+UY=";
    };
  }
)
