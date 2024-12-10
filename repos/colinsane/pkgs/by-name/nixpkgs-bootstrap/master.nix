{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "5ed5910063937562d7add4e47d8e4b0140e5dbde";
  sha256 = "sha256-bps411iIu+xlyVKnT/oE7Dgy0btV7jjqWTKVocamu90=";
  version = "0-unstable-2024-12-09";
  branch = "master";
}
