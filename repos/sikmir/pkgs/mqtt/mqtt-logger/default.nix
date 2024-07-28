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
    rev = "v${version}";
    hash = "sha256-AG8L2CD+YN6gWswDtsUtUMOA3xC2ro1f1YKYgc4jwXE=";
  };

  postPatch = ''
    sed -i 's/==.*//' requirements.txt
    sed -i 's/rich = "^12.0.0"/rich = "*"/' pyproject.toml
  '';

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    commonmark
    paho-mqtt
    pygments
    rich
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Python based MQTT to SQLite3 logger";
    homepage = "https://github.com/Blake-Haydon/mqtt-logger";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
