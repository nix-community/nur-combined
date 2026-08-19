{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "drift";
  version = "unstable-2026-08-20";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "TaewoooPark";
    repo = "DRIFT";
    rev = "d36328711c287903f9ca9a9ec243aefb830d5bc0";
    hash = "sha256-OrE7bJHMaxSEVawXhkpEaCZHD65ZjL6jMRseclkEB0g=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    torch
    transformers
    safetensors
    msgpack
    numpy
    huggingface-hub
    accelerate
    pyyaml
    zeroconf
    cryptography
    starlette
    uvicorn
  ];

  pythonImportsCheck = [
    "drift"
  ];

  meta = with lib; {
    description = "Decentralized Routed Inference For Tokens — one model, split across your machines, no datacenter";
    homepage = "https://github.com/TaewoooPark/DRIFT";
    license = licenses.mit;
    mainProgram = "drift";
  };
}
