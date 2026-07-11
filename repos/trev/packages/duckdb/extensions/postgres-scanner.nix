{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "ac4f6c6d800d354c94f4025bb707445ad0e8884b";
  hash = "sha256-JYylJJ7gd2d6yVa7LHOwiwmM2Y2V415PbJo7T0Ne2L8=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
