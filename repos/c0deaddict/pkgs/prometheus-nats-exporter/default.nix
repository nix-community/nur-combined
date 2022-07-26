{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "prometheus-nats-exporter";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-2+nkWwa5n7DyVitnJ8gt7b72Y6XiiLM7ddTM2Cp9/LQ=";
  };

  vendorSha256 = "sha256-bsk6htRnb4NiaJXTHNjPGN9NEy8owRJujancK3nVIsA=";
  modSha256 = vendorSha256;

  doCheck = false;

  meta = with lib; {
    description = "A Prometheus exporter for NATS metrics";
    homepage = "https://github.com/nats-io/prometheus-nats-exporter";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
