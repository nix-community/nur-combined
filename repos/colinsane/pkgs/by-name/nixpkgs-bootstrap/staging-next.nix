{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "41845d16d3aa27afe3e0e73b395179ed22749d3d";
  sha256 = "sha256-wA+2DufkEtcsPyCbi51u6hQraYWr8v4W4W46u993gwk=";
  version = "0-unstable-2024-11-23";
  branch = "staging-next";
}
