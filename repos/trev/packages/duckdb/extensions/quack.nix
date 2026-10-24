{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "quack";
  repo = "duckdb-quack";
  rev = "f96420ed46aee9c42064bdb99ddfd1230d6c0086";
  hash = "sha256-S3/yaeTiJoA3efiMPksLVGlfKm3JH7I3tzuub9v3IQg=";
  dependencies = [ "httpfs" ];
}
