{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mqziti";
  version = "unstable-2022-08-26";

  src = fetchFromGitHub {
    owner = "ekoby";
    repo = pname;
    rev = "311cb183f44d5d33fe3319ad955b7bed2fa05069";
    hash = "sha256-s2SWkwWXGDR1zLAoRU1UuHyt4SBa+m/lCFTQps8WH+Y=";
  };

  vendorHash = "sha256-086Of9zg8y5B/ZFF7iDhwGF4EEgyyzqYT49DngnYYos=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "MQTT => MQZiti";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    mainProgram = "mqziti_client";
  };
}
