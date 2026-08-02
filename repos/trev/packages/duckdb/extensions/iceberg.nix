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
  rev = "d987bfc2015df5d825c09567db782be37001a0b3";
  hash = "sha256-GkbAUy4CPArGF7cAlUfGCzsTmCodjNNhNFzzdXovDp4=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
