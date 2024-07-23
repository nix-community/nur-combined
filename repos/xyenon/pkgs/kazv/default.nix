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
  version = "0.4.0-unstable-2024-07-21";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "31da53994d1513b6a21dfb581f7bc3a9b17d69df";
    hash = "sha256-9bDDZZD8CWjLbDffh2WZfuG8PY19lMWexG0Tol3ZlU4=";
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
