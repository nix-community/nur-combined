{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "318dabb2474fc3789b0199301a2e661e19c1b4fc";
  hash = "sha256-Sn3xXJH2EHc6ecdKcw15/MMi8xnMPhJRZ8Cg+zlvV5o=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
