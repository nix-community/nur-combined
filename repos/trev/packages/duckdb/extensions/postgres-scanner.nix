{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "4053b617c863dfb435c9be9dacf1ec0e3dacde80";
  hash = "sha256-4l4e9sqmmMuNI0RLhXeskicJmz35PYIYt43olUQsr/s=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
