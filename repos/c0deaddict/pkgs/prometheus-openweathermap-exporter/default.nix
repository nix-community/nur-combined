{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "prometheus-openweathermap-exporter";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "billykwooten";
    repo = "openweather-exporter";
    rev = "v${version}";
    sha256 = "sha256-FxxUBEh9HY3fzsSU/uT7hiGwfLPcp7rvnbYedLv975w=";
  };

  vendorSha256 = "sha256-Iq3fqFfCrRtLSjTAYIaF4WaxcCmev1p7xjaAw4LMzT4=";
  modSha256 = vendorSha256;

  doCheck = false;

  postInstall = ''
    mv $out/bin/openweather-exporter $out/bin/prometheus-openweathermap-exporter
  '';

  meta = with lib; {
    description = "Prometheus exporter utilizing Openweather API to gather weather metrics";
    homepage = "https://github.com/billykwooten/openweather-exporter";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
