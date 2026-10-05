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
  rev = "5dcf5070c50341c2e4b4403b67ed4cbc7afaa37b";
  hash = "sha256-RJ/D5o6NOelrXtOv4mBIJBRR28yRKWudOcDkuB4uIZY=";
  loadOptions = [ "DONT_LINK" ];
  dependencies = [
    "avro"
    "httpfs"
  ];
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
