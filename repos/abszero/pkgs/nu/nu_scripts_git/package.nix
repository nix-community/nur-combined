{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-01-23";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "e65d76cd14979937ee378d56fc21f4e72f21cecc";
      hash = "sha256-LPwe0DS7rNFY6MUcfCCqMYJjPkhHQyBmy4M+KjrNz34=";
    };
  }
)
