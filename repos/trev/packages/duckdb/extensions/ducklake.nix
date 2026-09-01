{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "47c21b5f03a9ea24eaf5365a6a418aa281295573";
  hash = "sha256-pQMm5QW2ii6pzP53YJsNLUvBqctLDcDSdEdAbndvh4w=";
  duckdbBuildInputs = [ croaring ];
}
