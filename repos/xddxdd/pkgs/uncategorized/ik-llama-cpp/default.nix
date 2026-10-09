{
  lib,
  autoAddDriverRunpath,
  avx2Support ? false,
  avxSupport ? false,
  cmake,
  cudaPackages ? { },
  cudaSupport ? false,
  fetchFromGitHub,
  ninja,
  stdenv,
  unstableGitUpdater,
}:

let
  version = "0-unstable-2026-10-08";
  rev = "04b4ebc2b32240c7495c33cb23ee35ac8108bb2a";
  hash = "sha256-mCFaWQPi8Re+jKF1+pSCCzYqY5UNT5NGVtqzZ5Q+bG8=";

  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
in
effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "ik-llama-cpp";

  __structuredAttrs = true;
  strictDeps = true;

  inherit version;
  src = fetchFromGitHub {
    owner = "ikawrakow";
    repo = "ik_llama.cpp";
    inherit rev hash;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
    autoAddDriverRunpath
  ];

  buildInputs = lib.optionals cudaSupport (
    with cudaPackages;
    [
      cccl
      cuda_cudart
      libcublas
    ]
  );

  doCheck = false;

  cmakeFlags = [
    (lib.cmakeBool "GGML_NATIVE" false)
    (lib.cmakeBool "GGML_RPC" false)
    (lib.cmakeBool "LLAMA_BUILD_TESTS" false)
    (lib.cmakeBool "LLAMA_BUILD_SERVER" true)
    (lib.cmakeBool "GGML_CUDA" cudaSupport)
  ]
  ++ lib.optionals avxSupport [
    (lib.cmakeBool "GGML_AVX" true)
  ]
  ++ lib.optionals avx2Support [
    (lib.cmakeBool "GGML_AVX2" true)
    (lib.cmakeBool "GGML_FMA" true)
    (lib.cmakeBool "GGML_F16C" true)
  ]
  ++ lib.optionals cudaSupport [
    (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaPackages.flags.cmakeCudaArchitecturesString)
  ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/ikawrakow/ik_llama.cpp";
    hardcodeZeroVersion = true;
    shallowClone = false;
  };

  meta = {
    description = "High-performance llama.cpp fork with optimized i-quantization kernels";
    homepage = "https://github.com/ikawrakow/ik_llama.cpp";
    license = lib.licenses.mit;
    mainProgram = "llama-cli";
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.unix;
  }
  // lib.optionalAttrs cudaSupport {
    badPlatforms = lib.platforms.darwin;
  };
})
