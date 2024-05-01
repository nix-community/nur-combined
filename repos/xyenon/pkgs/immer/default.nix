{ lib, stdenv, fetchFromGitHub, cmake, catch2_3, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "immer";
  version = "unstable-2024-05-01";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "bd9f3188c74de1899b28d1b2ff952558a92f9a16";
    hash = "sha256-V6CMikyDeDL0yb3QdHbzom5QSE2IknmgoypwmkMfrSA=";
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
