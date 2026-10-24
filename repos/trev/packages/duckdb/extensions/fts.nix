{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "fts";
  repo = "duckdb-fts";
  rev = "2266e67d01c737cb65114e77c7c672e58869a635";
  hash = "sha256-Y8MPRvD5XFsLpPEsVzALq3jQk9vqEidGBcvPDHdjkMc=";
  loadOptions = [
    "SOURCE_DIR \${PROJECT_SOURCE_DIR}/extension_external/fts"
    "INCLUDE_DIR \${PROJECT_SOURCE_DIR}/extension_external/fts/extension/fts/include"
  ];
}
