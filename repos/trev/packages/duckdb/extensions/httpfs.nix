{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "httpfs";
  repo = "duckdb-httpfs";
  branch = "main";
  rev = "2a6481d0bfc2cbf1a1f15d8076fe09b9d326d8d4";
  hash = "sha256-nhSjs2oYq84Nj1iZ1sLQJTnACpOHEnHqB1XJekPX4pE=";
}
