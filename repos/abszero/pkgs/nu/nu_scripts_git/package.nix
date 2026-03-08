{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-03-07";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "c2e4b1763c7e6ea14e874b30cc14d085f901146a";
      hash = "sha256-MO/IY14kfDavR6mg1iaaXhkduDSESnqGjc56KXvW6Q0=";
    };
  }
)
