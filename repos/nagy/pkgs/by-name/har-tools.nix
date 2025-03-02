{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "har-tools";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "outersky";
    repo = "har-tools";
    rev = "v${version}";
    hash = "sha256-DRVO4zUdvb34T3st4+dhxxoORGncJsMD8XLWmzGdOs0=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "tools for HAR file";
    homepage = "https://github.com/outersky/har-tools";
    license = licenses.gpl2Only;
    mainProgram = "harx";
  };
}
