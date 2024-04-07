{
  stdenv,
  fetchFromGitHub,
  lib,
  cmake,
  graphviz,
  qtbase,
  qttools,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qgv";
  version = "1.3.5";

  src = fetchFromGitHub {
    owner = "gepetto";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-V9OfdjArTZMOxwYJw7ohPOGuKX1yqb3bGifrlzEMO1I=";
  };

  buildInputs = [
    qtbase
    qttools
  ];

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  propagatedBuildInputs = [ graphviz ];

  meta = {
    homepage = "https://github.com/gepetto/qgv";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
