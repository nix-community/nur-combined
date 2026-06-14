{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "quack";
  repo = "duckdb-quack";
  branch = "v1.5-variegata";
  rev = "40de7badae4193c29d9c0834473fb76acc6c51e6";
  hash = "sha256-E33EiV/SYD6l1kHiCNgkt/d15FT8hNM53pNPQgsMEqA=";
}
