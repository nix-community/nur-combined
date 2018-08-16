{ lib, stdenv, fetchFromGitHub, fetchgit, libusb, libtool, autoconf, pkgconfig, git,
gettext, automake, libxml2 
, autoreconfHook
, qmake4Hook
, qmake
, qtbase, qttools, qtmultimedia, libnotify, ffmpeg, gdk_pixbuf }:
let
  libvitamtp = stdenv.mkDerivation rec {
    name = "libvitamtp-${version}";
    version = "2.5.9";

    src = fetchFromGitHub {
      owner = "codestation";
      repo = "vitamtp";
      rev = "v"+version;
      sha256 = "09c9f7gqpyicfpnhrfb4r67s2hci6hh31bzmqlpds4fywv5mzaf8";
    };

    buildInputs = [ libusb libxml2 libtool autoconf automake gettext pkgconfig
    autoreconfHook ];

    meta = {
      description = "Content Manager Assistant for the PS Vita";
      homepage = https://github.com/codestation/qcma;
      license = stdenv.lib.licenses.gpl2;
      platforms = stdenv.lib.platforms.linux;
      maintainers = with stdenv.lib.maintainers; [ makefu ];
    };
  };
in stdenv.mkDerivation rec {
  name = "qcma-${version}";
  version = "8e6cafedc0f47733f33323f829624e3fc847a176";

  src = fetchFromGitHub {
    owner = "codestation";
    repo = "qcma";
    rev = version;
    sha256 = "1l95kx3x4pf5iwmwigbch5c6n2h27lls5qiy4xh15v59p5442yw5";
  };

  preConfigure = ''
    lrelease common/resources/translations/*.ts
  '';

  enableParallelBuilding = true;

  buildInputs = [ gdk_pixbuf ffmpeg libnotify libvitamtp git qtmultimedia qtbase ];
  nativeBuildInputs = [ qttools pkgconfig qmake ];

  meta = {
    description = "Content Manager Assistant for the PS Vita";
    homepage = https://github.com/codestation/qcma;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
