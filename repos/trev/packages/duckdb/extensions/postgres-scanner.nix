{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "2bb26835ca0866921f5a72ea2fe1a96cb88af693";
  hash = "sha256-JkqpQ1s1D9gycF5c0J7JHvtLZnZ+NFzNpZczhIv3iO4=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
