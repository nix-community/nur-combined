{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "vss";
  repo = "duckdb-vss";
  branch = "v1.5-variegata";
  rev = "1ef3ea6acbc22869c679d35ab430e92eb7248f39";
  hash = "sha256-8KjUqpFdcq2m/DmTybxKL/auB0lKIeGjgwD4UgAItj0=";
  loadOptions = [ "DONT_LINK" ];
}
