{
  lib,
  stdenv,
  python3,
  cmake,
  ninja,
  fetchFromGitHub,
}:
let
  vc-intrinsics-src = fetchFromGitHub {
    owner = "intel";
    repo = "vc-intrinsics";
    rev = "2d78d5805670d83b3cc6dc488acbd7f0251340c1";
    hash = "sha256-sbmLl+bOOMwr/tbtnXt19qIT3qmrCw7SLefZ4/gEsYw=";
  };
  unified-runtime-src = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "unified-runtime";
    rev = "v0.11.8";
    hash = "sha256-F3UsPazZNnK3U9U7EX2g9XV4wnV4udPXaTLV7mA2hRs=";
  };
  level-zero-loader-src = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "level-zero";
    rev = "v1.19.2";
    hash = "sha256-MnTPu7jsjHR+PDHzj/zJiBKi9Ou/cjJvrf87yMdSnz0=";
  };
  unified-memory-framework-src = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "unified-memory-framework";
    rev = "v0.10.0";
    hash = "sha256-8X08hlLulq132drznb4QQcv2qXWwCc6LRMFDDRcU3bk=";
  };
  opencl-headers-src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-Headers";
    rev = "542d7a8f65ecfd88b38de35d8b10aa67b36b33b2";
    hash = "sha256-LgpDEXiFiYDrRTKc5M5RK+2DrPx5ve44P41P9/sHkzE=";
  };
  ocl-headers-src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-Headers";
    rev = "542d7a8f65ecfd88b38de35d8b10aa67b36b33b2";
    hash = "sha256-LgpDEXiFiYDrRTKc5M5RK+2DrPx5ve44P41P9/sHkzE=";
  };
  ocl-icd-src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-ICD-Loader";
    rev = "804b6f040503c47148bee535230070da6b857ae4";
    hash = "sha256-tl4qtBwzfpR1gR+qEFyM/zdDzHVpVhbo3PCfbj95q/0=";
  };
  boost_mp11-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "mp11";
    rev = "boost-1.85.0";
    hash = "sha256-yvK4F4Z+cr5YdORzLRgL+LyeKwvpY2MBynPIDFRATS0=";
  };
  boost_unordered-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "unordered";
    rev = "boost-1.85.0";
    hash = "sha256-92679XwEzixsEcXJRKPwn+QqePdyDAmx3qk9uNWX580=";
  };
  boost_assert-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "assert";
    rev = "boost-1.85.0";
    hash = "sha256-zY9g31AlJSWZmciN/3ms30nho3QAHXoZex3xMG1kk+Y=";
  };
  boost_config-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "config";
    rev = "boost-1.85.0";
    hash = "sha256-eo8O+MUtyqGvF4OFb99PXahsM3uB6QdNCMqLAExXQ1c=";
  };
  boost_container_hash-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "container_hash";
    rev = "boost-1.85.0";
    hash = "sha256-RKedPIA4ETrRgDX6jBG5lJaapyrtmgG1LVzL+HOLMn0=";
  };
  boost_core-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "core";
    rev = "boost-1.85.0";
    hash = "sha256-ic+3fWg+xyExTmarACuP7+cJO5goa4Q+mc6tMDYJ/SU=";
  };
  boost_describe-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "describe";
    rev = "boost-1.85.0";
    hash = "sha256-z5/0ah8qglVe+WRwGGEolokVfBex0uMYbF6rgW5gA2I=";
  };
  boost_predef-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "predef";
    rev = "boost-1.84.0";
    hash = "sha256-puQw1kGDtdrCbIvZ4Egj9++qj4XaaAwjuPuLTVZ+w3o=";
  };
  boost_static_assert-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "static_assert";
    rev = "boost-1.78.0";
    hash = "sha256-r2gxsp0b1HvPu4uvr6CBqjMrqRmYWbakv5QDCNQX6rc=";
  };
  boost_throw_exception-src = fetchFromGitHub {
    owner = "boostorg";
    repo = "throw_exception";
    rev = "boost-1.85.0";
    hash = "sha256-APdrA3PJ2b90ImBEiAWS3MoQrMuXBGAt2YKZ82wGdrM=";
  };
  emhash-headers-src = fetchFromGitHub {
    owner = "ktprime";
    repo = "emhash";
    rev = "96dcae6fac2f5f90ce97c9efee61a1d702ddd634";
    hash = "sha256-yvnu8TMIX6KJZlYJv3ggLf9kOViKXeUp4NyhRg4m5Dg=";
  };
  parallel-hashmap-src = fetchFromGitHub {
    owner = "greg7mdp";
    repo = "parallel-hashmap";
    rev = "8a889d3699b3c09ade435641fb034427f3fd12b6";
    hash = "sha256-hcA5sjL0LHuddEJdJdFGRbaEXOAhh78wRa6csmxi4Rk=";
  };
  SPIRV-Headers = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "efb6b4099ddb8fa60f62956dee592c4b94ec6a49";
    hash = "sha256-07ROnZ+0xrZRoqUbLJAhqERV3X8E6iBEfMYfhWMfuyA=";
  };
  content-exp-headers = fetchFromGitHub {
    owner = "intel";
    repo = "compute-runtime";
    rev = "24.39.31294.12";
    hash = "sha256-7GNtAo20DgxAxYSPt6Nh92nuuaS9tzsQGH+sLnsvBKU=";
  };
in
stdenv.mkDerivation rec {
  pname = "intel-oneapi-dpcpp-cpp-pure";
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
  ];

  preConfigure = ''
    mkdir -p build/{_deps,tools/llvm-spirv}
    cp -r ${vc-intrinsics-src} ./build/_deps/vc-intrinsics-src
    cp -r ${unified-runtime-src} ./build/_deps/unified-runtime-src
    cp -r ${level-zero-loader-src} ./build/_deps/level-zero-loader-src
    cp -r ${unified-memory-framework-src} ./build/_deps/unified-memory-framework-src
    cp -r ${opencl-headers-src} ./build/_deps/opencl-headers-src
    cp -r ${ocl-headers-src} ./build/_deps/ocl-headers-src
    cp -r ${ocl-icd-src} ./build/_deps/ocl-icd-src
    cp -r ${boost_mp11-src} ./build/_deps/boost_mp11-src
    cp -r ${boost_unordered-src} ./build/_deps/boost_unordered-src
    cp -r ${boost_assert-src} ./build/_deps/boost_assert-src
    cp -r ${boost_config-src} ./build/_deps/boost_config-src
    cp -r ${boost_container_hash-src} ./build/_deps/boost_container_hash-src
    cp -r ${boost_core-src} ./build/_deps/boost_core-src
    cp -r ${boost_describe-src} ./build/_deps/boost_describe-src
    cp -r ${boost_predef-src} ./build/_deps/boost_predef-src
    cp -r ${boost_static_assert-src} ./build/_deps/boost_static_assert-src
    cp -r ${boost_throw_exception-src} ./build/_deps/boost_throw_exception-src
    cp -r ${emhash-headers-src} ./build/_deps/emhash-headers-src
    cp -r ${parallel-hashmap-src} ./build/_deps/parallel-hashmap-src
    cp -r ${SPIRV-Headers} ./build/tools/llvm-spirv/SPIRV-Headers
    cp -r ${content-exp-headers} ./build/content-exp-headers
  '';

  # level-zero version as seen in https://github.com/intel/llvm/blob/6a4665ef4c4b429076c589b923da9b9d5f728739/unified-runtime/cmake/FetchLevelZero.cmake#L50C38-L50C78
  configurePhase = ''
    runHook preConfigure
    python3 buildbot/configure.py \
      -Wno-dev
  '';

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
