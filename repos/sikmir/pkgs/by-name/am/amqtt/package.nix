{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "amqtt";
  version = "0.11.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Yakifo";
    repo = "amqtt";
    tag = "v${version}";
    hash = "sha256-l/YbfrjJsBA5a/IHH2p/B3irZF/z2xzNYxXOMOieV04=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "uv-dynamic-versioning"' ""
  '';

  build-system = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  dependencies = with python3Packages; [
    passlib
    psutil
    pyyaml
    transitions
    typer
    websockets
  ];

  pythonRelaxDeps = true;

  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    hypothesis
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
