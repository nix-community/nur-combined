{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "har-tools";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "outersky";
    repo = "har-tools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DRVO4zUdvb34T3st4+dhxxoORGncJsMD8XLWmzGdOs0=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "tools for HAR file";
    homepage = "https://github.com/outersky/har-tools";
    license = lib.licenses.gpl2Only;
    mainProgram = "harx";
  };
})
