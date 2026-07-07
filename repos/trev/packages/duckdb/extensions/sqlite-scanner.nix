{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "7fd725f82a5d88d9a1d350c1371de420f8843526";
  hash = "sha256-ocOI5DJmqgUpSRU6jQ/aTs6/TrmNGUVFtkJ5McDa8Gs=";
}
