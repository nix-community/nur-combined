{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "542514e1108e925ac25fd6b20f65584aba7ce5ec";
  hash = "sha256-XeaU0SD+lafY3ide5AH6BBJaHA8lCwDMOZQTT1BTmzU=";
  duckdbBuildInputs = [ croaring ];
}
