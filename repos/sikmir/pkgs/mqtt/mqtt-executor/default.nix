{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mqtt-executor";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "rainu";
    repo = "mqtt-executor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y3mvTWlIpHL0W4z7psbsKBkWn07RAFsx3D/pjcQe+Nk=";
  };

  patches = [ ./go.mod.patch ];

  vendorHash = "sha256-04Qc+9QDjNfHy5sGGbm+HvLRtKZb7YSKxV9ebDdtpOA=";

  meta = {
    description = "A simple MQTT client that subscribes to a configurable list of MQTT topics on the specified broker and executes a given shell script/command whenever a message arrives";
    homepage = "https://github.com/rainu/mqtt-executor";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mqtt-executor";
  };
})
