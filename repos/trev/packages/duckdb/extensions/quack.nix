{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "quack";
  repo = "duckdb-quack";
  branch = "v1.5-variegata";
  rev = "8e715ebb6d0fd6f36b1c705e431f5e3f33c45ef3";
  hash = "sha256-fNwEa+TVrm6Nbm8pM4lhv0LHNntBtuX9aTys6btz/aM=";
}
