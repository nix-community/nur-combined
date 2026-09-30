{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "62133d5cc10c8a942c08911da1c2baed665c9d8f";
  sha256 = "sha256-61yYjMOWKFM0nsUrJLgy91P/bkulLpOWpR1KeFrVh6g=";
  version = "unstable-2026-09-28";
  branch = "staging";
}
