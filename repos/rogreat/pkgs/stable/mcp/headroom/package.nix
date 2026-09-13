{
  fetchFromGitHub,
  lib,
  python3Packages,
  rustPlatform,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "headroom";
  version = "0.37.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "headroomlabs-ai";
    repo = "headroom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-89Tkzx56QIZWfNWLaiPdMynZGOLPr5EAP5RnLSgvBsA=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-iEvap6uLsAqCSv+l/S7K7osxL+yV7Y8pE6Dhaqt2AIA=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  dependencies = with python3Packages; [
    tiktoken
    pydantic
    litellm
    click
    rich
    opentelemetry-api
    ast-grep-cli
    pyyaml
    tomli
    tomlkit
    # [mcp]
    mcp
    httpx
    starlette
    uvicorn
  ];

  # has no tests
  doCheck = false;

  pythonImportsCheck = [ "headroom" ];

  __structuredAttrs = true;

  meta = {
    description = "Compress tool outputs, logs, files, and RAG chunks before they reach the LLM";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ RoGreat ];
    platforms = lib.platforms.all;
  };
})
