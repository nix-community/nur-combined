{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  kdbusaddons,
  kirigami-addons,
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
  version = "22.11";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "network";
    repo = pname;
    rev = "v${version}";
    sha256 = "NqDX65MllQVnlUQDrtbybORD+AJSbARYaNqFl+4zY+w=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    kdbusaddons
    kirigami-addons
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
    homepage = "https://apps.kde.org/tokodon/";
    license = with licenses; [gpl3Only cc-by-40];
    platforms = platforms.all;
  };
}
