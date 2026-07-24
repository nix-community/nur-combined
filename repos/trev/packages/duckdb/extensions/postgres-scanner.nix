{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "71b85668afdff00bd947fc21b0e6bde397690971";
  hash = "sha256-c0EIA5ZhQNvsVhVQBEdhueeTzS/oYtvuwrDe4R+F1Kg=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
