{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "0c53c28445084f0109b6f25027d07303b6b07230";
  sha256 = "sha256-z5awMRylXiiyHj3DlF5/69rkWAeWfkI0b85+SFCOIVU=";
  version = "0-unstable-2025-01-25";
  branch = "staging-next";
}
