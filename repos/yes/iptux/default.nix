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
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "iptux-src";
    repo = "iptux";
    rev = "v${version}";
    hash = "sha256-JhmOwSfu1ydl8v+PkORdUOHEdPvqiAhKTCpNT9LF374=";
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
