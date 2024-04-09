{
  stdenv,
  fetchFromGitHub,
  lib,
  boost,
  cmake,
  doxygen,
  openscenegraph,
  osgqt,
  pkg-config,
  python3Packages,
  qgv,
  qtbase,
  wrapQtAppsHook,
  python-qt,
}:
let
  python = python3Packages.python.withPackages (ps: [ ps.boost ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gepetto-viewer";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "gepetto";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-x+32/jywFq2A5lF7bDhh/9SoaIZeCUkYknug18qEN6Y=";
  };

  outputs = [
    "out"
    "doc"
  ];

  buildInputs = [
    boost
    python-qt
    qtbase
    osgqt
    python
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    wrapQtAppsHook
    pkg-config
  ];

  propagatedBuildInputs = [
    openscenegraph
    osgqt
    qgv
  ];

  doCheck = true;

  meta = {
    homepage = "https://github.com/gepetto/gepetto-viewer";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.nim65s ];
    mainProgram = "gepetto-gui";
  };
})
