{
  sources,
  lib,
  llama-cpp,
}:

(llama-cpp.override { cudaSupport = true; }).overrideAttrs (_old: rec {
  version = lib.removePrefix "b" sources.llama-cpp.version;
  inherit (sources.llama-cpp) src;
})
