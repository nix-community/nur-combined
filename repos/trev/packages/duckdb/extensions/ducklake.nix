{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "ac7595b0a1305bea3d4cfaca763b0ce964c763a2";
  hash = "sha256-QtdhWneqq61dvX2KX68mHm/06YZ30xWITIq5fJqCaFc=";
  duckdbBuildInputs = [ croaring ];
}
