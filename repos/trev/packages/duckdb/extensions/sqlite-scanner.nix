{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "494e9feed54c20b6bbfb665baf26864bc7e3b517";
  hash = "sha256-KGN/HbL3S0W8885CEarSUcTA6haSCFq5ElWA9Fzxnlg=";
}
