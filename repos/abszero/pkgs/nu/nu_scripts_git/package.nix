{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-06-27";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "788e144a109c5f47e3a24c75448b775c7f088368";
      hash = "sha256-J9xQFJWmKOl7BQXHeEmboknv6JnSimwMh+Jf0kmUZo0=";
    };
  }
)
