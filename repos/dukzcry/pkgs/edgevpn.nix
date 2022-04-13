{ lib, stdenv, buildGo117Module, fetchFromGitHub, fetchpatch }:

buildGo117Module rec {
  pname = "edgevpn";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "0sx04hra2iwrvbkac5sb0ymc06xqd0pf9ps7vip1qa6nqs38wzfm";
  };

  vendorSha256 = "1cmn4gcgj4mmx5hbwdn1y5ph62s99wmqdwvs2xdg3sbmkjrs5mnw";

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
