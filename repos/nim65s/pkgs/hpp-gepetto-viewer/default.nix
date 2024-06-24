{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gepetto-viewer-corba,
  hpp-corbaserver,
  libsForQt5,
  pkg-config,
  python3Packages,
}:
let
  python = python3Packages.python.withPackages (ps: [ ps.boost ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-gepetto-viewer";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-gepetto-viewer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-svP7/++gkw7Lw/Yj91rcc/54L0NULynCBj7YhYhZCCM=";
  };

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
    pkg-config
  ];
  buildInputs = [
    python
    libsForQt5.qtbase
  ];
  propagatedBuildInputs = [
    gepetto-viewer-corba
    hpp-corbaserver
  ];

  meta = {
    description = "Display of hpp robots and obstacles in gepetto-viewer";
    homepage = "https://github.com/humanoid-path-planner/hpp-gepetto-viewer";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
