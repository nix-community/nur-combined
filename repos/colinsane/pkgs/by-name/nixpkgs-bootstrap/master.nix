{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "651e727c688aa214b29ffeee9611b8efddb1e6bc";
  sha256 = "sha256-IO3FSgSLNtQOIhjL0FMgjrptT1m2Dy/RaO+0H66kO2k=";
  version = "0-unstable-2024-11-16";
  branch = "master";
}
