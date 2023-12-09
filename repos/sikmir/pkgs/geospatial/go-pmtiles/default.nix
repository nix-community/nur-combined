{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-pmtiles";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "go-pmtiles";
    rev = "v${version}";
    hash = "sha256-qmCnf88fc2cR6OFZqj89FDxaaxiVJ6140qs2lj7Xm1E=";
  };

  vendorHash = "sha256-qcbTNH15wiscgPOfT3Zmm9k7/P9AIMb4CwfEPGJHNqs=";

  ldflags = [ "-X main.version=${version}" ];

  meta = with lib; {
    description = "Read/write library & concurrent caching proxy for PMTiles archives";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
