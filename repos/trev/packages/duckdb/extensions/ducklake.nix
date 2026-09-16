{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "a7f80f5623fecdd7e39ad1a488036dd1cf5cb5d8";
  hash = "sha256-jD9AJvsjLVDfF4Vl3FQjC0huRU0pK9+ZKR1oqjZSHBk=";
  duckdbBuildInputs = [ croaring ];
}
