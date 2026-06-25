{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  branch = "v1.5-variegata";
  rev = "066c308642590ea69304356832cf8b44853120cc";
  hash = "sha256-RyP20QqrcUsq/IjlqXfwbCGeck7ZR6yP/k3RZUz/JlM=";
}
