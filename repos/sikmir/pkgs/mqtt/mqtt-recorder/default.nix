{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "mqtt-recorder";
  version = "1.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rpdswtk";
    repo = "mqtt_recorder";
    rev = "0abaf0dd757a06f7f400c8d5e0cb93aa6cd4a761";
    hash = "sha256-3oKqfOIK7zrfT8T5n7/+OD3zMMUZxY0IUpHIhzzHoaE=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    paho-mqtt
    tqdm
  ];

  meta = {
    description = "Simple cli tool for recording and replaying MQTT messages";
    homepage = "https://github.com/rpdswtk/mqtt_recorder";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
