{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-04-27";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "2a5e510ffd945c4e7244806d471664ab3acea11c";
      hash = "sha256-ZoJweCXqXaGQr6QjWdqCHmdcAKkAWvhPE45d+EgjbtU=";
    };
  }
)
