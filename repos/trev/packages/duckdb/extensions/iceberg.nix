{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  rev = "22990d741ec19f9f3c5370b1ee570d78b0aec1d7";
  hash = "sha256-t7qrTAkoVjM9chclFZXznYsbjnzKqU15FqpOavDyZ/Q=";
}
