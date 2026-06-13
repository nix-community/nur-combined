{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  rev = "2fc791837413a57198c47f18c73fdf8997af2b4b";
  hash = "sha256-kUi0Kp4xUkWFyo2RuKYmRx0Bx6xVqb42HwnXye/xmLc=";
}
