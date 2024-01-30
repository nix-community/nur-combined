{ lib, stdenv, fetchFromGitHub, cmake, boost, catch2, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "zug";
  version = "unstable-2023-10-15";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "4e8617e6baf7d277b54354abade5703363140792";
    hash = "sha256-Ti0EurhGQgWSXzSOlH9/Zsp6kQ/+qGjWbfHGTPpfehs=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost catch2 ];

  cmakeFlags = [ "-Dzug_BUILD_TESTS=ON" "-Dzug_BUILD_EXAMPLES=OFF" "-Dzug_BUILD_DOCS=OFF" ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/arximboldi/zug";
    description = "Transducers for C++ — Clojure style higher order push/pull sequence transformations";
    license = licenses.boost;
    maintainers = with maintainers; [ xyenon ];
  };
}
