{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "httpfs";
  repo = "duckdb-httpfs";
  branch = "main";
  rev = "23f7709c3c5054afbb5c84bed696d69a44a70769";
  hash = "sha256-JT6ouLTlC/wsAlJCUjcFdhlBt2F3UbQwAXlqYJT4zV8=";
}
