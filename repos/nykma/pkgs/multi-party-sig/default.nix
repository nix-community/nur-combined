{
  lib, fetchgit, clangStdenv,
  openssl, protobuf3_20, safeheron-crypto-suites,
  pkg-config, cmake, gtest
}:

let
  src = fetchgit {
    url = "https://github.com/Safeheron/multi-party-sig-cpp.git";
    rev = "807a7a1253936b521d54745e6e909261323b52a4";
    hash = "sha256-lYkTYwsJFi/seNpX+nGrgclV4UsLjhLe+2ykU7hKSKg=";
  };
in
clangStdenv.mkDerivation {
  pname = "multi-party-sig";
  version = "1.0.1";

  srcs = [ src ];

  buildInputs = [
    openssl
    protobuf3_20
    safeheron-crypto-suites
  ];
  nativeBuildInputs = [
    pkg-config
    cmake
    gtest
  ];

  patches = [
    ./patches/CMakeLists.patch
    ./patches/stdint.patch
    ./patches/message_type.patch
  ];

  cmakeFlags = [ "-DENABLE_TESTS=ON" ];

  meta = {
    downloadPage = "https://github.com/Safeheron/multi-party-sig-cpp";
    homepage = "https://blog.safeheron.com/blog/product-and-solution/media-reports/safeheron-releases-worlds-first-c++-based-mpc-protocol-library";
    description = "This project is a C++ implementation of {t,n}-Threshold Signature Scheme";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
