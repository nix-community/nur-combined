{ stdenv, lib, fetchFromGitLab
, meson, ninja, pkgconfig
, boost, gmp, rapidjson, intervalset, loguru, redox, cppzmq, zeromq
, debug ? false
}:

stdenv.mkDerivation rec {
  pname = "batsched";
  version = "1.4.0";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "batsim";
    repo = pname;
    rev = "v${version}";
    sha256 = "1dmx2zk25y24z3m92bsfndvvgmdg4wy2iildjmwr3drmw15s75q0";
  };

  # Temporary hack. Meson is no longer able to pick up Boost automatically.
  # https://github.com/NixOS/nixpkgs/issues/86131
  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  nativeBuildInputs = [ meson ninja pkgconfig ];
  buildInputs = [ boost gmp rapidjson intervalset loguru redox cppzmq zeromq ];

  ninjaFlags = [ "-v" ];

  mesonBuildType = if debug then "debug" else "release";
  CXXFLAGS = if debug then "-O0" else "";
  hardeningDisable = if debug then [ "fortify" ] else [];
  dontStrip = debug;

  meta = with lib; {
    description = "Batsim C++ scheduling algorithms.";
    longDescription = "A set of scheduling algorithms for Batsim (and WRENCH).";
    homepage = "https://gitlab.inria.fr/batsim/batsched";
    platforms = platforms.all;
    license = licenses.free;
    broken = false;
  };
}
