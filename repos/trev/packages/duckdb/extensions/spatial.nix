{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "spatial";
  repo = "duckdb-spatial";
  rev = "6019a321b4e9a91cb0e81e29d8458d41c75ec3ba";
  hash = "sha256-A0/BeYd7t9NxVlCcxccqFuOYoMdo+P4+Hoa2cJ/vuFE=";
  loadOptions = [
    "DONT_LINK"
    "INCLUDE_DIR src/spatial"
  ];
}
