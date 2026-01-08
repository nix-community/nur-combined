{
  lib,
  stdenv,
  fetchFromGitea,
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
  version = "0.6.0-unstable-2026-01-08";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "the-kazv-project";
    repo = "kazv";
    fetchSubmodules = true;
    rev = "b3296879bc3c85195dad3de5f7c87221e5dbd68d";
    hash = "sha256-IB8Z23SQGOaQRsdZowgJ4UURRKHFgVFdDk/sBz4fYk4=";
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
