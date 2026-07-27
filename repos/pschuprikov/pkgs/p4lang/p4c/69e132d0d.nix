{ stdenv, fetchFromGitHub, boost, gmp, boehmgc, cmake, flex, bison, protobuf3_2, python3 }:
stdenv.mkDerivation {
  name = "p4c";
  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "p4c";
    rev = "69e132d0d663e3408d740aaf8ed534ecefc88810";
    sha256 = "sha256-23jzvNd/39M9LZv9hFzCuYq8JXffRhIwi4uI2sMrN9E=";
    fetchSubmodules = true;
  };
  buildInputs = [ boost gmp boehmgc ];
  nativeBuildInputs = [ python3 cmake flex bison protobuf3_2 ];
  cmakeFlags = [ "-DENABLE_UNIFIED_COMPILATION=OFF" ];
}
