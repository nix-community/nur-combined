{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tsnsrv";
  version = "0-unstable-2024-07-22";

  src = fetchFromGitHub {
    owner = "boinkor-net";
    repo = "tsnsrv";
    rev = "0260f4f52d452d15f71e0297561bba367f92d7fd";
    hash = "sha256-LrMqwcX6e6F93y0+gr1rmABp2eerq6bRu58QftDXLU0=";
  };

  subPackages = [ "cmd/tsnsrv" ];

  vendorHash = "sha256-5Z2qPuQBvLRgsMd9z8WrtGJcLwyJjclyh2g0KdFR3hc=";

  meta = {
    description = "A reverse proxy that exposes services on your tailnet";
    homepage = "https://github.com/boinkor-net/tsnsrv";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "tsnsrv";
  };
}
