{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "e68fd26555218bcca974054fbfccb407632435b1";
  sha256 = "sha256-QvYFqTTiFzntx8jEVDrKB/OkoygutLRlPhNQEJY9oE4=";
  version = "0-unstable-2024-11-19";
  branch = "staging-next";
}
