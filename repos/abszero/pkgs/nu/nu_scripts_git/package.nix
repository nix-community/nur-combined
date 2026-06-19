{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-06-19";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "6e38e891d85876a180882ce44533182105e3ba1a";
      hash = "sha256-LvlMu54RPvez7WyQ4RDfUUfRMGeY3EwLQbH2Y3e856A=";
    };
  }
)
