{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-07-19";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "381eb7577705b00bea437da7c0439c39ff05f06b";
      hash = "sha256-b4/JOcpUa2BittwZz/w3IPUik4QPlpqcgc2dgDDbb1E=";
    };
  }
)
