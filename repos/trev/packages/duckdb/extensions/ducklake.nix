{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "c23aca43b6033acfac2b8cc8d80b15ae7fa729b2";
  hash = "sha256-JiO9aR8AtGxDKBpnVgtdbzxzNUY2E9z65jXIXcyLw0A=";
}
