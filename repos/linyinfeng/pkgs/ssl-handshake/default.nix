{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "ssl-handshake";
  version = "1.6.2";
  src = fetchFromGitHub {
    owner = "tuladhar";
    repo = "ssl-handshake";
    rev = "v${version}";
    sha256 = "sha256-OJkFMYSf3rI/pdg4VblDhNxg8NspV0mj21zMbgM35gg=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "A command-line tool for testing SSL/TLS handshake latency";
    homepage = "https://github.com/tuladhar/ssl-handshake";
    license = licenses.mit;
    mainProgram = "ssl-handshake";
    maintainers = with maintainers; [ yinfeng ];
  };
}
