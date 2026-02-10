{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-02-09";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "f074325660667432a097ace094cb36be192015bc";
      hash = "sha256-qVAzZHlm1Z2QIYbosYtXV75rVOKBnI0J5xkf8SrDb1U=";
    };
  }
)
