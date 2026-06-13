{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "aws";
  repo = "duckdb-aws";
  rev = "0fca260b1dd2864a942c83635048cfae8f23c8aa";
  hash = "sha256-ut7+a6PiR5LWyrITEJaC8MLDrtdqtWyjOaP1hqerllA=";
}
