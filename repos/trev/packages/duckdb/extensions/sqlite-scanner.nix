{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  rev = "e223dc01493414cef6d5960744f1e048d59fc592";
  hash = "sha256-fVZP6vctnSoT+6mHAVMfWjOoYrEvh0/RalFWpuEdC1o=";
  fetchSubmodules = true;
}
