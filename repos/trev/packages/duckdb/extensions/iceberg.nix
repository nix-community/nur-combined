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
  rev = "8181c63ea8cbce5ae3534d02a3f3894713bda444";
  hash = "sha256-06fV684XBZliQfqeIW/4nhfqYvPgWbNdV2L7JqNAV9c=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
