{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "f77b0cb511748fd70fb8a4eb265e2990599d286c";
  hash = "sha256-dSTqfb8LEQu1k8Z9qty/wrC3pgiMDl+aMkirK590Fjk=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
}
