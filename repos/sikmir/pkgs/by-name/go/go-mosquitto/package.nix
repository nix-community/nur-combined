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
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "mutablelogic";
    repo = "go-mosquitto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eUe6ntxWW0eAQMNSiW73EpZH8SRF/fM9bluBxR3ajY4=";
  };

  vendorHash = "sha256-DAHB9u1S7DkxcpN1zdwFGjZTFLKVQG+O3hK/mqZZUMM=";

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
