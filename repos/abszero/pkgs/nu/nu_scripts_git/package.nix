{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2025-12-28";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "1cb6d6c460949b989b7fb1a6d02456a560521366";
      hash = "sha256-Cq814VegRIWRR0UfRz3xV3pHm4C1701I5BoPRsEi+ZQ=";
    };
  }
)
