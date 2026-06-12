{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "spatial";
  repo = "duckdb-spatial";
  rev = "b68b309d371dba936c5bb362980e559b7756b16d";
  hash = "sha256-cSsdHVM1yDSCZuwXKv9N/P1PFI8vY+7EtHNosIP5PGg=";
  loadOptions = [
    "DONT_LINK"
    "INCLUDE_DIR src/spatial"
  ];
}
