{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-09-27";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "32be8aa912f78fbb0abd5ce87fa8555161931b99";
      hash = "sha256-hkx6hi5CB8Wp0YWeZD7v8tuANVQzmaTcD5kCOcFLT3E=";
    };
  }
)
