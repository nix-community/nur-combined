{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "quack";
  repo = "duckdb-quack";
  branch = "v1.5-variegata";
  rev = "c1548111c1bfd16207e22fd3cb7e4bde1335b9d0";
  hash = "sha256-B94mtDHNemCmPQfZIceIaFYeMy4rjwrV6OzRxK83DkQ=";
}
