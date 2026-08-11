{ stdenv, fetchurl, perl, lib, moarvm }:

stdenv.mkDerivation rec {
  pname = "nqp";
  version = "2019.11";

  src = fetchurl {
    url    = "https://github.com/perl6/nqp/releases/download/${version}/nqp-${version}.tar.gz";
    sha256 = "0a0k91gq6ry52wr4qrlhq4kbf8yzwn3aqydh878dxbwaxwfr2zxl";
  };

  buildInputs = [ perl ];

  configureScript = "${perl}/bin/perl ./Configure.pl";
  configureFlags = [
    "--backends=moar"
    "--with-moar=${moarvm}/bin/moar"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Not Quite Perl -- a lightweight Raku-like environment for virtual machines";
    homepage    = "https://github.com/perl6/nqp";
    license     = licenses.artistic2;
    platforms   = platforms.unix;
  };
}
