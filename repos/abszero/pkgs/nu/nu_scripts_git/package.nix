{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-06";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "16e4eaa7354ef53f19c938b7d10f5ead8864ced0";
      hash = "sha256-x8XuBM3Zyorf0Fvnnaln5N0VPFlnHGMOdckNAE3cCJQ=";
    };
  }
)
