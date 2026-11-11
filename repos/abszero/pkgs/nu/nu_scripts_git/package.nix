{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-11-10";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "d5bf09a509c3de1d28f6b51015eb4460435d658d";
      hash = "sha256-kCILVEQeALH/iB2Z6FNczeUrLbrOyXY5jvp2cN2r0Nw=";
    };
  }
)
