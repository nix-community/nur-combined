{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "c5b4835e1e9c25c96c72306df069d3e8f4474389";
  hash = "sha256-1Shz6a50zRnwAnvEqTLfcHkhQ66W7vCxfSBC3YvIvls=";
}
