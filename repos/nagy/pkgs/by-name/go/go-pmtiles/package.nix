{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-pmtiles";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "go-pmtiles";
    rev = "v${version}";
    hash = "sha256-FOYvzYC/tdARfUjcr+cugTSqi3tLezFp8m8lMgLSboU=";
  };

  vendorHash = "sha256-tSQjCdgEXIGlSWcIB6lLQulAiEAebgW3pXL9Z2ujgIs=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description =
      "Single-file executable tool for working with PMTiles archives";
    homepage = "https://github.com/protomaps/go-pmtiles";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nagy ];
    mainProgram = "go-pmtiles";
  };
}
