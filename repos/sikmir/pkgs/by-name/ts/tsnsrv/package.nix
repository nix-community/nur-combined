{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "tsnsrv";
  version = "0-unstable-2025-10-01";

  src = fetchFromGitHub {
    owner = "boinkor-net";
    repo = "tsnsrv";
    rev = "a4e47c178e0bdd4da72fad6f0dd2dea6b89d2d25";
    hash = "sha256-b0d0lfERd3+N/K0oq4YsX2pSMGh5HX5D6ocehEoJjeU=";
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
