{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mqtt-stresser";
  version = "4";

  src = fetchFromGitHub {
    owner = "inovex";
    repo = "mqtt-stresser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4xcoqsbTDxpaR1T7KgkqqT7iOUh8k8GFHYTPoapfjJQ=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Load testing tool to stress MQTT message broker";
    homepage = "https://github.com/inovex/mqtt-stresser";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mqtt-stresser";
  };
})
