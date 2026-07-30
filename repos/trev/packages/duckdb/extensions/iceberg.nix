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
  rev = "506c407212b89ccc60f81b17e5e23e39c73d7366";
  hash = "sha256-EzVtINejI1iB2rTDO7h4DrSQh9Ekmm1HSSbSzHlD274=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
