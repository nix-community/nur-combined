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
        mlx-lm = super.mlx-lm.overridePythonAttrs (prev: {
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
  version = "0.10.17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "raullenchai";
    repo = "Rapid-MLX";
    rev = "v${version}";
    hash = "sha256-aJS0zWG0iQAw7mpLN1kGJVnoo2YpL1M1ldAHcVNMkoY=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    argcomplete
    fastapi
    huggingface-hub
    jsonschema
    llguidance
    mcp
    mlx
    mlx-lm
    numpy
    openai-harmony
    pillow
    psutil
    pyyaml
    requests
    tabulate
    tokenizers
    tqdm
    transformers
    uvicorn
    websockets
  ];

  # tests require downloaded models and a live server
  doCheck = false;

  pythonImportsCheck = [ "vllm_mlx" ];

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
