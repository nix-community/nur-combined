{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "f33cb972e3a4895c896b66f91c72d445599050d8";
  hash = "sha256-EgOkDoJnOLw5GK2JqlmY/zXCK3C8VEAAM12CXx06zvQ=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
