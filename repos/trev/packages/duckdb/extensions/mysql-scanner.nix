{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "mysql_scanner";
  repo = "duckdb-mysql";
  branch = "v1.5-variegata";
  rev = "2a59de314c07bece84ae0be4286c9b8964419b95";
  hash = "sha256-QJeE74I7v448NPMm9wK+uj/mjxbTkQR50Dpgy13gNfU=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
}
