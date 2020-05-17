{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "unbound_exporter";
  version = "1739a339d3404a4164a5664dc38e328108c6a2a6";

  src = fetchFromGitHub {
    owner = "kumina";
    repo = pname;
    rev = version;
    sha256 = "194l4alsqpnli844slm8n41cmbk9f6d8r3x5w4dkq62xkp36sis5";
  };

  modSha256 = "10ibfivw5k76z5pbh0zm9x22rfxmcj709cd5fsyx6v7z4nx8yq5z";

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "Prometheus exporter for Unbound";
    homepage = "https://github.com/kumina/unbound_exporter";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
