{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "73396b5dc01dc8fc211b6c3efc11cb8d9d064d3a";
  hash = "sha256-qxBb7cE0qBeRS68xVknm0E0Sg07vSfMWodTBCk8KZZ8=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
