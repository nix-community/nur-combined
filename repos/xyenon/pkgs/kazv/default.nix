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

stdenv.mkDerivation rec {
  pname = "kazv";
  version = "unstable-2023-10-04";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "f210c22503b86777305803d98a260025e215bdca";
    hash = "sha256-cL/adrx9n4xqNerwr8NNDm3KDV+HeBJKEPx48kPSDfU=";
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
