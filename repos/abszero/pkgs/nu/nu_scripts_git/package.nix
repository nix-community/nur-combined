{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-26";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "9f23aeb2508f9b6b449949790393e361de306e1b";
      hash = "sha256-IvPFUrWNf324E737tbebNRAJL/7+91tJQKZr8UEeeXk=";
    };
  }
)
