{
  stdenv,
  lib,
  level-zero-1-19,
  cmake,
  fetchFromGitHub,
  hwloc,
  numactl,
}:
stdenv.mkDerivation rec {
  pname = "oneapi-unified-memory-framework";
  version = "0.10.0";

  buildInputs = [
    hwloc
    numactl
    level-zero-1-19
  ];

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeFeature "UMF_LEVEL_ZERO_INCLUDE_DIR" "${level-zero-1-19}/include/level_zero")
    (lib.cmakeBool "UMF_BUILD_CUDA_PROVIDER" false)
    (lib.cmakeBool "UMF_BUILD_TESTS" false) # requires google-test
    #(lib.cmakeBool "UMF_BUILD_SHARED_LIBRARY" true)
  ];

  src = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "unified-memory-framework";
    tag = "v${version}";
    hash = "sha256-8X08hlLulq132drznb4QQcv2qXWwCc6LRMFDDRcU3bk=";
  };

  meta = {
    homepage = "https://oneapi-src.github.io/unified-memory-framework/";
    description = "The Unified Memory Framework (UMF) is a library for constructing allocators and memory pools";
    maintainers = with lib.maintainers; [ kuflierl ];
    license = with lib.licenses; [
      ncsa
      asl20
      llvm-exception
    ];
  };
}
