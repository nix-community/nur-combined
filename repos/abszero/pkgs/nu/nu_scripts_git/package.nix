{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-08";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "1b8c6ef9d286b559986ef4ea1dab3b921f24f924";
      hash = "sha256-cwAAtNW5fVEHZ/fHxiYeFVppCJnOEQClMAz2mZ6mpok=";
    };
  }
)
