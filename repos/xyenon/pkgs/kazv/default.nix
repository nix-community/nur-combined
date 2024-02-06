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
  version = "unstable-2024-01-28";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "dcd61c17bc6a6bb578cf40e813f9fa6aea6c78d0";
    hash = "sha256-aj6Q25R4OdZ88751B1H9c1IMLIKaLNB5tDMayuk+HOw=";
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
