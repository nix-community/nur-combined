{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "go-mqtt-to-influxdb";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "elgohr";
    repo = "mqtt-to-influxdb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wO/TS+J68UvnadeMqm3xzZ/qv7gitW3Hi84v32UlZKI=";
  };

  vendorHash = null;
  doCheck = false;

  meta = {
    description = "Bridge to write MQTT to InfluxDB";
    homepage = "https://github.com/elgohr/mqtt-to-influxdb";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mqtt-to-influxdb";
  };
})
