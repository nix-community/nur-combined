{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "b8242c80af59857b95760c4d6ec2452b469ea4a9";
  hash = "sha256-cRQ5f+laxE7m1eX2VtBaIe2EtxMF4o3ks4t0aBS4/IE=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
