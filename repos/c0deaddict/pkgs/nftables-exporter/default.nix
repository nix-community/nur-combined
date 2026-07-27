{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  name = "nftables-exporter";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "metal-stack";
    repo = "nftables-exporter";
    rev = "v${version}";
    hash = "sha256-t0fC7Gso8+k3jLP3YbpZk2rCQgTXfJ/S/SFr2+Kiz7k=";
  };

  vendorHash = "sha256-8QooGMczKUN7DjJQe5/szEYE+p0qqKqPIrVyapg/sYE=";

  meta = with lib; {
    homepage = "https://github.com/metal-stack/nftables-exporter";
    description = "Prometheus exporter for nftables metrics";
    license = licenses.gpl3;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
