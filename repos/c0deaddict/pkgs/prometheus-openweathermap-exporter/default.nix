{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "prometheus-openweathermap-exporter";
  version = "0ad2d408fc1adb012cb9098f061c14a6a14ffb1e";

  src = fetchFromGitHub {
    owner = "c0deaddict";
    repo = "openweather-exporter";
    rev = version;
    sha256 = "sha256-vUaYRSYiJqP+zonNO1dt3/XvAlW3l8phtMClTPjkygI=";
  };

  vendorSha256 = "sha256-M0a7SSgfFcSM8oyptOrciLtUdo/l31JIIlAO7T7snWI=";
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
