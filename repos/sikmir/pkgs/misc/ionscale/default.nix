{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "ionscale";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "jsiebens";
    repo = "ionscale";
    tag = "v${version}";
    hash = "sha256-OXCxdXkBpbb6qQUGp70OOhi6Ydaw+EXlVTw8QsCjAGQ=";
  };

  vendorHash = "sha256-UzxfIaZ2tbCt0g4WtH0gnSw8HGFI+07JOe4HUdPQmqs=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jsiebens/ionscale/internal/version.Version=${version}"
  ];

  doCheck = false;

  meta = {
    description = "A lightweight implementation of a Tailscale control server";
    homepage = "https://jsiebens.github.io/ionscale/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "ionscale";
  };
}
