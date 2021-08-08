{ stdenv, fetchurl, perl, perlPackages }:

let

  perl' = perl.withPackages (p:
    [ p.IOSocketSSL p.XMLRSS p.URI p.DateTimeFormatStrptime p.HTTPDaemon ]);

in

stdenv.mkDerivation rec {
  name = "Atlas";
  version = "1.0";

  src = fetchurl {
  	url = "https://github.com/heph2/atlas/releases/download/v1.0/atlas-1.0.tar.gz";
	  sha256 = "1hzladzchnbszyvfp3h1qddgnq30cslsrz55ljw0dc404fsszf6h";
  };
 
  buildInputs = [ perl' ];
  
  installPhase = ''
    perl Makefile.PL PREFIX=$out
    make
    make install
    '';
}
