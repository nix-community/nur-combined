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
  qtimageformats,
  qtwayland,
  qthttpserver,
  kio,
  kirigami,
  kirigami-addons,
  kconfig,
  knotifications,
  boost,
  lager,
  immer,
  zug,
  cryptopp,
  vodozemac-bindings-kazv-unstable,
  nlohmann_json,
  libkazv,
  cmark,
  breeze-icons,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "kazv";
  version = "0.6.0-unstable-2025-10-15";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "kazv";
    fetchSubmodules = true;
    rev = "df06f29d6d857e11a542e2bfc5f33ec5d4f130cb";
    hash = "sha256-5HhC3GSTvubmu+bZ7yFpClJSPXqpDQojdafE4eOTsBY=";
  };

  nativeBuildInputs = [
    wrapQtAppsHook
    cmake
    pkg-config
    extra-cmake-modules
  ];

  buildInputs = [
    qtbase
    qtdeclarative
    qtsvg
    qtmultimedia
    qtimageformats
    qtwayland
    qthttpserver

    kio
    kirigami
    kirigami-addons
    kconfig
    knotifications

    boost
    lager
    immer
    zug
    cryptopp
    vodozemac-bindings-kazv-unstable
    nlohmann_json
    libkazv
    cmark
  ];

  strictDeps = true;

  propagatedBuildInputs = [ breeze-icons ];

  cmakeFlags = [ "-Dkazv_KF_QT_MAJOR_VERSION=6" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Convergent qml/kirigami matrix client based on libkazv";
    homepage = "https://lily-is.land/kazv/kazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
    platforms = platforms.linux;
  };
}
