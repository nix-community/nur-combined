{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "q";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "natesales";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Esg2i8UNT+SuW9+jsnVEOt1ot822CamZ3JoR8ReY0+4=";
  };

  vendorSha256 = "sha256-oarXbxROTd7knHr9GKlrPnnS6ehkps2ZYYsUS9cn6ek=";

  subPackages = [ "." ];

  # network tests
  doCheck = false;

  meta = with lib; {
    description =
      "Tiny command line DNS client with support for UDP, TCP, DoT, DoH, DoQ and ODoH";
    homepage = "https://github.com/natesales/q";
    license = licenses.gpl3;
  };
}
