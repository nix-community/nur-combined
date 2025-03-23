{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "mqziti";
  version = "0-unstable-2022-08-25";

  src = fetchFromGitHub {
    owner = "ekoby";
    repo = "mqziti";
    rev = "311cb183f44d5d33fe3319ad955b7bed2fa05069";
    hash = "sha256-s2SWkwWXGDR1zLAoRU1UuHyt4SBa+m/lCFTQps8WH+Y=";
  };

  vendorHash = "sha256-086Of9zg8y5B/ZFF7iDhwGF4EEgyyzqYT49DngnYYos=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "MQTT => MQZiti";
    homepage = "https://github.com/ekoby/mqziti";
    license = lib.licenses.asl20;
    mainProgram = "mqziti_client";
  };
}
