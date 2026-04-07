{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-07";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "021f50daf57b2e04d7c1ac8e9f781920a24ec951";
      hash = "sha256-htzhyrIQ0ySpRFKetAGZvKRDzRmFNnw9nkefHPJYQaA=";
    };
  }
)
