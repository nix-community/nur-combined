{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-pmtiles";
  version = "2021-12-21";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "go-pmtiles";
    rev = "82ab855965337a9497eb6d1ff1026c125b8c2a7d";
    hash = "sha256-jUDaTQ4vImKWaSAdKrIZqO7YjwWvzi1ob7MTbieDeCQ=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "Read/write library & concurrent caching proxy for PMTiles archives";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
