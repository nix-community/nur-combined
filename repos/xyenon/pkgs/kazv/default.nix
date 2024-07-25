{
  lib,
  stdenv,
  fetchFromGitLab,
  wrapQtAppsHook,
  cmake,
  pkg-config,
  extra-cmake-modules,
  qtbase,
  qtdeclarative,
  qtsvg,
  qtmultimedia,
  kio,
  kirigami,
  kirigami-addons,
  kconfig,
  nlohmann_json,
  libkazv,
  cmark,
  breeze-icons,
  unstableGitUpdater,
}:

stdenv.mkDerivation rec {
  pname = "kazv";
  version = "0.4.0-unstable-2024-07-24";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "12bd8059aae6977304b92207c0c595323ad919e6";
    hash = "sha256-wGrFUJ0Z8aJLx7KQdmSc1m9m3lExFoJIRpzs69fkneA=";
  };

  nativeBuildInputs = [
    wrapQtAppsHook
    cmake
    pkg-config
  ];

  buildInputs = [
    extra-cmake-modules

    qtbase
    qtdeclarative
    qtsvg
    qtmultimedia

    kio
    kirigami
    kirigami-addons
    kconfig

    nlohmann_json
    libkazv
    cmark
  ];

  propagatedBuildInputs = [ breeze-icons ];

  cmakeFlags = [ "-Dkazv_KF_QT_MAJOR_VERSION=6" ];

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "A convergent qml/kirigami matrix client based on libkazv";
    homepage = "https://lily-is.land/kazv/kazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
    platforms = platforms.linux;
  };
}
