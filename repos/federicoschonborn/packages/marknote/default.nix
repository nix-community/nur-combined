{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, wrapQtAppsHook
, kirigami2
, ki18n
, kconfig
, kcoreaddons
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "marknote";
  version = "unstable-2023-08-02";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "office";
    repo = "marknote";
    rev = "eca72aa5e8ba2572e611c338575b9ac4083878b5";
    hash = "sha256-5VO/HLOELSbSg1WdXmFPX53SC+lWKwO87m3DpLMAzNs=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtquickcontrols2
    kirigami2
    ki18n
    kconfig
    kcoreaddons
  ];

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = with lib; {
    description = "A simple markdown note management app";
    homepage = "https://invent.kde.org/office/marknote";
    license = with licenses; [
      bsd3
      cc-by-sa-40
      cc0
      gpl2Only
      gpl2Plus
      gpl3Only
      gpl3Plus
      lgpl2Plus
      lgpl3Only
    ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
