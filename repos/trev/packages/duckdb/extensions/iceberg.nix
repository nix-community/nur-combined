{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  branch = "v1.5-variegata";
  rev = "826320929a22e70a3735d674beeb0a0b2363614a";
  hash = "sha256-dN4uWkrzFrYQEnZYe0cWTQCcrI+DF7tIAcXO3UehSZM=";
}
