{ stdenv, lib, fetchFromGitHub, makeWrapper, pkgconfig, libtool, gcc, glib }:

stdenv.mkDerivation rec {
  name = "conmon-${version}";
  version = "unstable-2018-10-03";
  rev = "605136242787b6c7e1c7c8233b74a14c9097e510";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "conmon";
    sha256 = "1ks9m4hsv0iflcj62szy6s8ifzvdns0hmhx2cz9mhfa9a7796311";
    inherit rev;
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    makeWrapper libtool gcc glib
  ];

  installPhase = ''
    install -D -m 755 bin/conmon $out/bin/conmon
  '';
}
