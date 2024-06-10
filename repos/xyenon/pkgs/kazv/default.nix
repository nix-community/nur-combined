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
, nlohmann_json
, libkazv
, cmark
, breeze-icons
, unstableGitUpdater
}:

stdenv.mkDerivation rec {
  pname = "kazv";
  version = "0.3.0-unstable-2024-06-09";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "f11c4872a0144ba09f53f6232332432a39651bd1";
    hash = "sha256-yAkjxNZ7jFVu81igxgYRhME7jntEBLjcsB7rPJsim+c=";
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

    nlohmann_json
    libkazv
    cmark
  ];

  propagatedBuildInputs = [ breeze-icons ];

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "A convergent qml/kirigami matrix client based on libkazv";
    homepage = "https://lily-is.land/kazv/kazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
    platforms = platforms.linux;
  };
}
