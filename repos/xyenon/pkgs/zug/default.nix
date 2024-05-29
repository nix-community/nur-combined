{ lib, stdenv, fetchFromGitHub, cmake, boost, catch2, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "zug";
  version = "0.1.1-unstable-2024-03-26";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "7c22cc138e2a9a61620986d1a7e1e9730123f22b";
    hash = "sha256-/0HnSUmmyX49L6pJk9QlviFF2FYi5o+x++94wwYwWjk=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost catch2 ];

  cmakeFlags = [ "-Dzug_BUILD_TESTS=ON" "-Dzug_BUILD_EXAMPLES=OFF" "-Dzug_BUILD_DOCS=OFF" ];

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    homepage = "https://github.com/arximboldi/zug";
    description = "Transducers for C++ — Clojure style higher order push/pull sequence transformations";
    license = licenses.boost;
    maintainers = with maintainers; [ xyenon ];
  };
}
