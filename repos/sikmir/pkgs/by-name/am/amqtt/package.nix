{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "amqtt";
  version = "0.11.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Yakifo";
    repo = "amqtt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J2BWaUJacsCDa3N9fNohn0l+5Vl4+g8Y8aWetjCfZ/A=";
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
    dacite
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
})
