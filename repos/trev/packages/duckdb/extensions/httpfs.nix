{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "httpfs";
  repo = "duckdb-httpfs";
  branch = "main";
  rev = "8b7226c2a0d35ba4055d1839e881a19b9a8b73e3";
  hash = "sha256-GHAZw51q78AzNy1AWGOgWL+kNEk/GLcLcankYaA9Vys=";
}
