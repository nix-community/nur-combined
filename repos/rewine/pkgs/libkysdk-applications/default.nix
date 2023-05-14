{ lib
, stdenv
, fetchFromGitea
, qmake
, qttools
, pkg-config
, wrapQtAppsHook
, qtx11extras
, gsettings-qt
, wayland
, kwindowsystem
, kwayland
, kiconthemes
, libkysdk-base
}:

stdenv.mkDerivation rec {
  pname = "libkysdk-applications";
  version = "2.0.2.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wine";
    repo = pname;
    rev = "2c03228b0b5fa38ea577a2f817e2dbf95298c3e6";
    sha256 = "sha256-pv1VZocglp3PrsPWKdPwGH3grUy9OKby8rhr/Fxx/S8=";
  };

  postPatch = ''
    for file in $(grep -rl "/usr")
    do
      substituteInPlace $file \
        --replace "/usr" "$out"
    done
  '';

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtx11extras
    gsettings-qt
    wayland
    kwindowsystem
    kwayland
    kiconthemes
    libkysdk-base
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${kwindowsystem.dev}/include/KF5"
    "-I${libkysdk-base}/include/kysdk/kysdk-base"
  ];

  qmakeFlags = [
  #  "peony-qt.pro"
  ];

  meta = with lib; {
    description = "The File Manager Application of UKUI";
    homepage = "https://github.com/ukui/peony";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

