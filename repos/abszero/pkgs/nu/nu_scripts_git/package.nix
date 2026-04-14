{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-14";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "31e67054f4e8a7cd68b6c5484bae0e6dca26e9ac";
      hash = "sha256-uUji7eQB9/nIVg26wVCqvX5IBij8ybVrfBYnLzOeb50=";
    };
  }
)
