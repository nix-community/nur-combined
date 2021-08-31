{ stdenv, lib, fetchgit
, meson, ninja, pkgconfig
, flatbuffers
, debug ? false
}:

stdenv.mkDerivation rec {
  name = "batprotocol-cpp-${src.rev}";

  src = fetchgit {
    url = "https://framagit.org/batsim/batprotocol.git";
    rev = "58e2b2956f9a3e86d27371eadeeaa13e3739c11a";
    sha256 = "09w8bpmcrqz7wfii63jf2b3bh8ddppq6vqpimd5k0106zsq2wa0h";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];
  propagatedBuildInputs = [ flatbuffers ];
  mesonBuildType = if debug then "debug" else "release";
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
