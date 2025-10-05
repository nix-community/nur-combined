{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "mqtt-to-influxdb-forwarder";
  version = "2.1.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "mhaas";
    repo = "mqtt-to-influxdb-forwarder";
    tag = "v${version}";
    hash = "sha256-2n5YF5aLaUzHmxgPhnRXXyhoXV0nJ21aa7g+NBTYvBk=";
  };

  postPatch = ''
    substituteInPlace forwarder.py --replace-fail "ur'" "r'"
  '';

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  dependencies = with python3Packages; [
    paho-mqtt
    influxdb
  ];

  installPhase = ''
    install -Dm755 forwarder.py $out/bin/mqtt-to-influxdb-forwarder
  '';

  meta = {
    description = "IoT MQTT to InfluxDB forwarder";
    homepage = "https://github.com/mhaas/mqtt-to-influxdb-forwarder";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
