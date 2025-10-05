{
  lib,
  fetchFromGitHub,
  python3Packages,
  pytest-docker-fixtures,
}:

python3Packages.buildPythonPackage rec {
  pname = "pytest-mqtt";
  version = "0.4.1";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "mqtt-tools";
    repo = "pytest-mqtt";
    tag = version;
    hash = "sha256-DohQw10WCDlb9kJdMd9ql4mcELx4IhVSmoovLI6GI9k=";
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
}
