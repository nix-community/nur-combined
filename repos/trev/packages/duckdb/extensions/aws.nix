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
  rev = "08ad34f625e4a8e15221e462b96000ff29174447";
  hash = "sha256-ut7+a6PiR5LWyrITEJaC8MLDrtdqtWyjOaP1hqerllA=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    curl
    zlib
  ];
}
