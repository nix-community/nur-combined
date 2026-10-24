{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "inet";
  repo = "duckdb-inet";
  rev = "fe7f60bb60245197680fb07ecd1629a1dc3d91c8";
  hash = "sha256-k4SZ9vuPGAGapzPXCywUkVGhfV1MuCgtA2DY4MhS+Z4=";
  fetchSubmodules = true;
}
