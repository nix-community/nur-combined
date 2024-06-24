{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-gepetto-viewer,
  hpp-gui,
  hpp-plot,
  pkg-config,
  python3Packages,
  libsForQt5,
}:
let
  python = python3Packages.python.withPackages (ps: [ ps.boost ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-practicals";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-practicals";
    rev = "v${finalAttrs.version}";
    hash = "sha256-616/bmDyv7j17u2aBCKa0cXkWIPdGESQaFJg/89V0ZM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
    pkg-config
  ];
  buildInputs = [
    libsForQt5.qtbase
    python
  ];
  propagatedBuildInputs = [
    hpp-gepetto-viewer
    hpp-gui
    hpp-plot
  ];

  doCheck = true;

  meta = {
    description = "Practicals for Humanoid Path Planner software";
    homepage = "https://github.com/humanoid-path-planner/hpp-practicals";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
