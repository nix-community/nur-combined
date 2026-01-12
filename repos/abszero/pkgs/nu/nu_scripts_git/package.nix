{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-01-11";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "c0eef9bb94eaf9d69f1cc27e2e1964fdb66fb24a";
      hash = "sha256-KfnxoyLY8F0jx6h/SGQb5hkTBHgaa0fktE1qM4BKTBc=";
    };
  }
)
