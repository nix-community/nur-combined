{ stdenv, fetchFromGitHub, pkgconfig, ... }:

stdenv.mkDerivation rec {
  pname = "libpd";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "libpd";
    repo = pname;
    rev = version;
    sha256 = "sha256-04pSzNGum65Y+IXG6THroWXEAIwVXs7hGTY5H1MLj60=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [];

  buildPhase = ''
    make libpd

    mkdir $out
    cp libs/libpd.so $out/
  '';

  dontInstall = true;

  meta = with stdenv.lib; {
    description = "Pure Data embeddable audio synthesis library";
    homepage = "https://github.com/libpd/libpd";
    license = licenses.bsd3;
    platforms = with platforms; linux;
  };
}
