{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-24";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "02cb1a2bfb8f7b6977af6914dbe44f450d6f9df2";
      hash = "sha256-Lx44zQPldtkF3haks6E5DtZIBKLveafgE4HtwbX2yt4=";
    };
  }
)
