{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mochi";
  version = "2.7.9";

  src = fetchFromGitHub {
    owner = "mochi-mqtt";
    repo = "server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZdKaCzQsigf7G9uMthnm7n3fdyesZul+LNq6i+X8Yls=";
  };

  vendorHash = "sha256-qxAl8cyT206jWhC2dEGRikDWmXs9PprmfyFp9nUBUVI=";

  postInstall = ''
    mv $out/bin/{cmd,mochi}
    mv $out/bin/{docker,mochi-docker}
  '';

  doCheck = false; # listen tcp :22222: bind: address already in use

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "The fully compliant, embeddable high-performance Go MQTT v5 server for IoT, smarthome, and pubsub";
    homepage = "https://github.com/mochi-mqtt/server";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mochi";
  };
})
