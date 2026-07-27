{ stdenv
, lib
, fetchFromGitLab
, cmake
, extra-cmake-modules
, libsForQt5
}:

stdenv.mkDerivation rec {
  name = "ruqola";
  version = "2.0.0";
  src = fetchFromGitLab
  {
    domain = "invent.kde.org";
    owner = "network";
    repo = name;
    rev = "v${version}";
    hash = "sha256-AszLSHmocpWevUpiiaQHl/M2WbFKv9HbcSbg4p2M4tw=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    libsForQt5.qtbase
    libsForQt5.wrapQtAppsHook
    libsForQt5.qtwebsockets
    libsForQt5.qtnetworkauth
    libsForQt5.qtmultimedia
    libsForQt5.ki18n
    libsForQt5.kcrash
    libsForQt5.kcoreaddons
    libsForQt5.syntax-highlighting
    libsForQt5.sonnet
    libsForQt5.ktextwidgets
    libsForQt5.knotifyconfig
    libsForQt5.kio
    libsForQt5.kiconthemes
    libsForQt5.kxmlgui
    libsForQt5.kidletime
    libsForQt5.prison
    libsForQt5.qtkeychain
  ];

  meta = with lib; {
    description = "KDE client for Rocket Chat";
    homepage = "https://invent.kde.org/network/ruqola";
    license = licenses.lgpl21Only;
    platforms = platforms.all;
  };
}
