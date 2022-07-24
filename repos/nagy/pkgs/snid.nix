{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "snid";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "AGWA";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-B1j3cR0ahBUJBgK9MYbl6pg35RZg0/BMwBGWJj1krwQ=";
  };

  vendorSha256 = "sha256-2sJPMN4cKQOhFV/b73a7bd6BZQc5MfIFfItk8FanD0A=";

  meta = with lib; {
    description = "Zero config SNI proxy server";
    homepage = "https://github.com/AGWA/snid";
    license = licenses.mit;
  };
}
