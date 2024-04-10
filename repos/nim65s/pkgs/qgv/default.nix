{
  stdenv,
  fetchFromGitHub,
  lib,
  cmake,
  graphviz,
  jrl-cmakemodules,
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
    hash = "sha256-NUMCVqXw7euwxm4vISU8qYFfvV5HbAJsj/IjyxEjCPw=";
  };

  buildInputs = [
    qtbase
    qttools
  ];

  nativeBuildInputs = [
    cmake
    jrl-cmakemodules
    wrapQtAppsHook
  ];

  propagatedBuildInputs = [ graphviz ];

  meta = {
    homepage = "https://github.com/gepetto/qgv";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
