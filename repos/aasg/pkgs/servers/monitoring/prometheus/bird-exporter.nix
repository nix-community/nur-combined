{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "bird_exporter";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "czerwonk";
    repo = pname;
    rev = version;
    sha256 = "1kgymbk9npw5bdbawm8xvm81b267ag81862favfbnmg3xyl5sh81";
  };
  vendorSha256 = null;

  doCheck = true;

  meta = with lib; {
    description = "Bird protocol state exporter for bird routing daemon to use with Prometheus";
    homepage = "https://github.com/czerwonk/bird_exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.unix;
  };
}
