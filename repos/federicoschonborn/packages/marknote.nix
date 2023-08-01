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
}:

stdenv.mkDerivation {
  pname = "marknote";
  version = "unstable-2023-07-31";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "office";
    repo = "marknote";
    rev = "5360aadf401de046c74cc68d8c0bfb8910dd0393";
    hash = "sha256-XJNFB0zxWxYKVeo6Ykz13x7SCDOmnGZfzjHnYwkvBDw=";
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
