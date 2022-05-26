{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "unbound_exporter";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "letsencrypt";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-CR3ogt8jiGysneM+nIFavn6vIu3SeVd8ywnq/wntTAk=";
  };

  vendorSha256 = "sha256-3MpdH55Qs78Yqfev2MlfNC+wX2Xbi9Orn96awOAlRDg=";
  modSha256 = vendorSha256;

  meta = with lib; {
    description = "Prometheus exporter for Unbound";
    homepage = "https://github.com/letsencrypt/unbound_exporter";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
