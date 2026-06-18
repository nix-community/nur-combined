{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "d318a545571d7d46eb751fa2aa5f6f4389285d3c";
  hash = "sha256-qq+U3+X2cGtw91/WnhJJG2WyWQflkJMuBvGjQ0si2DY=";
  duckdbBuildInputs = [ croaring ];
}
