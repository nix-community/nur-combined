{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "5e0d69ad7a83d1a5afdfd9fc40d724b5f30b6b16";
  hash = "sha256-9OmRH/HimTzRdNP5n4pK8vZDwNukaih5mxbJpDSyZDI=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
