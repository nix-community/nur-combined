{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, boost, immer-unstable, zug-unstable, catch2, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "lager";
  version = "unstable-2023-11-22";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "53dfad020a177b33d375e9b294a5e924edd8a82a";
    hash = "sha256-uvIAQ0nipxnfVUIig4LIER96GltaSPGiGsssc8DWB78=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ boost immer-unstable zug-unstable catch2 ];

  cmakeFlags = [ "-Dlager_BUILD_TESTS=ON" "-Dlager_BUILD_EXAMPLES=OFF" "-Dlager_BUILD_DOCS=OFF" ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/arximboldi/lager";
    description = "C++ library for value-oriented design using the unidirectional data-flow architecture — Redux for C++";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
