{ stdenv, fetchurl, perl, texinfo, pkgconfig, netpbm, psutils, ghostscript }:

stdenv.mkDerivation {
  pname = "groff";
  version = "1.22.4";

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/groff/groff-1.22.4.tar.gz";
    sha256 = "14q2mldnr1vx0l9lqp9v2f6iww24gj28iyh4j2211hyynx67p3p7";
  };

  buildInputs = [ perl texinfo ];

  configurePhase = ''
    ./configure --prefix=$out
  '';
}
