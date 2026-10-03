{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "7dceb64d9d5e011d0b46b9871fadf95af6b2121a";
  sha256 = "sha256-tXb8SM1/4Cqi7jsV6UqD4cvbOOUwffsubxSkN+0uR78=";
  version = "unstable-2026-10-03";
  branch = "staging-next";
}
