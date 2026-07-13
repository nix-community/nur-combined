{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "f79b1db7d7730b18d0f8400d3650ffa6b45168d8";
  hash = "sha256-zQSB/dreOArPrrXV8KP6i/nOlSguRyOGWORvwZ5BsfI=";
}
