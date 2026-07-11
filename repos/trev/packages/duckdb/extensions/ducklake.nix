{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "84ef2d14a0161f6f6197d6c8d2b4dbc45bf40375";
  hash = "sha256-1gMiM5tQ/QDmR+UH2RlN3omYBtqMdCBAirqHihjeS50=";
  duckdbBuildInputs = [ croaring ];
}
