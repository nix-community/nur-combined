{
  sources,
  lib,
  llama-cpp,
}:

(llama-cpp.override { cudaSupport = true; }).overrideAttrs (old: {
  version = lib.removePrefix "b" sources.llama-cpp.version;
  inherit (sources.llama-cpp) src;

  cmakeFlags = (old.cmakeFlags or [ ]) ++ [
    (lib.cmakeBool "LLAMA_LTO" true)
    (lib.cmakeBool "LLAMA_AVX" false)
    (lib.cmakeBool "LLAMA_AVX2" false)
    (lib.cmakeBool "LLAMA_FMA" false)
    (lib.cmakeBool "LLAMA_F16C" false)
    (lib.cmakeBool "LLAMA_CUDA_FA_ALL_QUANTS" true)
  ];

  postInstall = ''
    mkdir -p $out/include
    cp $src/llama.h $out/include/
  '';
})
