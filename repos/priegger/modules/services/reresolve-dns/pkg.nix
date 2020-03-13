{ pkgs, stdenv, buildPackages, fetchFromGitHub, makeWrapper }:

stdenv.mkDerivation rec {
  version = "0.0.20191212";
  name = "reresolve-dns-${version}";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "WireGuard";
    repo = "WireGuard";
    rev = "refs/tags/${version}";
    sha256 = "1vyin3i4nqc4syri49jhjc4qm0qshpvgw7k4d3g5vlyskhdfv5q0";
  };

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 contrib/examples/reresolve-dns/reresolve-dns.sh $out/bin/reresolve-dns
    # pkgs.coreutils pkgs.utillinux pkgs.nettools
    wrapProgram $out/bin/reresolve-dns --prefix PATH : "${pkgs.stdenv.lib.makeBinPath [ pkgs.wireguard-tools ]}"
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/WireGuard/WireGuard/tree/master/contrib/examples/reresolve-dns;
    license = licenses.gpl2;
    description = "update kernel DNS entries for wireguard remote endpoints";
    platforms = platforms.unix;
  };
}
