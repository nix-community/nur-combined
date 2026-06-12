{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "aws";
  repo = "duckdb-aws";
  rev = "38d4ed30b7f5855168f4b494bf9be611c868c69a";
  hash = "sha256-48LuIbzjPE5bG7RTvVYpoonUg0JS8MGyfxh0R/b1NNQ=";
}
