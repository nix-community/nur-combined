{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "3771b3f3beae6ab492752cc863a4c59c1c9a1f05";
  hash = "sha256-SfFV/VYCSaBpkSCBkeGJdeT03X5DtsCteVEtIkzoNO4=";
  fetchSubmodules = true;
}
