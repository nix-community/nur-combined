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
  version = "0.5.0-unstable-2024-08-05";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = pname;
    fetchSubmodules = true;
    rev = "17ba2aec72e23b7bc921f30a578db29bc12dcb01";
    hash = "sha256-3bQq7pdBxlg62AmG8h6bXsLGcSVQD1y6DD8fzucQ1oQ=";
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
