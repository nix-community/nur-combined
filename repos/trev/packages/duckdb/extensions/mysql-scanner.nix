{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "mysql_scanner";
  repo = "duckdb-mysql";
  rev = "496ac9e3cb61bd8d6d1255f73cf69b958a311525";
  hash = "sha256-V3l+LE/dHpYljvCstf7dvrekWIqtN/w314qxjrLNnVw=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
}
