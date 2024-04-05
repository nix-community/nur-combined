{
  lib, fetchgit, clangStdenv,
  openssl, protobuf3_20,
  pkg-config, cmake, gtest
}:

let
  src = fetchgit {
    url = "https://github.com/Safeheron/safeheron-crypto-suites-cpp.git";
    rev = "1690ece051f562c5cf75dcefbc531f811cc6288a";
    hash = "sha256-hJ+RleBkSU7RkdO6nnod2IdDS/MTabUxuk/5aLwDCoo=";
  };
in
clangStdenv.mkDerivation {
  pname = "safeheron-crypto-suites";
  name = "safeheron-crypto-suites";
  version = "1.1.1"; # CMakeFiles says 1.0.1, while git tag says 1.1.1 .

  srcs = [ src ];

  buildInputs = [
    openssl
    protobuf3_20
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    gtest
  ];

  cmakeFlags = [ "-DENABLE_TESTS=ON" ];

  # target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE /usr/local/lib)
  patches = [
    ./patches/cmake.patch
    ./patches/bn.patch
    ./patches/hd_path.patch
    ./patches/located_exception.patch
    ./patches/openssl_curve_wrapper.patch
  ];

  meta = {
    downloadPage = "https://github.com/Safeheron/safeheron-crypto-suites-cpp";
    homepage = "https://blog.safeheron.com/blog/product-and-solution/media-reports/safeheron-releases-worlds-first-c++-based-mpc-protocol-library";
    description = "Cryptographic primitives developed by Safeheron";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
