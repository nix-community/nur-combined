{ stdenv, fetchurl, perl }:

stdenv.mkDerivation rec{
  version = "2.1.1";
  name = "hello-${version}"; 
  builder = ./builder.sh; 
  src = fetchurl {
    url = "ftp://ftp.nluug.nl/pub/gnu/hello/hello-${version}.tar.gz";
    sha256 = "1md7jsfd8pa45z73bz1kszpp01yw6x5ljkjk2hx7wl800any6465";
  };
  inherit perl;
}