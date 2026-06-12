{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "fts";
  repo = "duckdb-fts";
  rev = "6814ec9a7d5fd63500176507262b0dbf7cea0095";
  hash = "sha256-Cm9RWizvxNwhMKyWWPrkr5SG9kU9NaUWTvWhlLbg1sg=";
  loadOptions = [ "DONT_LINK" ];
}
