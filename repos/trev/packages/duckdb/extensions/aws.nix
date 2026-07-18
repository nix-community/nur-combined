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
  rev = "efa54a990e16c976576685dd4134d2478cf5a574";
  hash = "sha256-6FIdsmzzkpUnhxVzN5hd9wuQMPPl9VifoCQjttCJG8M=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    curl
    zlib
  ];
}
