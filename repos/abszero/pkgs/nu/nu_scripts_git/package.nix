{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-21";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "e055e4c5a371e74574365b94b438f51c44afac98";
      hash = "sha256-15USnd5E1ugI+EyFQvU2G2K2Jlk3fBtj4qwhBTUiIsg=";
    };
  }
)
