{ pkgs, lib, stdenv, libX11 }:

stdenv.mkDerivation rec {
  pname = "xqp";
  version = "0.1";

  src = pkgs.fetchgit {
    url = "https://github.com/baskerville/xqp";
    sha256="sha256-1lWVLeRukD1d+XhQBOz3ZA0BMPnyp+tAhpAj0KMo6J0=";
  };

  buildInputs = [ libX11 ];

  postPatch = "sed -i \"s:/usr/local:$out:\" Makefile";

  meta = with lib; {
    description = "X Query pointer";
    homepage = "https://github.com/baskerville/xqp";
    platforms = platforms.all;
  };
}


