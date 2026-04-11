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
  vodozemac-bindings-kazv,
  nlohmann_json,
  libkazv,
  cmark,
  qcoro,
  breeze-icons,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "kazv";
  version = "0.6.0-unstable-2026-04-09";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "the-kazv-project";
    repo = "kazv";
    fetchSubmodules = true;
    rev = "963205c17c4fc32315151726ce79aaafb6d7e9e1";
    hash = "sha256-U8wGS6eDMEMXJ+qJhG/d2ubySn4FE0thReiVp7jwd+M=";
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
