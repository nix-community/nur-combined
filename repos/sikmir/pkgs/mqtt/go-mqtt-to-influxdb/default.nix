{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "go-mqtt-to-influxdb";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "elgohr";
    repo = "mqtt-to-influxdb";
    rev = "v${version}";
    hash = "sha256-wO/TS+J68UvnadeMqm3xzZ/qv7gitW3Hi84v32UlZKI=";
  };

  vendorHash = null;
  doCheck = false;

  meta = with lib; {
    description = "Bridge to write MQTT to InfluxDB";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
