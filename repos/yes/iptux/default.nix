{ lib
, stdenv
, fetchFromGitHub
, appstream
, glib
, glog
, gtk3
, jsoncpp
, libsigcxx
, meson
, ninja
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "iptux";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "iptux-src";
    repo = "iptux";
    rev = "v${version}";
    hash = "sha256-GdEd/u9t/5kD9U+jNSlT6iYjNs7pPJqu9S6Kvp71OB0=";
  };

  buildInputs = [
    glib
    glog
    gtk3
    jsoncpp
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
