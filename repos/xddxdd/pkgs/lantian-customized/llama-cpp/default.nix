{
  sources,
  lib,
  llama-cpp,
}:

(llama-cpp.override { cudaSupport = true; }).overrideAttrs (_old: rec {
  version = lib.removePrefix "b" sources.llama-cpp.version;
  inherit (sources.llama-cpp) src;

  cmakeFlags = [
    (lib.cmakeBool "GGML_NATIVE" false)
    (lib.cmakeBool "GGML_LTO" true)
    (lib.cmakeBool "GGML_AVX" false)
    (lib.cmakeBool "GGML_AVX2" false)
    (lib.cmakeBool "GGML_FMA" false)
    (lib.cmakeBool "GGML_F16C" false)
    (lib.cmakeBool "GGML_CUDA" true)
    (lib.cmakeBool "GGML_CUDA_FA_ALL_QUANTS" true)
    (lib.cmakeBool "LLAMA_BUILD_SERVER" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
  ];

  postPatch = ''
    substituteInPlace ./ggml/src/ggml-metal.m \
      --replace-fail '[bundle pathForResource:@"ggml-metal" ofType:@"metal"];' "@\"$out/bin/ggml-metal.metal\";"

    substituteInPlace ./scripts/build-info.sh \
      --replace-fail 'build_number="0"' 'build_number="${version}"' \
      --replace-fail 'build_commit="unknown"' "build_commit=\"$(cat COMMIT)\""
  '';

  postInstall = ''
    mkdir -p $out/include
    cp $src/include/llama.h $out/include/
  '';
})
