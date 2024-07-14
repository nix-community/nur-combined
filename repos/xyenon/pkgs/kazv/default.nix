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
  version = "0.4.0-unstable-2024-07-13";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "3e0332d17334d240b43657481eeb05f2441b0f8b";
    hash = "sha256-Y2Hr99zwEc1J2LJJqol3fX6+9VnixGaxQuT0PS9NzxA=";
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
