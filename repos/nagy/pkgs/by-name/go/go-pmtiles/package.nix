{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "go-pmtiles";
  version = "1.20.1";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "go-pmtiles";
    rev = "v${version}";
    hash = "sha256-5kXEbNrstg0ZPfT327FN2/TJw1e5m4FELkCf5iQyrxw=";
  };

  vendorHash = "sha256-Buzk+rPSPrs0q+g6MWVb47cAIKMxsNXlj3CWA0JINXM=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Single-file executable tool for working with PMTiles archives";
    homepage = "https://github.com/protomaps/go-pmtiles";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nagy ];
    mainProgram = "go-pmtiles";
  };
}
