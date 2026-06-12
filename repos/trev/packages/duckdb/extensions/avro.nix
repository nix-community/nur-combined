{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "avro";
  repo = "duckdb-avro";
  rev = "7f423d69709045e38f8431b3470e0395fce1a595";
  hash = "sha256-jB/eZjtEHhFmuonU9fDYNBiPFoxzpgOaqzQNV36a6GQ=";
}
