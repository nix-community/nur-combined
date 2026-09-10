{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "5274128259f73166c1f37f01190a4601f84c5525";
  hash = "sha256-1HicYGYwf1g7CCOITP0B4dl/whnKMEswOvQZp1TbG8g=";
  fetchSubmodules = true;
}
