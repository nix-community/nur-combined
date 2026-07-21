{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "quack";
  repo = "duckdb-quack";
  branch = "v1.5-variegata";
  rev = "7e80f7ffcc98d0b3e81d0e1df8cc1c2da240a64b";
  hash = "sha256-fLswkJMvfhv8yAsWIiZvG6Lg5Svy8d8d8+WmPiWt4AI=";
}
