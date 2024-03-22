{ lib, stdenv, fetchFromGitHub, cmake, catch2_3, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "immer";
  version = "unstable-2024-03-20";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "d8fd87fc212cadc1d8aa52689e6213c9e57ab28b";
    hash = "sha256-vGxxV72stV5lH6JfTdgYCABRYTsuqfB0RFXUe+Q7VJ0=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ catch2_3 ];

  cmakeFlags = [
    "-Dimmer_BUILD_TESTS=ON"
    "-Dimmer_BUILD_EXAMPLES=OFF"
    "-Dimmer_BUILD_DOCS=OFF"
    "-Dimmer_BUILD_EXTRAS=OFF"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    homepage = "http://sinusoid.es/immer";
    description = "Postmodern immutable and persistent data structures for C++ — value semantics at scale";
    license = licenses.boost;
    maintainers = with maintainers; [ xyenon ];
  };
}
