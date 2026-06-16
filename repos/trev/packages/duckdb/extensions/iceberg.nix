{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  branch = "v1.5-variegata";
  rev = "ff3b2e8119793abc8cbecfa7e15e712f7bdfe940";
  hash = "sha256-YgF4wVoyP7A8fuw24pgSTYmUpWs952n3kiOP6XtsXCs=";
}
