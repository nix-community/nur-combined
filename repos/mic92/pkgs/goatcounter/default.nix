{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "goatcounter";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "zgoat";
    repo = "goatcounter";
    rev = "v${version}";
    sha256 = "sha256-MF4ipSZfN5tAphe+gde7SPAypyi1uRyaDBv58u3lEQE=";
  };

  subPackages = [ "cmd/goatcounter" ];

  ldflags = ["-X=main.Version=${version}"];

  doCheck = false;

  vendorHash = "sha256-cwR3wCRbvISKyhHCnIYDIGSZ+1DowfGT4RAkF/d6F5Q=";

  meta = with lib; {
    description = "Easy web analytics. No tracking of personal data.";
    homepage = "https://www.goatcounter.com/";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
