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
  version = "0.6.0-unstable-2026-07-19";

  src = fetchFromCodeberg {
    owner = "the-kazv-project";
    repo = "kazv";
    fetchSubmodules = true;
    rev = "5841a77b921a9a27e8115b19da524d0c9bdea692";
    hash = "sha256-NIooLekgIeI1IRwTIGSIGxKTN6p8uaWSoR/JRkC7FlI=";
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
