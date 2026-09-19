{
  llama-cpp,
  fetchFromGitHub,
  fetchNpmDeps,
  lib,
}:

(llama-cpp.override { cudaSupport = true; }).overrideAttrs (
  final: prev: {
    pname = "prismml-llama-cpp";
    version = "0.3.0-prism-b10685";

    src = fetchFromGitHub {
      owner = "PrismML-Eng";
      repo = "llama.cpp";
      rev = "7dffb158de30ebb8ef9d64f33c6b0b2d7c1e6313";
      hash = "sha256-8/oJa/GpMnbfvKjAmBrmX0E+L2hoStlUJLz9AjXavnI=";
    };

    # tools/ui lockfile matches ggml-org v0.3.0.
    npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
    npmDeps = fetchNpmDeps {
      name = "${final.pname}-${final.version}-npm-deps";
      inherit (final) src;
      inherit (prev) patches;
      preBuild = ''
        pushd tools/ui
      '';
      hash = final.npmDepsHash;
    };

    cmakeFlags = (prev.cmakeFlags or [ ]) ++ [
      (lib.cmakeFeature "LLAMA_BUILD_NUMBER" "10685")
      (lib.cmakeFeature "LLAMA_BUILD_COMMIT" "7dffb15")
    ];

    meta = prev.meta // {
      description = "PrismML llama.cpp fork with ternary GGUF kernels";
      homepage = "https://github.com/PrismML-Eng/llama.cpp";
      mainProgram = "llama-server";
    };
  }
)
