{ lib
, stdenv
, fetchFromGitLab
, wrapQtAppsHook
, cmake
, pkg-config
, extra-cmake-modules
, qtbase
, qtdeclarative
, qtquickcontrols2
, qtsvg
, qtmultimedia
, kio
, kirigami2
, kconfig
, libkazv
, breeze-icons
, unstableGitUpdater
}:

stdenv.mkDerivation {
  name = "kazv";
  version = "unstable-2023-07-11";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "kazv";
    fetchSubmodules = true;
    rev = "a1eb1138740d58a952f3fd3fb830f5f8022eb6b8";
    hash = "sha256-yBjK7n81OvWdtnjY7vpyGkAk1cvQ7hpU7h4lfJBYOug=";
  };

  nativeBuildInputs = [ wrapQtAppsHook cmake pkg-config ];

  buildInputs = [
    extra-cmake-modules

    qtbase
    qtdeclarative
    qtquickcontrols2
    qtsvg
    qtmultimedia

    kio
    kirigami2
    kconfig

    libkazv
  ];

  propagatedBuildInputs = [ breeze-icons ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "A convergent qml/kirigami matrix client based on libkazv";
    homepage = "https://lily-is.land/kazv/kazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
    platforms = platforms.linux;
  };
}
