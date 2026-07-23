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
  rev = "1a683585d4ec482064895540b4a592909acb6f52";
  hash = "sha256-zV4f/0sd8iuCLA27LEFa+JNod69voM18fgr8dW1qH04=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
