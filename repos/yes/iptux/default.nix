{ lib
, stdenv
, fetchFromGitHub
, appstream
, glib
, glog
, gtk3
, jsoncpp
, libayatana-appindicator
, libsigcxx
, meson
, ninja
, pkg-config
, wrapGAppsHook3
}:

stdenv.mkDerivation rec {
  pname = "iptux";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "iptux-src";
    repo = "iptux";
    rev = "v${version}";
    hash = "sha256-9IulJH07/M2ZiFu5YXO9tbltZ0R7VKHYN27KQpQ3Z70=";
  };

  buildInputs = [
    glib
    glog
    gtk3
    jsoncpp
    libayatana-appindicator
    libsigcxx
  ];

  nativeBuildInputs = [
    appstream
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  meta = with lib; {
    description = "A software for sharing in LAN";
    homepage = "https://github.com/iptux-src/iptux";
    changelog = "https://github.com/iptux-src/iptux/blob/${src.rev}/ChangeLog";
    license = licenses.gpl2Plus;
    mainProgram = "iptux";
    platforms = platforms.unix;
  };
}
