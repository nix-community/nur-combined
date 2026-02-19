{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-18";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "f704022b7fa32b1bd2bc649c2f5bf185209fff1d";
      hash = "sha256-Nd/dYxKqD5pNJJWJaYqaXSGdBKBZE4jDiCXdOXSdLWw=";
    };
  }
)
