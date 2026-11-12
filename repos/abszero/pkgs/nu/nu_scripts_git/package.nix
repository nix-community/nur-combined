{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-11-12";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "f9fb123aa541250e5bbfa85ed055293b39751195";
      hash = "sha256-Yk+wgPiZXLHrCUhrbZiCQbATwdniTr9BMZpe+dXz1Fg=";
    };
  }
)
