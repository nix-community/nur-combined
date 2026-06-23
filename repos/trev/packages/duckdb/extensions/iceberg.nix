{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  branch = "v1.5-variegata";
  rev = "fa4d3d521cb05b42abbc33bd63a8efa5e736c5d8";
  hash = "sha256-J+yRPar9u59QsvOTpHzrr6Mju7vZqCuxkMPLq2VaFTk=";
}
