{
  aws-sdk-cpp,
  callPackage,
  curl,
  zlib,
}:

(callPackage ./generic.nix { }) {
  name = "aws";
  repo = "duckdb-aws";
  rev = "16ae9c135300f750478d648c2496f2952a6f2827";
  hash = "sha256-YjOMPH2jdQ8s8VYXM+lhhvx0Lbp4KT/YVc5Yg67w3mI=";
  duckdbBuildInputs = [
    aws-sdk-cpp
    curl
    zlib
  ];
}
