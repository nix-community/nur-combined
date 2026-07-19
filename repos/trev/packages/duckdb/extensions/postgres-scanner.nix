{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "41223e51559cd581f1c06e170b71c71df25bbaac";
  hash = "sha256-P9GlAkUmYN/UOQ/B1RW7Cr75kpiYfqF49WfPWgCPjOU=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
