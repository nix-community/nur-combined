{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  rev = "417a9117f590e8141742ac0579d02f6a90162e37";
  hash = "sha256-CfGNeFJlTjLS5/2GEg4EU8Ph9I8mLPax96wCNOIrgZk=";
  duckdbBuildInputs = [ croaring ];
}
