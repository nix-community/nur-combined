{ stdenv, lib, fetchurl, unzip }:

stdenv.mkDerivation rec {
  name = "TestU01-1.2.3";
  src = fetchurl {
    url = "http://simul.iro.umontreal.ca/testu01/TestU01.zip";
    sha256 = "1b0wxp9c1ha3yvj8zv3swqfg24srwn72rbga50ykpvd7mv91s7dw";
  };
  nativeBuildInputs = [ unzip ];
  hardeningDisable = [ "format" ];
  buildInputs = [ ];
  configureFlags = [ ];

  meta = with lib; {
    broken = true;
    description = "Empirical Statistical Testing of Uniform Random Number Generators";
    license = licenses.gpl3;
    homepage = http://simul.iro.umontreal.ca/testu01/tu01.html;
    maintainers = [ maintainers.idontgetoutmuch ];
  };
}
