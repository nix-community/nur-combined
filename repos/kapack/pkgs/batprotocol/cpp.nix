{ stdenv, lib, fetchgit
, meson, ninja, pkgconfig
, flatbuffers
, debug ? false
}:

stdenv.mkDerivation rec {
  name = "batprotocol-cpp-${src.rev}";

  src = fetchgit {
    url = "https://framagit.org/batsim/batprotocol.git";
    rev = "03b11f45505d25f253e3b0a3dbf7438584cf436a";
    sha256 = "18jihzs247pw3kir4q78z9byhm23hp7ik8ccaz7s9wq571703da8";
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
