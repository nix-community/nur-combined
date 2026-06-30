{
  sources,
  lib,
  llama-cpp,
}:

(llama-cpp.override { cudaSupport = true; }).overrideAttrs (old: rec {
  version = lib.removePrefix "b" sources.llama-cpp.version;
  inherit (sources.llama-cpp) src;

  npmDepsHash = "sha256-X1DZgmhS/zHTqDT5zq0kywwntthcJ9vRXeqyO3zz6UU=";

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    changelog = "https://github.com/ggml-org/llama.cpp/releases/tag/b${version}";
  };
})
