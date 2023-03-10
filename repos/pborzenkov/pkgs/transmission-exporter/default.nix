{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "transmission-exporter";
  version = "0.2.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;

    owner = "pborzenkov";
    repo = "transmission-exporter";
    sha256 = "sha256-kx7pb1XpKRpX58hMYTXu/NXBoYrnZF1wcHMt1stkcog=";
  };

  vendorSha256 = "sha256-stHoGnv3me0q6XKStnPr1pWNv5okCFbjPuORUrRDYOw=";

  ldflags = [
    "-X github.com/prometheus/common/version.Version=${version}"
    "-X github.com/prometheus/common/version.Revision=${rev}"
  ];

  meta = with lib; {
    description = "Prometheus exporter for Transmission torrent client.";
    homepage = "https://github.com/pborzenkov/transmission-exporter";
    license = with licenses; [mit];
    maintainers = with maintainers; [pborzenkov];
  };
}
