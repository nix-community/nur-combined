{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "quack";
  repo = "duckdb-quack";
  rev = "1693647c152b438aa2a6a9ad71764f99c5a561e0";
  hash = "sha256-SKx2nDHgW8o7V0TudPFwAH6fD87/iGTPAUtsGVzvOeA=";
}
