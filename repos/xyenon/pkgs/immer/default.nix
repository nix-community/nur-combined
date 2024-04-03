{ lib, stdenv, fetchFromGitHub, cmake, catch2_3, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "immer";
  version = "unstable-2024-03-26";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "00cdcbf90a73a367f1ef76a088c80506e01a2c22";
    hash = "sha256-3ByB/tCAXT3IkCqMYEQ2tdIphHOWk4w6rQMitvuxyrw=";
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
