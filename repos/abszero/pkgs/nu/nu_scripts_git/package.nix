{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-09-18";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "9d90767d41b715fce2c552c2f0a8f56525fb8353";
      hash = "sha256-JROzCAneBYpp4DEDKLeWBHbPt5P8XRdVSgtmfss966A=";
    };
  }
)
