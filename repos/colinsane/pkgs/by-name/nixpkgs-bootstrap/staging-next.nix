{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "f9ae478ae2298ad91b9ef4d9a5d0860b85cd6ae7";
  sha256 = "sha256-KBSk//slCmVJr8TKa5RcHin7b3l/LdLUp30iH+8K3kg=";
  version = "unstable-2026-07-28";
  branch = "staging-next";
}
