{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "mochi";
  version = "2.7.7";

  src = fetchFromGitHub {
    owner = "mochi-mqtt";
    repo = "server";
    tag = "v${version}";
    hash = "sha256-gwkiRNXsInD6m3TGC1qQlyMwbkqN+rl8KRZ6MOEp26E=";
  };

  vendorHash = "sha256-qxAl8cyT206jWhC2dEGRikDWmXs9PprmfyFp9nUBUVI=";

  postInstall = ''
    mv $out/bin/{cmd,mochi}
    mv $out/bin/{docker,mochi-docker}
  '';

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "The fully compliant, embeddable high-performance Go MQTT v5 server for IoT, smarthome, and pubsub";
    homepage = "https://github.com/mochi-mqtt/server";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
