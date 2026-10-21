{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-21";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "9e8552cc3a0134d4fac25223aace2cf6f70d10e6";
      hash = "sha256-y116DAzooLZPCh6UhyZBtRO9LPfHfHHfOYsSzftusk0=";
    };
  }
)
