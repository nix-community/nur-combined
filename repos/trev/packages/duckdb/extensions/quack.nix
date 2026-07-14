{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "quack";
  repo = "duckdb-quack";
  branch = "v1.5-variegata";
  rev = "d440703c807b0095d9d4dcbb29c06bb971af6aac";
  hash = "sha256-/yyl9yn61rTP7acJEBQdZl1tdBhxGyaU+Cp4MzyVoE8=";
}
