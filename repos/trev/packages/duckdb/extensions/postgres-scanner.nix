{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "1ddd672176c01b58cbebca310155153ec306e87c";
  hash = "sha256-G9iBDPetOwF13fLn4n6dYgxLNCK8oeyG1B3Iref6lBc=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
