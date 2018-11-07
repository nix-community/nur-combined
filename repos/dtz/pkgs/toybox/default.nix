{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "toybox-${version}";
  version = "0.7.8";

  src = fetchurl {
    url = "http://landley.net/toybox/downloads/${name}.tar.gz";
    sha256 = "1mlqv5hsvy8ii6m698hq6rc316klwv44jlr034knwg6bk1lf2qj9";
  };

  postPatch = "patchShebangs .";

  configurePhase = "make defconfig";


  doCheck = true;
  checkTarget = "tests";

  installFlags = [ "PREFIX=$(out)/bin" ];
  installTargets = [ "install_flat" ];

  meta = with stdenv.lib; {
    description = "Common linux utilities in a multicall binary";
    homepage = https://landley.net/toybox/;
    license = licenses.bsd2;
    maintainers = with maintainers; [ dtzWill ];
  };
}
