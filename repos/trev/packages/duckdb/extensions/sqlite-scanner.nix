{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "ce61f45618e3f922196b83206d71d6c4e1e4ec00";
  hash = "sha256-RVxcRSKHYevUeWW+FXlERtRAxt6DZytqMopE7jxpqEA=";
}
