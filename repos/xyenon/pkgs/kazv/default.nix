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
  version = "0.2.0-unstable-2024-05-29";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "4dcc5526cef13e2ee23213c55325a8aa3eed51c9";
    hash = "sha256-r38hdBLbb8uXU2631XWeU71i+bRA4Y2jTeqYMwtQiy4=";
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
