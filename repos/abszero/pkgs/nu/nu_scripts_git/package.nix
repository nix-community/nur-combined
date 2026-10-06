{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-05";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "4033ddf35966612e8dc1f28980170f5f54709f74";
      hash = "sha256-P9qxCykVBOmHAB4D16ArNBmDJpEcJa3/sIEv2y6V7ow=";
    };
  }
)
