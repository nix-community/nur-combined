{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-02";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "3ffc5aa43194bb4d5295dec9fbf0a18b3a2dddfc";
      hash = "sha256-/6nbTNfpkNRUJcXnQKw9yrm3UAvgfUoyKbNRUkQAfPY=";
    };
  }
)
