{
  sources,
  lib,
  llama-cpp,
}:

(llama-cpp.override { cudaSupport = true; }).overrideAttrs (old: rec {
  version = lib.removePrefix "b" sources.llama-cpp.version;
  inherit (sources.llama-cpp) src;

  postPatch = builtins.replaceStrings [ "./ggml/src/ggml-metal.m" ] [
    "./ggml/src/ggml-metal/ggml-metal.m"
  ] old.postPatch;

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
