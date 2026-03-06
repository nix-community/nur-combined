{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-03-06";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "4b616e8afe503a709d1c245e4c9cdcd24839f156";
      hash = "sha256-CqZYxn/h6Z4hj/xoXqFNDRfzG1wlMWPzJEGV/IyRD1M=";
    };
  }
)
