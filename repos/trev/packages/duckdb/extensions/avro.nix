{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "avro";
  repo = "duckdb-avro";
  branch = "v1.5-variegata";
  rev = "f9d590297485f0318f480372c70bdd852826e258";
  hash = "sha256-1JiLOHgnqd7Oao3S8W2/erlqi8fgvpbHXSURhigBQSM=";
}
