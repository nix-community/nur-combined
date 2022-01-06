{ rustPlatform, fetchFromGitHub, lib }:

rustPlatform.buildRustPackage rec {
  pname = "prometheus-nut-exporter";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "HON95";
    repo = "prometheus-nut-exporter";
    rev = "v${version}";
    sha256 = "153kk9725d3r7177mwcyl8nl0f1dsgn82m728hfybs7d39qa4yqm";
  };

  cargoSha256 = "066s2wp5pqfcqi4hry8xc5a07g42f88vpl2vvgj20dkk6an8in54";

  buildInputs = [ ];

  meta = with lib; {
    description = "A Prometheus exporter for Network UPS Tools (NUT)";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
  };
}
