{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  rev = "4008894c57168e0e9dff00e87cd725c5168fd81e";
  hash = "sha256-wjdQa/SnU2fkSlPKSPygx9EnH0pBolMDAEcw8x5oB5A=";
}
