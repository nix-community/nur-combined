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
  pname = "hpp-gui";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-gui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TjOhR78rsfvaBx8hkJ8l6zdptI8ZZ9z8FkhisnwiFX4=";
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
    description = "Qt based GUI for HPP project";
    homepage = "https://github.com/humanoid-path-planner/hpp-gui";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
