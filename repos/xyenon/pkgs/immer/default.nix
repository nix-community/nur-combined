{ lib, stdenv, fetchFromGitHub, cmake, catch2, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "immer";
  version = "unstable-2024-01-17";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "fe0b6f816d6064f263462938b6ed988e4448248b";
    hash = "sha256-AgEvgrsKzSaADsZf1Ej4JC4Jg8QntC1Y8U2jzTL66rs=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ catch2 ];

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
