{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "60542de2c433199869aaff95a41570849a56fa33";
  sha256 = "sha256-ZEgeHls2/vTTN40MYj56DXpx/+6xB6K+jUGWFTUFAtw=";
  version = "unstable-2026-08-18";
  branch = "staging-next";
}
