{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-07-02";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "4af42d7f10993ee488ae37762a0e7034b9a004f6";
      hash = "sha256-Q+RxZ7j1odpxbZXdex2gfJ7uUqmIpNk1W/Cq39K1g0s=";
    };
  }
)
