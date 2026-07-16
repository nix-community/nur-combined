{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "cliproxyapi";
  version = "7.2.80";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    rev = "v${version}";
    hash = "sha256-becB1mP/n5uqySpYr9fW5veT1Z08os6y5KrttLAj/VY=";
  };

  vendorHash = "sha256-xirNOpnPVwe/TqEYkHHLMWREajosaisBazvy8rFEIak=";

  subPackages = [ "cmd/server" ];

  postInstall = ''
    mv $out/bin/server $out/bin/cli-proxy-api
  '';

  meta = with lib; {
    description = "CLIProxyAPI - A proxy API application";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = licenses.mit;
    mainProgram = "cli-proxy-api";
  };
}
