final: prev: {
  antigravity-tools-bin = final.callPackage ./antigravity-tools-bin {};
  openfortigui = final.callPackage ./openfortigui {};
  orca-bin = final.callPackage ./orca-bin {};
  prince-bin = final.callPackage ./prince-bin {};
  zed-preview-bin = final.callPackage ./zed-preview-bin {};
  # 0.43.0 has dead-code errors with Rust -D warnings in test builds;
  # skip tests entirely until upstream fixes it.
  rtk = prev.rtk.overrideAttrs (old: { doCheck = false; });

  # Python 3.14 package fixes (see modules/apps/document-conversion.nix).
  # pandas-stubs: pytest parametrize(generator) fails with pytest 9
  #   (used transitively via pdfplumber → markitdown)
  # optuna: logging + visualization tests fail on Python 3.14
  #   (used transitively via pyannote-pipeline → whisperx)
  python314Packages = (prev.python314.override {
    packageOverrides = pyfinal: pyprev: {
      pandas-stubs = pyprev.pandas-stubs.overridePythonAttrs (_: { doCheck = false; pythonImportsCheck = []; });
      optuna = pyprev.optuna.overridePythonAttrs (_: { doCheck = false; });
    };
  }).pkgs;

  # A full nixpkgs instance with CUDA ENABLED, used ONLY to source the GPU
  # Python stack (torch/ctranslate2/...) for whisper-gui-cuda. cudaSupport is
  # intentionally NOT set globally in the system config, because that drags
  # unrelated packages (firefox, thunderbird, ...) into CUDA rebuilds that
  # miss cache.nixos.org and compile from source. Scoping CUDA to just this
  # instance keeps whisper-gui-cuda GPU-accelerated while everything else
  # stays on its normal cached binary. (The derivation hashes here are
  # byte-identical to the global-cudaSupport ones, so nothing already built
  # is re-done.)
  pkgsCuda = import prev.path {
    inherit (prev.stdenv.hostPlatform) system;
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };

  ollama-cuda = prev.ollama-cuda.overrideAttrs (old: {
    preBuild = ''
      # CMake 4.3.4's FindCUDAToolkit.cmake reads CUDAToolkit_ROOT from the
      # environment. The nixpkgs setupCUDAToolkitCompilers hook appends all
      # buildInputs paths to it, producing a garbled single path.
      # CUDA_PATH has the major version suffix stripped (cuda-merged) which
      # doesn't exist; the actual buildEnv is cuda-merged-<MAJ>. Find it.
      for _cu_dir in "$CUDA_PATH" "$CUDA_PATH"-*; do
        if [ -x "$_cu_dir/bin/nvcc" ]; then
          export CUDAToolkit_ROOT="$_cu_dir"
          break
        fi
      done
      unset _cu_dir
    '' + (old.preBuild or "");
  });

  whisper-gui-cuda = final.callPackage ./whisper-gui-cuda {
    python3 = final.pkgsCuda.python3.override {
      packageOverrides = pyfinal: pyprev: {
        gradio-client = pyprev.gradio-client.overridePythonAttrs (old: {
          passthru = old.passthru // {
            sans-reverse-dependencies = old.passthru.sans-reverse-dependencies.overrideAttrs (_: {
              dontCheckPythonMetadata = true;
            });
          };
        });
        gradio-pdf = pyprev.gradio-pdf.overridePythonAttrs (_: {
          pythonImportsCheck = [];
        });
        onnxruntime = pyprev.onnxruntime.override {
          onnxruntime = final.onnxruntime;
        };
      };
    };
    cudaPackages = final.pkgsCuda.cudaPackages;
  };
}
