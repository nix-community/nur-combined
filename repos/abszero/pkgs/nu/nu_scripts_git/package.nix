{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-07-14";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "829c2d8e34ce17f2654ca9dbb9e84c2ba0ddf189";
      hash = "sha256-GHTtPrfurUwViRjW2mUP4gwDFKEJm52XJG78dVPCthU=";
    };
  }
)
