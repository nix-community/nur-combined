{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "vss";
  repo = "duckdb-vss";
  rev = "3685131eacaf0d467d430be5c4e5e7d1d483437a";
  hash = "sha256-aNf65cZSR3S1JU5SNOSKuvlx436G81lSLRvzyCbWtkk=";
}
