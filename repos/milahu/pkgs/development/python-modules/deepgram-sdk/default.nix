{
  lib,
  python,
  fetchFromGitHub,
}:

python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "deepgram-sdk";
  # version = "6.1.1";
  # fix: ModuleNotFoundError: No module named 'deepgram.clients'
  version = "4.8.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "deepgram";
    repo = "deepgram-python-sdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xQTH0jiMEnhUOzDaPfkvGSKssRN4CSnfow+j7VOah0w=";
  };

  build-system = [
    python.pkgs.poetry-core

    # version = "4.8.1";
    python.pkgs.setuptools
  ];

  dependencies = with python.pkgs; [
    httpx
    pydantic
    pydantic-core
    typing-extensions
    websockets

    # version = "4.8.1";
    dataclasses-json
    aiohttp
    aiofiles
    aenum
    deprecation
  ];

  pythonImportsCheck = [
    "deepgram"
  ];

  meta = {
    description = "Official Python SDK for Deepgram";
    homepage = "https://github.com/deepgram/deepgram-python-sdk";
    changelog = "https://github.com/deepgram/deepgram-python-sdk/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "deepgram-sdk";
  };
})
