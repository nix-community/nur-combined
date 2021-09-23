{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "prometheus-nats-exporter";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = pname;
    rev = "v${version}";
    sha256 = "08p6rkbpzig3g17anmp1qchxjgrwyll4zsxbks3xq11j2k6ssh03";
  };

  vendorSha256 = "0437xwzj10h7hwdx87s9h2vllkvq5c6lv4xgrc5qiqn8vjnymh6l";
  modSha256 = vendorSha256;

  doCheck = false;

  meta = with lib; {
    description = "A Prometheus exporter for NATS metrics";
    homepage = "https://github.com/nats-io/prometheus-nats-exporter";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
