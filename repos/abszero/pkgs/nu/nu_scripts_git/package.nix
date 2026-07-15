{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-07-15";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "e0b8d1e0c167efa32e9f4c69761b67dc625cb529";
      hash = "sha256-hIjJLoeep28PxivoGl2f5jihb0ljrp6ObrWZ9oyeWi4=";
    };
  }
)
