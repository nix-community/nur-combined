{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-05-23";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "57f49add9b32d4741351b63236f28341eba35077";
      hash = "sha256-l0feMriwY8/WAghUOwSsD0MDUVGXgOkzUklnnvS1ij8=";
    };
  }
)
