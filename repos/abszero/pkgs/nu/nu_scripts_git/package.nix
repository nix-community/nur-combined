{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-03-09";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "33ea2a5271a3b9d5f2722ebeebc26e4159068a76";
      hash = "sha256-JDepNHHj0aKnLPBDuLNjvNLKsTcp84WeYqoASTl1Gvs=";
    };
  }
)
