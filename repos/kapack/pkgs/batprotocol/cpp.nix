{ stdenv, lib, fetchgit
, meson, ninja, pkgconfig
, flatbuffers
, debug ? false
}:

stdenv.mkDerivation rec {
  name = "batprotocol-cpp-${src.rev}";

  src = fetchgit {
    url = "https://framagit.org/batsim/batprotocol.git";
    rev = "9e4a432f34b0222a41473a564f4bf8d80cc3fd16";
    sha256 = "156c2p0s98z3bs2sj21jps3923cxfr5z6rdg818v6smhcvyl0lvx";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];
  propagatedBuildInputs = [ flatbuffers ];

  preConfigure = "cd cpp";
  ninjaFlags = [ "-v" ];

  mesonBuildType = if debug then "debug" else "release";
  CXXFLAGS = if debug then "-O0" else "";
  hardeningDisable = if debug then [ "fortify" ] else [];
  dontStrip = debug;

  meta = with lib; {
    description = "C++ library to serialize messages in the batprotocol";
    longDescription = "C++ library to serialize messages in the batprotocol.";
    homepage = https://framagit.org/batsim/batprotocol;
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;
  };
}
