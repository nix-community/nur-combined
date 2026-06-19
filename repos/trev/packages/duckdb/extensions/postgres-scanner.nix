{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "0642861a90bc9dcfac12f8ad8dff8a1715883297";
  hash = "sha256-ZVCTfJOiN+NaIOZ8W36OddHnFGTlReZy/wzUKUGpR8c=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
