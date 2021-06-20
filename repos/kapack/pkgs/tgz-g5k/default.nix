{ stdenv, lib, pkgs, fetchurl }:

stdenv.mkDerivation rec {
  name = "tgz-g5k-${version}";
  version = "1.0.11";
  
  src = fetchurl {
    url = "https://www.grid5000.fr/packages/debian/tgz-g5k_${version}.tar.gz";
    sha256 = "0m5d2c85v2falg53d25mggqm56azpmi7s959g45764n1fnyw6731";
  };
  
  buildInputs = [pkgs.libxslt.bin pkgs.docbook_xsl];
    
  phases = "unpackPhase buildPhase installPhase";
  buildPhase = ''
    substituteInPlace VERSION --replace "1.0.9" "${version}"
    substituteInPlace tgz-g5k.in --replace "/bin/bash" "${pkgs.bash}/bin/bash"
    substituteInPlace Makefile --replace "chown" "true"
    substituteInPlace Makefile --replace "chmod" "true"

    make clean
    make DB2MAN=${pkgs.docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl DISTRIB=generic SHAREDIR=$out/share dismissed insipid tgz-g5k tgz-g5k.8
  '';
  installPhase = ''
    mkdir -p $out/share/man
    mkdir -p $out/bin
    export DISTRIB=generic 
    export SHAREDIR=$out/share 
    export BINDIR=$out/bin 
    export MANDIR=$out/share/man
    export NAME=tgz-g5k
	  install    -m 0755 $NAME $BINDIR/$NAME
	  install    -m 0644 dismissed $SHAREDIR
	  cp -a insipid $SHAREDIR
	  install    -m 0644 "$NAME".8 $MANDIR
  '';

  meta =  with lib; {
    description = "A tool to create neutral deployment tgz image for Grid'5000";
    homepage = https://www.grid5000.fr/mediawiki/index.php/TGZ-G5K;
    license = licenses.lgpl2;
  };
}

