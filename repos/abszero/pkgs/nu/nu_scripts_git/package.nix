{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-01-29";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "efe6b1dd683a0398073fb595104854a690c2e36c";
      hash = "sha256-NSt0mHrQjqZoC8oc3eWqYcLc2SG152O1sRS9fifyk5M=";
    };
  }
)
