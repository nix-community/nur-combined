{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-01-23";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "08ae664fce3dccda36bae74fc7e32e1dd6d8cf1f";
      hash = "sha256-zvUnrbfSDJ5cxVh0GWBEULk24+efC9QmhCSrp7GH7TQ=";
    };
  }
)
