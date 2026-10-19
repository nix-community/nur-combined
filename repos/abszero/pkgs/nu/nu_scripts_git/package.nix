{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-18";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "f4d6874a5508d4857ccbb6c33a2ff10819ddbb1d";
      hash = "sha256-aZGpkNP/2bNJ/EtY/kpXUQwy85rgFnGjb5x92LSsCmU=";
    };
  }
)
