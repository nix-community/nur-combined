{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "osmmcp";
  version = "0-unstable-2025-11-26";

  src = fetchFromGitHub {
    owner = "estebamod";
    repo = "osmmcp";
    rev = "2e9620bafceacee81f5ee274fb46f562fb9ec66b";
    hash = "sha256-SgBomoXu8XnZpcBbE1TG3f4T8VgpVYLaguolb4ex02k=";
  };

  vendorHash = "sha256-qJoOG/wasCXPWDBc3AHtWsTD7TFrLRa49Eo9f5WrS50=";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${finalAttrs.version}"
  ];

  doCheck = false;

  postInstall = ''
    mv $out/bin/{cmd,debug_polyline}
  '';

  meta = {
    description = "OpenStreetMap MCP Server";
    homepage = "https://github.com/estebamod/osmmcp";
    license = lib.licenses.mit;
    mainProgram = "osmmcp";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
