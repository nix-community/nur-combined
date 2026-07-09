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
  rev = "45163a28e0ed6a2071a82a1bf1dd432d0216cf9c";
  hash = "sha256-g7H0kKFjuiQ7LL3HvWe0PJYeAzlfh9f71JVVfz4zkWI=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    croaring
    curl
    zlib
  ];
}
