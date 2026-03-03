{
  lib,
  fetchFromGitHub,
  python3Packages,
  pytest-docker-fixtures,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pytest-mqtt";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mqtt-tools";
    repo = "pytest-mqtt";
    tag = finalAttrs.version;
    hash = "sha256-rrcJBb4aXflUeLaOjQaFeb8vV+dKuDtQdyDR80/yJJc=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    paho-mqtt
    pytest-docker-fixtures
  ];

  meta = {
    description = "pytest-mqtt supports testing systems based on MQTT";
    homepage = "https://github.com/mqtt-tools/pytest-mqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
