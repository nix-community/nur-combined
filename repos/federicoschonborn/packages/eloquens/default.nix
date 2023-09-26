{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, ninja
, wrapQtAppsHook
, kconfig
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, qtbase
, qtquickcontrols2
}:

stdenv.mkDerivation {
  pname = "eloquens";
  version = "unstable-2023-07-31";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "eloquens";
    rev = "925ee64e9153d877bb5a8e14db1c98e2bb3d4d63";
    hash = "sha256-k9saOlyWmSXNBMqBR8joWqSvfUTS9+bTK/noLs3Olek=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    kdbusaddons
    ki18n
    kirigami2
    qtbase
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Generate the lorem ipsum text";
    homepage = "https://invent.kde.org/sdk/eloquens";
    license = with licenses; [
      bsd2
      cc0
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
    ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
