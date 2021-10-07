# this expression builds uniutils with the latest Unicode data, that is, whatever pkgs.unicode-character-database is at
{ stdenv, lib, fetchurl, unicode-character-database }:
let
versionSuffix = unicode-character-database.version;
in
stdenv.mkDerivation rec {
  pname = "uniutils";
  version = "2.27-" + versionSuffix; 
  src = fetchurl {
    url = "http://billposer.org/Software/Downloads/uniutils-2.27.tar.gz";
    sha256 = "15hmlsfwicdsqniqap0gz7dbv7a7bl9pkxhh0pkalrrsb8hsjqn6";
  };

  preConfigure = ''
    awk -f genunames.awk < ${unicode-character-database}/share/unicode/UnicodeData.txt  > unames.c ;
  '';

  meta = {
    description = "utilities for inspecting unicode text";
    homepage = "http://billposer.org/Software/uniutils.html";
    license = lib.licenses.gpl3;
  };
}
