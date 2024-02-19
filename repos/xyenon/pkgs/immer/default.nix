{ lib, stdenv, fetchFromGitHub, cmake, catch2_3, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "immer";
  version = "unstable-2024-02-15";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "57a8c5ede6f36a8ef9c6e3c82ac6c81f1e5273fd";
    hash = "sha256-D6QiTeOoBUJScQQl/e1jq4n+ORTzYnKg7LKTP6xacM4=";
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
