{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e4dc3dbba6995b0b4402cfce2065d6c92f31f81e";
  sha256 = "sha256-bKDgdhoTyB+/ZEqvViiM4hi62PzdmCVJImIeexyZvho=";
  version = "unstable-2026-08-01";
  branch = "staging";
}
