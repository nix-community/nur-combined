{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "5d215e93d4d95df409d89e85e19b9fa9993b0611";
  hash = "sha256-ACkcASReMxuD9RV7ge/YFg8TFYw7qd1wJ84DFf75hrM=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
