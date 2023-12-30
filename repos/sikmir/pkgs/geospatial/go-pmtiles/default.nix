{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-pmtiles";
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "go-pmtiles";
    rev = "v${version}";
    hash = "sha256-wKfBL5L77wbNk1YC87G7pAPYb+l4vSG1sB3TI9Qe9vI=";
  };

  vendorHash = "sha256-gLFwGEUeH41bObG32MZznF7clct3h2GEvdZ2/KIiVb4=";

  ldflags = [ "-X main.version=${version}" ];

  meta = with lib; {
    description = "Read/write library & concurrent caching proxy for PMTiles archives";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
