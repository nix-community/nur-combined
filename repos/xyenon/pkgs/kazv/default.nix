{
  lib,
  stdenv,
  fetchFromCodeberg,
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
  vodozemac-bindings-kazv,
  nlohmann_json,
  libkazv,
  cmark,
  qcoro,
  breeze-icons,
  nix-update-script,
}:

stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "kazv";
  version = "0.6.0-unstable-2026-05-10";

  src = fetchFromCodeberg {
    owner = "the-kazv-project";
    repo = "kazv";
    fetchSubmodules = true;
    rev = "1893088383532221c0c318351b73892373cefb83";
    hash = "sha256-iPh8KW/vQL6ikdWoCguq3mF0KE9uJNN3zH8W55iOKj0=";
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
    vodozemac-bindings-kazv
    nlohmann_json
    libkazv
    cmark
    qcoro
  ];

  strictDeps = true;
  enableParallelBuilding = true;

  propagatedBuildInputs = [ breeze-icons ];

  cmakeFlags = [ "-Dkazv_KF_QT_MAJOR_VERSION=6" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--version-regex=^v(.*)$"
    ];
  };

  meta = {
    description = "Convergent qml/kirigami matrix client based on libkazv";
    homepage = "https://lily-is.land/kazv/kazv";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ xyenon ];
    platforms = lib.platforms.linux;
  };
}
