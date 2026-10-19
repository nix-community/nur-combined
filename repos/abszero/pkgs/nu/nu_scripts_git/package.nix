{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-19";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "2b7fd0e37fbb10560b8e85c460148127c4c93dae";
      hash = "sha256-F2Oxy0tV47QjaCCSbWD/c1OTn/HAxcJ2iW/E6/rJxsA=";
    };
  }
)
