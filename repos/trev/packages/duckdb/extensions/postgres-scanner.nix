{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "ab217c6b0c1d8b8783af1b72af48009e902c2718";
  hash = "sha256-cdet+FuYMCiVeyzMniN7IbUR9m3gvcphEkDE5OC/P5U=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
