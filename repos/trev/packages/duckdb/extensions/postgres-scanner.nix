{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  rev = "c0f5a3c0c4b68b02afbf669d36d7f0e503985c88";
  hash = "sha256-redRKplI5rkMqb+oclVVJRofcWiS2cXH7qV5BCGkKEI=";
  fetchSubmodules = true;
  duckdbBuildInputs = [ libpq ];
}
