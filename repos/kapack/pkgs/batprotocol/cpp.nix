{ stdenv, lib, fetchgit
, meson, ninja, pkgconfig
, flatbuffers
, debug ? false
}:

stdenv.mkDerivation rec {
  name = "batprotocol-cpp-${src.rev}";

  src = fetchgit {
    url = "https://framagit.org/batsim/batprotocol.git";
    rev = "1100c5ff784fe9792aeb8bec0e4367695c94a19c";
    sha256 = "14w5c6r8q57gffpwj2m1npdj1c3w1mhp5wzdqb4jqm1r98d6vmk4";
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
