{ lib, stdenv, buildGo117Module, fetchFromGitHub }:

buildGo117Module rec {
  pname = "edgevpn";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "13phcbppl8ca3lsmywhlwr54r35hb7dlb5h6vnxanac114l7f8vf";
  };

  vendorSha256 = "17z9mgh0h99wxx5fc2nji6zjygz3nmqv9ggjam2f4wmhll10x4pb";

  preBuild = ''
    substituteInPlace internal/version.go \
      --replace 'Version = ""' 'Version = "${src.rev}"'
  '';

  doCheck = false;

  meta = with lib; {
    description = "The immutable, decentralized, statically built VPN without any central server";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
