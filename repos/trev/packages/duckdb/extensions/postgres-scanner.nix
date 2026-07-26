{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "7c570c46845da2c6bb751673961eba1ecddfc7c2";
  hash = "sha256-0zd/7+xmJeYzW9Y+Uq+74ItdIVREiZrmGYpx9nJqCMw=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
