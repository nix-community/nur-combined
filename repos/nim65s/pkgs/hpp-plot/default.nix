{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gepetto-viewer-corba,
  hpp-manipulation-corba,
  pkg-config,
  python3Packages,
  libsForQt5,
}:
let
  python = python3Packages.python.withPackages (ps: [ ps.boost ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-plot";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-plot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LMJpXyw5QvhrC8xwKBHpeZyUSEUnUhCE1uTDXRBnNqI=";
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
    gepetto-viewer-corba
    hpp-manipulation-corba
  ];

  doCheck = true;

  meta = {
    description = "Graphical utilities for constraint graphs in hpp-manipulation";
    homepage = "https://github.com/humanoid-path-planner/hpp-plot";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
