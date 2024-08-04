{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  catch2_3,
  unstableGitUpdater,
  ...
}:

stdenv.mkDerivation rec {
  pname = "immer";
  version = "0.8.1-unstable-2024-07-25";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "18b42d2e7b6377a3191908d031dcff784a212b9b";
    hash = "sha256-Z0ezcLDGmkXGhC8Y/Tr5ylxyL2f4u9HtI5S2vBP0YcU=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ catch2_3 ];

  cmakeFlags = [
    "-Dimmer_BUILD_TESTS=ON"
    "-Dimmer_BUILD_EXAMPLES=OFF"
    "-Dimmer_BUILD_DOCS=OFF"
    "-Dimmer_BUILD_EXTRAS=OFF"
  ];

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    homepage = "http://sinusoid.es/immer";
    description = "Postmodern immutable and persistent data structures for C++ — value semantics at scale";
    license = licenses.boost;
    maintainers = with maintainers; [ xyenon ];
  };
}
