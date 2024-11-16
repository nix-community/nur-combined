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
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "kazv";
  version = "0.5.0-unstable-2024-11-16";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "kazv";
    fetchSubmodules = true;
    rev = "db800e30cd4e84ab099515ed59177c01977fea4d";
    hash = "sha256-0E6qTxOt3ugXv5kEGE+HOwpUxJsqcabmzN4vJ7BbTF0=";
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

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "A convergent qml/kirigami matrix client based on libkazv";
    homepage = "https://lily-is.land/kazv/kazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
    platforms = platforms.linux;
  };
}
