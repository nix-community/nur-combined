{ lib, buildGoModule, fetchFromGitHub, libpcap }:

buildGoModule rec {
  pname = "goreplay";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "buger";
    repo = pname;
    rev = "v${version}";
    sha256 = "0smhl6gk91fymryybf1hzihmd0j4ks4yyf2vwihb55xh83mnnn2s";
  };

  buildInputs = [ libpcap ];

  vendorSha256 = null;
  modSha256 = vendorSha256;

  # Requires network.
  doCheck = false;

  postInstall = ''
    mv $out/bin/goreplay $out/bin/gor
  '';

  meta = with lib; {
    description = "Open-source tool for capturing and replaying live HTTP traffic";
    homepage = "https://goreplay.org/";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.gpl3;
  };
}
