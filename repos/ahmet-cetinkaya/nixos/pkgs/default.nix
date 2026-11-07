final: prev: {
  antigravity-tools-bin = final.callPackage ./antigravity-tools-bin {};
  dikte-bin = final.callPackage ./dikte-bin {};
  mempalace = final.python314Packages.callPackage ./mempalace {};
  # Craft App Suite (storytold) — shared builder + per-app pins.
  # See craft-apps/builder.nix; only pdfcraft is installed on hosts.
  craftBuilder = final.callPackage ./craft-apps/builder.nix {};
  photocraft-bin = final.craftBuilder (import ./craft-apps/photocraft/default.nix);
  lightcraft-bin = final.craftBuilder (import ./craft-apps/lightcraft/default.nix);
  filmcraft-bin = final.craftBuilder (import ./craft-apps/filmcraft/default.nix);
  designcraft-bin = final.craftBuilder (import ./craft-apps/designcraft/default.nix);
  vectorcraft-bin = final.craftBuilder (import ./craft-apps/vectorcraft/default.nix);
  pdfcraft-bin = final.craftBuilder (import ./craft-apps/pdfcraft/default.nix);
  effectcraft-bin = final.craftBuilder (import ./craft-apps/effectcraft/default.nix);
  wordcraft-bin = final.craftBuilder (import ./craft-apps/wordcraft/default.nix);
  deckcraft-bin = final.craftBuilder (import ./craft-apps/deckcraft/default.nix);
  gridcraft-bin = final.craftBuilder (import ./craft-apps/gridcraft/default.nix);
  cadcraft-bin = final.craftBuilder (import ./craft-apps/cadcraft/default.nix);
  soundcraft-bin = final.craftBuilder (import ./craft-apps/soundcraft/default.nix);
  openfortigui = final.callPackage ./openfortigui {};
  munder-difflin-bin = final.callPackage ./munder-difflin-bin {};
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
  # posthog: marked broken only for its tests (fail with mcp >= 2); the client
  #   itself works (used transitively via chromadb → mempalace)
  python314Packages = (prev.python314.override {
    packageOverrides = pyfinal: pyprev: {
      pandas-stubs = pyprev.pandas-stubs.overridePythonAttrs (_: { doCheck = false; pythonImportsCheck = []; });
      optuna = pyprev.optuna.overridePythonAttrs (_: { doCheck = false; });
      posthog = pyprev.posthog.overridePythonAttrs (old: {
        doCheck = false;
        meta = (old.meta or {}) // {broken = false;};
      });
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
