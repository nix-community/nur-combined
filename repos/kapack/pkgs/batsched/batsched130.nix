{ stdenv, lib, fetchFromGitLab
, cmake
, boost, gmp, rapidjson, intervalset, loguru, redox, cppzmq, zeromq
, debug ? false
}:

stdenv.mkDerivation rec {
  pname = "batsched";
  version = "1.3.0";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "batsim";
    repo = pname;
    rev = "v${version}";
    sha256 = "1k13vk8sl3lfsf0r7jk04bwqihbqb5n2py5yivk20kp41h995jnj";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost gmp rapidjson intervalset loguru redox cppzmq zeromq ];
  cmakeBuildType = if debug then "Debug" else "Release";
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
