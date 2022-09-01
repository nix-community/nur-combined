{ lib, buildGoModule, fetchFromGitHub, leveldb, geos }:

buildGoModule rec {
  pname = "imposm";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "omniscale";
    repo = "imposm3";
    rev = "v${version}";
    hash = "sha256-ufP617XMkNyntdjB7EMhhkSDau/8j2UP1UAPegqP1sU=";
  };

  vendorHash = null;

  buildInputs = [ leveldb geos ];

  ldflags = [
    "-s -w"
    "-X github.com/omniscale/imposm3.Version=${version}"
  ];

  # requires network access
  doCheck = false;

  meta = with lib; {
    description = "Imposm imports OpenStreetMap data into PostGIS";
    inherit (src.meta) homepage;
    license = licenses.apsl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
