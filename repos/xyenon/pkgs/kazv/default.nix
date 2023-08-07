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
  version = "unstable-2023-07-29";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "93f5590d151075a336b79157fcee73ac39a1b454";
    hash = "sha256-4FBiqfTRlMOuykKsTOu/tdSN5oQAintG/m1tj/PRBbk=";
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
