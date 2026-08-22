{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "0027dfc8a6c66bd1bfc30d8832c7075b801eae45";
  hash = "sha256-Q5FWuc7U8XGfGanSTORxswbmC3U+mnn6/bx2u/VKOiA=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
