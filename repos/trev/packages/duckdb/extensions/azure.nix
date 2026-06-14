{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "azure";
  repo = "duckdb-azure";
  branch = "v1.5-variegata";
  rev = "563589b2f24290a4dcdd4247eaedf2b544f9dbcd";
  hash = "sha256-4gnj1OCdyhFosaCPVmiyFx9nSCSemNRxIC+nmVwtHjs=";
}
