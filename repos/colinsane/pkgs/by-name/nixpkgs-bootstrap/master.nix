{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "767b0e3398fb899d0c88a9f7aecf30dd1cad3166";
  sha256 = "sha256-kIKqS3093Xz5vuvSLk0x1hqo2pFaGwMjnwr3qrTBkzk=";
  version = "0-unstable-2024-12-01";
  branch = "master";
}
