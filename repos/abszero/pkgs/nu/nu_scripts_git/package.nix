{ nu_scripts, fetchFromGitHub }:
nu_scripts.overrideAttrs (
  final: prev: {
    version = "0-unstable-2026-01-29";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "049b00e54e0dc878bc9a37ee0e05c6ba18789c2f";
      hash = "sha256-zHLVDV7RsQMMgYP7ysWF83Q+7PoP4E+pOguzixWf9iA=";
    };
  }
)
