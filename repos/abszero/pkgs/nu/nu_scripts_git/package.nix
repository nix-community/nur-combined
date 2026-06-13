{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-06-13";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "afb08cd49b1454cf8de6293dcfa7eca644ac6462";
      hash = "sha256-0D7LnwLOvrn00I8HW0PmBnCf95jMTo1TMEoEsR0g7Hs=";
    };
  }
)
