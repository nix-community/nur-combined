{
  lib,
  stdenv,
  python3,
  cmake,
  ninja,
  fetchFromGitHub,
  level-zero-1-19,
  intel-compute-runtime-24-39-31294-12,
  oneapi-unified-memory-framework,
  git,
}:
let
  vc-intrinsics = fetchFromGitHub {
    owner = "intel";
    repo = "vc-intrinsics";
    # as seen in https://github.com/intel/llvm/blob/16fa0942206027173be9f969ae691cfb2f7a0425/llvm/lib/SYCLLowerIR/CMakeLists.txt#L9C36-L9C49
    rev = "2d78d5805670d83b3cc6dc488acbd7f0251340c1";
    hash = "sha256-sbmLl+bOOMwr/tbtnXt19qIT3qmrCw7SLefZ4/gEsYw=";
    # License: MIT
  };
  unified-runtime = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "unified-runtime";
    # as seen in https://github.com/intel/llvm/blob/16fa0942206027173be9f969ae691cfb2f7a0425/sycl/cmake/modules/UnifiedRuntimeTag.cmake#L1
    tag = "v0.11.8";
    hash = "sha256-F3UsPazZNnK3U9U7EX2g9XV4wnV4udPXaTLV7mA2hRs=";
    # License: Apache 2 with llvm exceptions
  };
  opencl-headers-src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-Headers";
    rev = "542d7a8f65ecfd88b38de35d8b10aa67b36b33b2";
    hash = "sha256-LgpDEXiFiYDrRTKc5M5RK+2DrPx5ve44P41P9/sHkzE=";
    # License: Apache 2
  };
in
stdenv.mkDerivation rec {
  pname = "intel-oneapi-dpcpp-cpp";
  version = "6.1.0";
  src = fetchFromGitHub {
    owner = "intel";
    repo = "llvm";
    tag = "v${version}";
    hash = "sha256-yyvbG8GwBPA+Nv6xd4ifeInAtfCggLZIcNe8FHp9k9M=";
  };

  nativeBuildInputs = [
    python3
    cmake
    ninja
    git
  ];

  buildInputs = [ oneapi-unified-memory-framework ];

  # hack to bypass "unbypassable" download
  preConfigure = ''
    mkdir -p build
    cp -r ${intel-compute-runtime-24-39-31294-12.src} build/content-exp-headers
    cp -r ${opencl-headers-src} build/_deps/opencl-headers-subbuild/opencl-headers-populate-prefix/src/opencl-headers-populate-stamp/opencl-headers-populate-download
  '';

  # level-zero version as seen in https://github.com/intel/llvm/blob/6a4665ef4c4b429076c589b923da9b9d5f728739/unified-runtime/cmake/FetchLevelZero.cmake#L50C38-L50C78
  configurePhase = ''
    runHook preConfigure
    python3 buildbot/configure.py \
      -Wno-dev \
      -DCMAKE_MODULE_PATH="${oneapi-unified-memory-framework}/lib/cmake" \
      -DLLVMGenXIntrinsics_SOURCE_DIR=${vc-intrinsics} \
      -DSYCL_UR_USE_FETCH_CONTENT=OFF \
      -DSYCL_UR_SOURCE_DIR=${unified-runtime} \
      -DUR_LEVEL_ZERO_INCLUDE_DIR=${level-zero-1-19}/include \
      -DUR_LEVEL_ZERO_LOADER_LIBRARY=${level-zero-1-19}/lib \
      -DUR_USE_EXTERNAL_UMF=ON \
  '';
  #   -DUR_COMPUTE_RUNTIME_FETCH_REPO=OFF \
  # -DUR_COMPUTE_RUNTIME_REPO=${intel-compute-runtime.src}

  buildPhase = ''
    python buildbot/compile.py
  '';

  installPhase = ''
    cp * $out/
  '';

  meta = {
    homepage = "https://github.com/intel/llvm/?tab=readme-ov-file#oneapi-dpc-compiler";
    description = "DPC++ is a LLVM-based compiler project that implements compiler and runtime support for the SYCL* language";
    license = with lib.licenses; [
      ncsa
      asl20
      llvm-exception
    ];
    maintainers = with lib.maintainers; [ kuflierl ];
    broken = true;
  };
}
