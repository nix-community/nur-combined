{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "hanga-signal";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "johanhelsing";
    repo = "matchbox";
    rev = "v${version}";
    hash = "sha256-apmA6agWeqrzRmWhtn4vAGw6u9FAqZ188QtWViQVrh0=";
  };

  cargoHash = "sha256-xncSQ7ZIwUfRH94NMXz8etQNfappucVcby87+OeWzRk=";

  buildAndTestSubdir = "matchbox_server";

  doCheck = false;

  postInstall = ''
    ln -s matchbox_server $out/bin/hanga-signal
  '';

  meta = {
    description = "Matchbox signaling server for Hanga multiplayer (port 3536)";
    homepage = "https://github.com/johanhelsing/matchbox";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "hanga-signal";
  };
}
