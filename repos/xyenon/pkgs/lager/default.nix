{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, boost, immer-unstable, zug-unstable, catch2, unstableGitUpdater, ... }:

stdenv.mkDerivation rec {
  pname = "lager";
  version = "unstable-2024-02-21";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "f17194a98bad82f546aa1e894c11cf65b98ff43d";
    hash = "sha256-6VMltltZj105x7V8/SfJTEowOt0U5XuPaEoVHntLhfk=";
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
