{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  autoPatchelfHook,
  libsForQt5,
  alsa-lib,
  atk,
  dbus,
  cairo,
  cups,
  expat,
  fontconfig,
  gnome2,
  gdk-pixbuf,
  glib,
  gtk2,
  libpulseaudio,
  libxkbcommon,
  nspr,
  nss,
  pango,
  xorg,
}:
let
  inherit (libsForQt5) qt5;
  pname = "qcef";
  version = "1.1.8";
  buildInputs =
    with xorg;
    with qt5;
    [
      alsa-lib
      atk
      cairo
      cups
      expat
      fontconfig
      gnome2.GConf
      gdk-pixbuf
      glib
      gtk2
      nspr
      nss
      pango
      libpulseaudio
      libX11
      libxcb
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libxkbcommon
      libXrandr
      libXrender
      libXtst
      libXScrnSaver
      qtbase
      qtx11extras
      qtwebchannel
      dbus
    ];
  rpath = lib.makeLibraryPath buildInputs;
in
stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "martyr-deepin";
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-EQvowXzdC2XyOEC5bEG1vZgTaOiNLa5d3gyv1m4HC2c=";
  };

  patches = [
    ./fix-qcef-install-path.patch
    ./cef-disable-werror.patch
  ];

  inherit buildInputs;
  nativeBuildInputs = [
    cmake
    pkg-config
    autoPatchelfHook
  ];
  NIX_LDFLAGS = "--as-needed -rpath ${rpath}";

  preFixup = ''
    chmod 644 $(readlink -f $out/lib/libqcef.so)
    chmod 755 $out/lib/qcef/chrome-sandbox
  '';

  dontWrapQtApps = true;

  meta = {
    description = "Qt5 binding of CEF";
    homepage = "https://github.com/martyr-deepin/qcef";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.lgpl3;
  };
}
