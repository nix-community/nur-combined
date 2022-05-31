{ lib, stdenv, buildGoModule, fetchFromGitHub, fetchpatch }:

buildGoModule rec {
  pname = "edgevpn";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-IlAj0QW1idTu5E8TAV7zpcaVTfYp5YY9sTF2muQq7gg=";
  };

  vendorSha256 = "sha256-wIZPY5igqWZKjSCpyUfL9BKv7rx6PQEmiaWJBb+sHUE=";

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
