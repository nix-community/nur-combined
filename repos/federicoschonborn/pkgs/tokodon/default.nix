{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  kdbusaddons,
  kitemmodels,
  knotifications,
  kwindowsystem,
  qqc2-desktop-style,
  qtkeychain,
  qtmultimedia,
  qtquickcontrols2,
  qtwebsockets,
  wrapQtAppsHook,
  ...
}:
stdenv.mkDerivation rec {
  pname = "tokodon";
  version = "22.09";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "network";
    repo = pname;
    rev = "v${version}";
    sha256 = "wHE8HPnjXd+5UG5WEMd7+m1hu2G3XHq/eVQNznvS/zc=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    kdbusaddons
    kitemmodels
    knotifications
    kwindowsystem
    qqc2-desktop-style
    qtkeychain
    qtmultimedia
    qtquickcontrols2
    qtwebsockets
  ];

  meta = with lib; {
    description = "Mastodon client for Plasma and Plasma Mobile";
    longDescription = ''
      Mastodon client for Plasma and Plasma Mobile.
    '';
    homepage = "https://invent.kde.org/network/tokodon";
    license = with licenses; [gpl3Only cc-by-40];
  };
}
