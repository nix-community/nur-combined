{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-17";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "44f8f25bd56c01cc765495bc4b704e564e3bd6e3";
      hash = "sha256-h+wSZrt7Fur3lKX2yRuX9qQB41/pReY0SQxOx3FIT3c=";
    };
  }
)
