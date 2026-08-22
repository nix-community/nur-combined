{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "f6bfba2d0db2ef0f1e9c6206d370f48a6df9573a";
  hash = "sha256-IkD3NAuqSRY3hI7vZmcj43pcwbkRDaBIHjgjfTqzUuU=";
}
