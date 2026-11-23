{
  lib,
  fetchFromGitHub,
  llama-cpp,
  rocmSupport ? false,
}:

(llama-cpp.override {
  cudaSupport = false;
  inherit rocmSupport;
  rocmGpuTargets = [ "gfx1151" ];
  vulkanSupport = !rocmSupport;
}).overrideAttrs
  (
    final: prev: {
      pname = "strix-llama-cpp";
      version = "1.1.0";

      src = fetchFromGitHub {
        owner = "halo-box";
        repo = "strix-llama.cpp";
        tag = "v${final.version}";
        hash = "sha256-rQ/mQxi4VlvHkklQgFoJBlUmnDJXcUR8Uv7UHsUiY2I=";
      };

      npmDepsHash = "sha256-hqYzdp1FwPhYkBP278fQXgY9NCKB6Q3P6Gko7BfP0m0=";

      # The fork has its own release tags and build numbering.
      cmakeFlags =
        builtins.filter (
          flag: !lib.hasPrefix "-DLLAMA_BUILD_NUMBER:" flag && !lib.hasPrefix "-DLLAMA_BUILD_COMMIT:" flag
        ) prev.cmakeFlags
        ++ [
          (lib.cmakeFeature "LLAMA_BUILD_COMMIT" final.src.tag)
          (lib.cmakeBool "LLAMA_USE_PREBUILT_UI" false)
        ];

      preConfigure = ''
        pushd ${final.npmRoot}
        LLAMA_BUILD_NUMBER=${final.src.tag} npm run build
        popd
      '';

      passthru = removeAttrs (prev.passthru or { }) [ "updateScript" ];

      meta = {
        description = "llama.cpp fork optimized for AMD Strix Halo, with ${
          if rocmSupport then "ROCm" else "Vulkan"
        } support";
        homepage = "https://github.com/halo-box/strix-llama.cpp";
        changelog = "${final.meta.homepage}/releases/tag/${final.src.tag}";
        license = lib.licenses.mit;
        mainProgram = "llama-cli";
        maintainers = with lib.maintainers; [ weathercold ];
        platforms = [ "x86_64-linux" ];
      };
    }
  )
