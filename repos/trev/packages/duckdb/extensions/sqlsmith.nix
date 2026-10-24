{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlsmith";
  repo = "duckdb-sqlsmith";
  rev = "00c4e5796c4e3e1f98ff4adec55d87326d2d2f3c";
  hash = "sha256-Mqxz2P8C8lhS6mVMM9slnnTaF6hRoqjczJH9SjyK83c=";
}
