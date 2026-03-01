{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-03-01";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "25d3c5b200202243f03e6e25bda707f073ba22ab";
      hash = "sha256-SCixlF+oNb3HuzWsnRNwJygvxlGM2pE6LdhWePvAauw=";
    };
  }
)
