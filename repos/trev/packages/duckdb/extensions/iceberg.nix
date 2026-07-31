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
  rev = "7d7990e43a0e60d01cd9ee44770d4edf74f28b08";
  hash = "sha256-ixwfDsawZpU8rZj3NOfIzbPTXCCzY0WbxSOJd1GyM1Y=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
