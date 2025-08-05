{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "mqtt-logger";
  version = "0.3.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Blake-Haydon";
    repo = "mqtt-logger";
    tag = "v${version}";
    hash = "sha256-AG8L2CD+YN6gWswDtsUtUMOA3xC2ro1f1YKYgc4jwXE=";
  };

  pythonRelaxDeps = true;

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    commonmark
    paho-mqtt
    pygments
    rich
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [ "test_basic_instantiation" ];

  meta = {
    description = "Python based MQTT to SQLite3 logger";
    homepage = "https://github.com/Blake-Haydon/mqtt-logger";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
