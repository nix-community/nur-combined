{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "b4c2d75c622d272bf235788ef77b4b83d3530fdb";
  sha256 = "sha256-M1Z1qxP4c5GrCJ5XZn/SHGgxucIntY1AMiN60G4GyiM=";
  version = "0-unstable-2024-11-16";
  branch = "staging-next";
}
