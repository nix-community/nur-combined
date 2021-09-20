{ stdenv, lib, fetchgit
, meson, ninja, pkgconfig
, flatbuffers
, debug ? false
}:

stdenv.mkDerivation rec {
  name = "batprotocol-cpp-${src.rev}";

  src = fetchgit {
    url = "https://framagit.org/batsim/batprotocol.git";
    rev = "19b5aa27979b3b41cd2548effc13e2093b35b5fb";
    sha256 = "0mbnf7hz3pc0jk9203zf7ndwfsacvjjn6m2zrph6402y37p2cb7m";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];
  propagatedBuildInputs = [ flatbuffers ];
  mesonBuildType = if debug then "debug" else "release";
  CXXFLAGS = if debug then "-O0" else "";
  ninjaFlags = [ "-v" ];
  dontStrip = debug;

  preConfigure = "cd cpp";

  meta = with lib; {
    description = "C++ library to serialize messages in the batprotocol";
    longDescription = "C++ library to serialize messages in the batprotocol.";
    homepage = https://framagit.org/batsim/batprotocol;
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;
  };
}
