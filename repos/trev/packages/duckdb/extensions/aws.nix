{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "aws";
  repo = "duckdb-aws";
  rev = "f15081e8708b78715a11391f33aea0c28b8c8d1a";
  hash = "sha256-7dgOGmGHgQUcoewyEW7O9/5AvDvy3JORFevAVw8ddcQ=";
}
