{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "mysql_scanner";
  repo = "duckdb-mysql";
  branch = "v1.5-variegata";
  rev = "37006e53a58ddc31eeb96ff95c21f3196e27fcf2";
  hash = "sha256-tJhJE8nDlQUJO9vfwZo5mx8hIRgO4idJH6ftldKcFUQ=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
}
