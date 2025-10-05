{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "mqtt-launcher";
  version = "0-unstable-2021-09-17";
  format = "other";

  src = fetchFromGitHub {
    owner = "jpmens";
    repo = "mqtt-launcher";
    rev = "bce7a5b320e7b81cfbb904d70033b9998f70e232";
    hash = "sha256-FEKvlED/Sgcr7vBa8HW2N7mapmARiemcJ22zwuTwORw=";
  };

  dependencies = with python3Packages; [ paho-mqtt ];

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  postInstall = ''
    install -Dm755 mqtt-launcher.py $out/bin/mqtt-launcher
  '';

  meta = {
    description = "Execute shell commands triggered by published MQTT messages";
    homepage = "https://github.com/jpmens/mqtt-launcher";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
