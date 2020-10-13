{ stdenv, fetchFromGitHub, cmake, pkgconfig, tinyxml2 }:

stdenv.mkDerivation rec {
  pname = "mkpsxiso";
  version = "1.23";

  src = fetchFromGitHub {
    owner = "Lameguy64";
    repo = "mkpsxiso";
    rev = "v${version}";
    sha256 = "11znd7f6kqn03mgr2nnkhlxhgcncyy54dw91jmya9b34lc9fx84c";
  };

  #prePatch = ''
  #  substituteInPlace CMakeLists.txt --replace "REQUIRED tinyxml2" "REQUIRED tinyxml"
  #  substituteInPlace ./src/main.cpp --replace "tinyxml2" "tinyxml"
  #  substituteInPlace ./src/iso.h --replace "tinyxml2" "tinyxml"
  #'';

  buildInputs = [ tinyxml2 ];
  nativeBuildInputs = [ cmake pkgconfig ];
  #cmakeFlags = [
  #  "-DTINYXML_INCLUDE_DIR=${tinyxml}/include"
  #  "-DTINYXML_LIBRARIES=${tinyxml}/lib"
  #];

  meta = with stdenv.lib; {
    homepage = https://github.com/Lameguy64/mkpsxiso;
    description = "ISO Image Maker Made Specifically for PlayStation Homebrew Development ";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.genesis ];
    broken = true;
  };
}
