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
  rev = "4c0c0874c48ec82a3e29910554891d04bcc0e988";
  hash = "sha256-zwhf6ePplnWagroxJ7hojgJrllRSRX66/9wH+qi3Fzw=";
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
