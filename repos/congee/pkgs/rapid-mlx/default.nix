{
  lib,
  python3,
  fetchFromGitHub,
  versionCheckHook,
}:

let
  # Swap nixpkgs' CPU-only mlx (built with MLX_BUILD_METAL=OFF) for the
  # official PyPI wheels with prebuilt Metal kernels; mlx-lm picks up the
  # override through the package-set fixpoint.
  python3Packages =
    (python3.override {
      packageOverrides = self: super: {
        mlx = self.callPackage ../mlx-bin { };
        # With Metal compiled in, mlx-lm's pytest suite executes ops on the
        # default (gpu) device and SIGABRTs on GitHub's virtualized macOS
        # runners, which expose no usable Metal device. nixpkgs already runs
        # this suite against its CPU-only mlx.
        mlx-lm = super.mlx-lm.overridePythonAttrs (prev: rec {
          # Upstream caps mlx-lm <0.32 until a coherence sweep clears it.
          version = "0.31.3";
          src = fetchFromGitHub {
            owner = "ml-explore";
            repo = "mlx-lm";
            tag = "v${version}";
            hash = "sha256-DPOJfsIucG8mWt4ZKenymCJo/i9Jw+a+iuIygIIYkA8=";
          };
          pythonRelaxDeps = (prev.pythonRelaxDeps or [ ]) ++ [ "transformers" ];
          doCheck = false;
          # sentencepiece is in the wheel's Requires-Dist, but nixpkgs only
          # supplies it via nativeCheckInputs; without the test env it has
          # to be a real dependency to pass the runtime-deps check.
          dependencies = (prev.dependencies or [ ]) ++ [ self.sentencepiece ];
        });
      };
    }).pkgs;
in
python3Packages.buildPythonApplication rec {
  pname = "rapid-mlx";
  version = "1.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "raullenchai";
    repo = "Rapid-MLX";
    rev = "v${version}";
    hash = "sha256-zpDW/APse8CxN886ZLt4wq8y9BuUpPhCygwhV4/p3o0=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies =
    with python3Packages;
    [
      argcomplete
      certifi
      fastapi
      httpx
      huggingface-hub
      jsonschema
      llguidance
      mcp
      mlx
      mlx-lm
      numpy
      openai-harmony
      pillow
      prompt-toolkit
      psutil
      pydantic-ai-slim
      pypdf
      pyyaml
      referencing
      requests
      rich
      safetensors
      sentencepiece
      tabulate
      tiktoken
      tokenizers
      tomli-w
      tqdm
      transformers
      uvicorn
      websockets
    ]
    # pydantic-ai-slim[openai]
    ++ [ openai ];

  # Text-only, like upstream's Homebrew formula: the image/audio/video
  # stacks (torch, mflux, mlx-vlm, ...) are not packaged here.
  pythonRemoveDeps = [
    "imageio"
    "mflux"
    "mlx-arsenal"
    "mlx-audio"
    "mlx-video-with-audio"
    "mlx-vlm"
    "opencv-python"
    "soundfile"
    "torch"
    "torchvision"
  ];

  # Upstream excludes the broken 5.13.0 (its _LazyAutoMapping.register
  # dereferenced key.__module__, which mlx-lm's string-name tokenizer
  # registration tripped over) and caps <5.16 only as a precaution against
  # unvalidated minors; nixpkgs' 5.16+ imports fine.
  pythonRelaxDeps = [
    "huggingface-hub"
    "mcp"
    "pydantic-ai-slim"
    "tokenizers"
    "transformers"
  ];

  # tests require downloaded models and a live server
  doCheck = false;

  pythonImportsCheck = [
    "rapid_mlx"
    "rapid_mlx.cli"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  versionCheckKeepEnvironment = "HOME";
  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR"
    runHook preInstallCheck
    runHook postInstallCheck
  '';

  meta = {
    description = "Fast local AI inference engine for Apple Silicon with an OpenAI-compatible API";
    homepage = "https://github.com/raullenchai/Rapid-MLX";
    changelog = "https://github.com/raullenchai/Rapid-MLX/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "rapid-mlx";
    platforms = [ "aarch64-darwin" ];
  };
}
