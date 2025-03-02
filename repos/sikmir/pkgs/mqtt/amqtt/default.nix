{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "amqtt";
  version = "0.10.1-unstable-2025-01-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Yakifo";
    repo = "amqtt";
    rev = "440e8ff945bf83c262f3a9d16be2f014fce6265c";
    hash = "sha256-ZFXIYgjNnYqBLLdYgxDpG9JG7weuY3vlHC4pwZlFsh0=";
  };

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    docopt
    passlib
    pyyaml
    transitions
    websockets
  ];

  pythonRelaxDeps = [
    "transitions"
    "websockets"
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    hypothesis
    psutil
    pytest-asyncio
    pytest-cov-stub
    pytest-logdog
    pytestCheckHook
  ];

  pythonImportsCheck = [ "amqtt" ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "MQTT client/broker using Python asyncio";
    homepage = "https://github.com/Yakifo/amqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
