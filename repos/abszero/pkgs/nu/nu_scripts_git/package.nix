{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-18";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "c5387bd60ca63d26885ee73ceb8a84160bc6ca6b";
      hash = "sha256-QPKgVj5tWwgwspCQYwjPBJZLTHm2e3AuneOK+hI6qUg=";
    };
  }
)
