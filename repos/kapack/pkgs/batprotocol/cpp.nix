{ stdenv, lib, fetchgit
, meson, ninja, pkgconfig
, flatbuffers
, debug ? false
}:

stdenv.mkDerivation rec {
  name = "batprotocol-cpp-${src.rev}";

  src = fetchgit {
    url = "https://framagit.org/batsim/batprotocol.git";
    rev = "ac766dbba26c34031aceb0e5aacedd08605fc9dd";
    sha256 = "1rhg1az13bw1v39aba0dv2lq455d1zzhxs63cc70m9fsdl4pgz43";
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
