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
  rev = "890b78a9cfae380396b435b033c27cdbdad04e42";
  hash = "sha256-9O96m3Bf0C3qgwTbG/8i9pHRVq/ZTKXobeG1bidJB7o=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
