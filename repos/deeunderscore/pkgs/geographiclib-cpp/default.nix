{ stdenv, lib, fetchurl, cmake }:

stdenv.mkDerivation rec {
  pname = "geographiclib-cpp";
  version = "2.0-alpha";

  src = fetchurl {
    url = "mirror://sourceforge/project/geographiclib/distrib-C%2B%2B/GeographicLib-${version}.tar.gz";
    sha256 = "sha256-VffBVKoW1T3AzAYee+UXPZ09EL7Z9MCvfvSPWs2xFvM=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "Library for solving geodesic problems";
    homepage = "https://geographiclib.sourceforge.io/";
    license = licenses.mit;
  };

}
