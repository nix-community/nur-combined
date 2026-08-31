{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "fbc433f664e0f1442126e0241ec27039420f0ff2";
  hash = "sha256-bOLGqCr+UbW5uO9lDdhbfjzc8Slk/x1JyUpdNZad6KM=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
