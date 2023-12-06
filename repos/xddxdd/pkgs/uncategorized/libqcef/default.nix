{
  lib,
  stdenv,
  sources,
  cmake,
  pkg-config,
  qt5,
  glib,
  gtk2,
  pango,
  cairo,
  at-spi2-atk,
  fontconfig,
  nss,
  nspr,
  expat,
  xorg,
  gnome2,
  alsa-lib,
  libpulseaudio,
  cups,
  gdk-pixbuf,
  ...
} @ args: let
  libraries = [
    glib
    gtk2
    pango
    cairo
    at-spi2-atk
    fontconfig
    nss
    nspr
    expat
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    xorg.libXrandr
    xorg.libXScrnSaver
    gnome2.GConf
    alsa-lib
    libpulseaudio
    cups
    gdk-pixbuf
  ];

  rpaths = lib.concatMapStringsSep " " (l: "-Wl,-rpath,${lib.getOutput "lib" l}/lib") libraries;
in
  stdenv.mkDerivation rec {
    inherit (sources.libqcef) pname version src;

    patches = [./fix-deprecated-option.patch];

    nativeBuildInputs = [cmake pkg-config];
    buildInputs = [
      qt5.qtbase
      qt5.qtwebengine
      qt5.qtx11extras
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
    ];

    dontWrapQtApps = true;

    makeFlags = ["VERBOSE=1"];

    preConfigure = ''
      rm -rf cef
      ln -sf ${sources.cef-binary.src} cef

      sed -i 's|-Wall|${rpaths}|g' src/CMakeLists.txt
    '';

    meta = {
      description = "Qt5 binding of CEF";
      homepage = "https://github.com/martyr-deepin/libqcef";
      platforms = ["x86_64-linux"];
      license = lib.licenses.lgpl3;
    };
  }
