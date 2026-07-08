{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "d1dd4a371213d2db02dedcc21a73393ea4f00e5c";
  hash = "sha256-7ecIsX/1TTW0qPgeqmiX2bupyW38kejS8MXLLGH6lmA=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
