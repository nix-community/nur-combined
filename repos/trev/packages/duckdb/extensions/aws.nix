{
  aws-sdk-cpp,
  callPackage,
  curl,
  zlib,
}:

(callPackage ./generic.nix { }) {
  name = "aws";
  repo = "duckdb-aws";
  branch = "v1.5-variegata";
  rev = "28c853c084a6e3acd36d7b8018c42438bb8c5a33";
  hash = "sha256-6FIdsmzzkpUnhxVzN5hd9wuQMPPl9VifoCQjttCJG8M=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    curl
    zlib
  ];
}
