{
  lib,
  python3Packages,
  fetchFromGitHub,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "rapid-mlx";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "raullenchai";
    repo = "Rapid-MLX";
    rev = "v${version}";
    hash = "sha256-SEjyILstMPJUsCdxE/hzhz9oP8h1Xb9+9k3rxYJtbjo=";
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
