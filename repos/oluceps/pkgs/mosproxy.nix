{
  lib,
  buildGo122Module,
  fetchFromGitHub,
}:
buildGo122Module {
  pname = "mosproxy";
  version = "0-unstable-2024-04-05";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosproxy";
    rev = "264f9d0c0d257a27a9d93082561aa0f958ce2e17";
    hash = "sha256-S8sY2DtRUDJ/GJ0ub7GrS7iwIBORs0dLwCA8dAwVlnA=";
  });
  vendorHash = "sha256-bDHbviwaI6R4cEjfjBEUeV9Jkk06CmMznvVUUpxyEg8=";
  doCheck = false;
  ldflags = [
    "-s"
    "-w"
  ];
  meta = with lib; {
    description = "A DNS proxy server";
    homepage = "https://github.com/IrineSistiana/mosproxy";
    license = licenses.gpl3;
  };
}
