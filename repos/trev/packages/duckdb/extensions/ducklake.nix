{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "5ef9e03d58286cf4bc532c62a69ae3c51fbb8f51";
  hash = "sha256-joz88S5KZvPp7E9EpE37cZTnj3F0enZsZb06iGygrHE=";
  duckdbBuildInputs = [ croaring ];
}
