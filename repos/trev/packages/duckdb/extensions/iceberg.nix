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
  rev = "5edc45f0ccdb308f066a9274449c3cb0c49ed0ea";
  hash = "sha256-VQTKbqlsdAIzZkhPEbynnOstE4A7RN1Kd7/3+g+DQjE=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
