{ stdenv, lib, fetchgit
, meson, ninja, pkgconfig
, flatbuffers
, debug ? false
}:

stdenv.mkDerivation rec {
  name = "batprotocol-cpp-${src.rev}";

  src = fetchgit {
    url = "https://framagit.org/batsim/batprotocol.git";
    rev = "baff452b365d471fc7316e1f5ab5ed6a9b5de460";
    sha256 = "0n566w68y11m1s82wq1wf9fgyx5q7xri9nmgn6xr75hr9kpafawr";
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
