{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "8f813f9b9c9e52a9074a050a0be60f49160a6baa";
  hash = "sha256-BICWevTyfE0N6vBirGIwa6EgPnyDkKHnMD+igv4XzZ0=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
