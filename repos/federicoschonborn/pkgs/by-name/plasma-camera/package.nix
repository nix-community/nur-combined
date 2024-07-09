{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  ninja,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-camera";
  version = "1.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "plasma-camera";
    rev = finalAttrs.version;
    hash = "sha256-PXpYS3hoeOrCCd1FpVoezYwf4eYsaDLRaTYHDqaec0U=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtquickcontrols2
    libsForQt5.kirigami2
  ];

  meta = {
    mainProgram = "plasma-camera";
    description = "Camera application for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/plasma-camera";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
