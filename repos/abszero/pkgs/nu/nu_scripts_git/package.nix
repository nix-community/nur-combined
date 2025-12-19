{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2025-12-17";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "4af008a317185b4e247bdb13002dbc074e98b60c";
      hash = "sha256-KsS3Brtt9tXKpogXdGQJK6QfJq3tbGnyU/ydVaYggE4=";
    };
  }
)
