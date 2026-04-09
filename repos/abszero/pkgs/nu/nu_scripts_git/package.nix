{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-09";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "fbab343ee1ab38fbfd5ec5842a0f2a7d5639abae";
      hash = "sha256-wg/+8hm3bAoxVM6ZSUhSIjzK6fKkouCtyZjZQIttDY0=";
    };
  }
)
