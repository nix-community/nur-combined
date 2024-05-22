{
  lib,
  buildGo122Module,
  fetchFromGitHub,
}:
buildGo122Module {
  pname = "mosproxy";
  version = "0-unstable-2024-05-01";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosproxy";
    rev = "8ad60f753b23137b02cc1af18e2784e67389489d";
    hash = "sha256-ZVMXxfrJ/+BJpQ16lZpLnH0QIW1ysbLpilkonJ3qX5U=";
  });
  vendorHash = "sha256-ZeWdUUBlGoxmoANPIiduf4x2mrCRa4BgUino3GQ4drU=";
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
