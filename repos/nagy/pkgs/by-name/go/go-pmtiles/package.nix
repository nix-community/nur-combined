{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-pmtiles";
  version = "1.10.5";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "go-pmtiles";
    rev = "v${version}";
    hash = "sha256-92pERXjZvvb+k0fi8Gi/p/FgvmyBoMb6XG484FkkSSw=";
  };

  vendorHash = "sha256-Dy2ozaxFGGT9UFvgAqFfxmSM5lyX3fudggkZJ5T8KdI=";

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
