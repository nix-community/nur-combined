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
  python3,
  qgv,
  qtbase,
  wrapQtAppsHook,
  python-qt,
}:
let
  python = python3.withPackages (pkgs: [ pkgs.boost ]);
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
    "dev"
    "out"
    "doc"
  ];

  buildInputs = [
    boost
    python-qt
    qtbase
    osgqt
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
    python
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
