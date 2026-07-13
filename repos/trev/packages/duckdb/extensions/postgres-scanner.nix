{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "9add648ccbc73f38c50dec91678050b3134d1244";
  hash = "sha256-2QNuQ82uTB23yiWldjATnyxJX/ueDFraZ3eVhDnMOKM=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
