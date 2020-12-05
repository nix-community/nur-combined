{ stdenv, lib, fetchurl, cmake }:

stdenv.mkDerivation rec {

  version = "0.5.3.1";
  pname = "friidump";

  src = fetchurl {
    url = "https://github.com/bradenmcd/${pname}/archive/${version}.tar.gz";
    sha256 = "0zpvlq47mf6rrdhiiswm7kzsakqhqy696v8jbisdqwqa8iwbn3cm";
  };

  buildInputs = [ cmake ];

  meta = {
    description = "A program to dump Nintendo Wii and GameCube disc";
    homepage = "https://github.com/bradenmcd/friidump";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.wamserma ];
  };
}
