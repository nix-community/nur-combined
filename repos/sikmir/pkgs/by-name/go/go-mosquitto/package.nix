{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  mosquitto,
  sqlite,
}:

buildGoModule (finalAttrs: {
  pname = "go-mosquitto";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "mutablelogic";
    repo = "go-mosquitto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JCsIUbQuMkJrzOI3naUZkEJXYPUHAzIucSj/bbhDFFs=";
  };

  vendorHash = "sha256-/1xaR3jFqKgyFMBsHmwgWrE7kG5MYX86uqyBmiQqPh4=";

  subPackages = [
    "cmd/mqttpub"
    "cmd/mqttsub"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    mosquitto
    sqlite
  ];

  meta = {
    description = "Golang Mosquitto MQTT Client Library";
    homepage = "https://github.com/mutablelogic/go-mosquitto";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
