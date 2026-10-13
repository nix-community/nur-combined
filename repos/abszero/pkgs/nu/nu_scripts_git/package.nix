{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-13";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "3157208885c6f4c39ec016265ddae00160ae860b";
      hash = "sha256-FpRpjPoWvXA0xeqKiCpM6SPDSzGE3JbYDZ1DFc2IDEE=";
    };
  }
)
