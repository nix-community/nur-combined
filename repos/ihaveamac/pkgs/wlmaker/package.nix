{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cmake,
  doxygen,
  flex,
  cairo,
  ncurses,
  wlroots,
  pkg-config,
  plantuml,
  xwayland, # ?
  libxkbcommon,
  libxdg_basedir,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libdrm,
  foot,
}:

stdenv.mkDerivation rec {
  pname = "wlmaker";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "phkaeser";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-wiGDpeDLYJAmp9hCZ/u4uUPvx0BXO6BgYK2UmNmtU1g=";
    fetchSubmodules = true;
  };

  buildInputs = [
    cairo
    ncurses
    wlroots
    libxkbcommon
    libxdg_basedir
    wayland
    wayland-protocols
    libdrm
  ];

  nativeBuildInputs = [
    bison
    cmake
    doxygen
    flex
    pkg-config
    wayland-scanner
  ];

  postPatch = ''
    substituteInPlace src/toolkit/gfxbuf.c \
      --replace-fail '<drm_fourcc.h>' '<libdrm/drm_fourcc.h>'
    substituteInPlace etc/Config.plist \
      --replace-warn '/usr/bin/foot' '${foot}/bin/foot'
    substituteInPlace etc/RootMenu.plist \
      --replace-warn '/usr/bin/foot' '${foot}/bin/foot'
    substituteInPlace etc/State.plist \
      --replace-warn '/usr/bin/foot' '${foot}/bin/foot' \
      --replace-warn '/usr/bin/firefox' 'firefox'
  '';
}
