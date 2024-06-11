{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  boost,
  immer-unstable,
  zug-unstable,
  catch2,
  unstableGitUpdater,
  ...
}:

stdenv.mkDerivation rec {
  pname = "lager";
  version = "0.1.1-unstable-2024-03-26";

  src = fetchFromGitHub {
    owner = "arximboldi";
    repo = pname;
    rev = "503ea6accc0ce6af683a207a9a02de4a9bf0bedc";
    hash = "sha256-vnLXGLPB55/znNNW2FAsIzi0i8G62t7Dyz3NkrghJNY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    boost
    immer-unstable
    zug-unstable
    catch2
  ];

  cmakeFlags = [
    "-Dlager_BUILD_TESTS=ON"
    "-Dlager_BUILD_EXAMPLES=OFF"
    "-Dlager_BUILD_DOCS=OFF"
  ];

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    homepage = "https://github.com/arximboldi/lager";
    description = "C++ library for value-oriented design using the unidirectional data-flow architecture — Redux for C++";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
