{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "transmission-exporter";
  version = "0.1.2";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;

    owner = "pborzenkov";
    repo = "transmission-exporter";
    sha256 = "sha256-2m/F9rvZxae+y4jUzbpa/6bdXsC4mY6r4UkgfKnGFFk=";
  };

  vendorSha256 = "1v308fs554g37vimc214kazqv5fnxdrvd4kjx4mfv6gpgcdfildj";

  ldflags = [
    "-X github.com/prometheus/common/version.Version=${version}"
    "-X github.com/prometheus/common/version.Revision=${rev}"
  ];

  meta = with lib; {
    description = "Prometheus exporter for Transmission torrent client.";
    homepage = "https://github.com/pborzenkov/transmission-exporter";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ pborzenkov ];
  };
}
