{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-10-31";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "1e6533e8c316386f9576d7220a72ab05ce48c52a";
      hash = "sha256-CMwtlPDqYsdPgtbZlTqdrBZpnxKVGwhJ0ejGH4L0fNo=";
    };
  }
)
