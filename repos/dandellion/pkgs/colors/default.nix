{ fetchgit, stdenv, libpng }:

stdenv.mkDerivation {
  pname = "colors-latest";
  version = "2018-04-15";

  buildInputs = [ libpng ];

  src = fetchgit {
    url = "git://git.2f30.org/colors.git";
    rev = "8edb1839c1d2a62fbd1d4447f802997896c2b0c0";
    sha256 = "13dx6fq9m0imish8293j3wqi3ra0pahg4c2pcs3224bjcar2k0gc";
  };

  installPhase = ''
    mkdir $out
    make DESTDIR=$out PREFIX="" MANPREFIX="/share/man/" install
  '';

}
