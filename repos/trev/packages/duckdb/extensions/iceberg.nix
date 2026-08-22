{
  aws-sdk-cpp,
  callPackage,
  croaring,
  curl,
  zlib,
}:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  branch = "v1.5-variegata";
  rev = "6561bfcac03e13a8162e44f55b31eca036d19db1";
  hash = "sha256-ICYE6mgXSUzDCZpDbycpRUBnFxUxMtgCKhje5uD0FxE=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
