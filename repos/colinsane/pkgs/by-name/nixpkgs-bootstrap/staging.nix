{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "489d55c3870875c82e32aa12a0151528e7336fce";
  sha256 = "sha256-rnNFG0Pk5vN6rInXOpugZ2Ro4hoRCQn9VIA0LRMWPOM=";
  version = "unstable-2026-10-03";
  branch = "staging";
}
