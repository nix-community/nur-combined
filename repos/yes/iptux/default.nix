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
}:

stdenv.mkDerivation rec {
  pname = "iptux";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "iptux-src";
    repo = "iptux";
    rev = "v${version}";
    hash = "sha256-y/UOJbXhaevESlc5c7cpsuz+ZVNS3VkpT1rD1yLDEfk=";
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
