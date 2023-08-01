{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, wrapQtAppsHook
, kdbusaddons
, kitemmodels
, kirigami2
, kirigami-addons
, kcoreaddons
, kconfig
, ki18n
}:

stdenv.mkDerivation {
  pname = "licentia";
  version = "unstable-2023-07-31";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "licentia";
    rev = "8744512cbc984ea342e9a70997d970e530ffa156";
    hash = "sha256-eA7du+YnYL7enWNkLKpgw5YBAioL2S5DOsSxSKzaggw=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtquickcontrols2
    kdbusaddons
    kitemmodels
    kirigami2
    kirigami-addons
    kcoreaddons
    kconfig
    ki18n
  ];

  meta = with lib; {
    description = "Choose a license for your project";
    homepage = "https://invent.kde.org/sdk/licentia";
    license = with licenses; [
      bsd2
      cc-by-30
      cc0
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
    ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
