{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-08";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "66012624c7384b4319a33187455e91c545705909";
      hash = "sha256-o1hJP3mXuIQ4Zhn1Yyom1oOOjxpQocs7OaqcLF7Bhew=";
    };
  }
)
