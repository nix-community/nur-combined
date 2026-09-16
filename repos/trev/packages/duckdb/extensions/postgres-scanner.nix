{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "786f9c06d0a036a8151c1c2b56b600662aa55637";
  hash = "sha256-45ZCJ2kMHIapAmhZmx5AwarF8L7MqnxfnBDnQ7PldyM=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
