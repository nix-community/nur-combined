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
  rev = "548887af4e0b77ad4e2c886c4b093e670852ec12";
  hash = "sha256-PuXyRbvmdUDb63URbdRJKFv2G6Iu6dz+C3xurpDyAaE=";
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [
    aws-sdk-cpp
    curl
    zlib
  ];
}
