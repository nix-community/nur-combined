{ stdenv, cmake, pkgconfig, libogg, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "opustags";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "fmang";
    repo = "opustags";
    rev = version;
    sha256 = "09z0cdg20algaj2yyhfz3hxh1biwjjvzx1pc2vdc64n8lkswqsc1";
  };

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
  ];

  buildInputs = [ libogg ];

  nativeBuildInputs = [ cmake pkgconfig ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/fmang/opustags";
    description = "Ogg Opus tags editor";
    platforms = platforms.all;
  };
}
