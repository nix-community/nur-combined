{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "mqtt-to-influxdb-forwarder";
  version = "2.1.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "mhaas";
    repo = "mqtt-to-influxdb-forwarder";
    rev = "v${version}";
    hash = "sha256-2n5YF5aLaUzHmxgPhnRXXyhoXV0nJ21aa7g+NBTYvBk=";
  };

  postPatch = ''
    substituteInPlace forwarder.py --replace "ur'" "r'"
  '';

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  propagatedBuildInputs = with python3Packages; [ paho-mqtt influxdb ];

  installPhase = ''
    install -Dm755 forwarder.py $out/bin/mqtt-to-influxdb-forwarder
  '';

  meta = with lib; {
    description = "IoT MQTT to InfluxDB forwarder";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ sikmir ];
  };
}
