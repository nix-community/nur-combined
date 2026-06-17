{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  branch = "v1.5-variegata";
  rev = "bf16d5b7ef009ff2b5e2aae6c09cd4ba3ca5c0be";
  hash = "sha256-jOCZG6SQswpBjurFL97/0FviSldMd+vArhCxURIt7iE=";
}
