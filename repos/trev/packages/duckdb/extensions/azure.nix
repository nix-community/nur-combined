{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "azure";
  repo = "duckdb-azure";
  rev = "a0e1ff30a074e2d8c17d7c861d4df07461029b27";
  hash = "sha256-+Zsi2yiAcAvXrkyjDlcCWmzqCBlt+AO4StWjSUiRbyk=";
}
