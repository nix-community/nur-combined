{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "tsnsrv";
  version = "0-unstable-2025-12-29";

  src = fetchFromGitHub {
    owner = "boinkor-net";
    repo = "tsnsrv";
    rev = "8f3fbf69e1517612c0fde9be27522e12c2ddc238";
    hash = "sha256-uRm4oWMFUBSmXgofOngMWIyA/yUmLlon6f3XoFTWvBA=";
  };

  subPackages = [ "cmd/tsnsrv" ];

  vendorHash = "sha256-Mhx2WITsCby3Tou70+SLE68hpcCVhL2tWxy8kdoh0Ws=";

  meta = {
    description = "A reverse proxy that exposes services on your tailnet";
    homepage = "https://github.com/boinkor-net/tsnsrv";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tsnsrv";
  };
}
