{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  rev = "a087a5878900d8bae155e97fd1b18c4cec0cca21";
  hash = "sha256-1PYhePttl77xbYer8pdIn0dOd+s4Efzh+2UM94Jifmg=";
}
