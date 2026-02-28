{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-28";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "a524b016d1314b5083ff8e7fe365cfd0884bdda9";
      hash = "sha256-4SowPytzUdH8fAwnwI5KoT++VyvyGqOahDc3Tdw4m6E=";
    };
  }
)
