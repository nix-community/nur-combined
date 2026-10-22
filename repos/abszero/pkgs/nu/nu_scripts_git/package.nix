{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-22";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "0a85f069dabbf8792ff60eb98946669533055e46";
      hash = "sha256-DZRjNKgmkcjB3TYCAlPiA7UU91Z4z1QTCw7UA2d29K8=";
    };
  }
)
